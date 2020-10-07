import numpy as np

from bootstrap import default

import numpy as np
import cupy as cp
from numba import cuda, f8, u4
    
@cuda.jit('f8(f8, u4)', device=True)
def reduce_warp(value, mask):
    offset = 16 # i.e. WARPSIZE // 2
    while offset:
        value += cuda.shfl_down_sync(mask, value, offset)
        offset //= 2
    return value

@cuda.jit('void(f8[:], f8[:,:], f8[:], f8[:,:])')
def convolve(signal, ref, window, result):
    smem = cuda.shared.array(0, f8)

    i, j = cuda.grid(2) 
    S = signal.size
    W = window.size
    R = ref.shape[0]
    
    Bix = cuda.blockIdx.x   # Block index along the x dimension       -> indexing the signal
    BDx = cuda.blockDim.x   # Number of threads along x               -> Many things
    tix = cuda.threadIdx.x  # x thread id within block [0,blockdim.x) -> indexing the window
    tiy = cuda.threadIdx.y  # y thread id within block [0,blockdim.y) -> indexing of memory
    tif = tix + tiy*BDx     # thread index within a block (flat)      -> indexing lines and shared memory
    
    index = j + tix         # reference and signal index

    value = f8(0)
    if (tix < W) & (index < S):
        value = window[tix] * (ref[R, index] * signal[index])
    value = reduce_warp(value, u4(0xffffffff))
    # Reduced sum should be present in the value of all threads with lane index == 0

    # Store the warp reduction in the shared memory
    if tif % 32 == 0:             # For all threads with lane index == 0
        smem[tif // 32] = value   # Flat warp id 
    cuda.syncthreads()  

    # When the blocksize is smaller than a single warp (32), we are done. 
    # In this case we can be very specific about the locations we need
    if (BDx <= 32) and (tix == 0): 
        result[Bix, j] = smem[tiy]

    # Otherwise, take values from the shared memory van reduce.
    # NOTE: maximum number of threads is 1024 which is 32 times a warp (consisting of 32 threads)
    # This means, the warp reductions of 32 warps, fit baxck into a single warp. 
    
    # Disperse the reduction values from the memory over the first threads along the x direction. 
    # All others become 0
    Nwx = (BDx-1)//32 + 1
    if (tix < BDx // 32):
        values = smem[tix + Nwx*tiy]
    else:
        values = 0
    # Perhaps its better to put the index definition outside the if-else block and remove this barrier 
    cuda.syncthreads() 

    # All threads in a first warp along x 
    if tix // 32 == 0:
        value = reduce_warp(value, u4(0xffffffff))
    cuda.syncthreads() 

    if (tix == 0) and (j < S):
        result[Bix, j] = value


signal, references, window = default(N=10, p=4*1024)

kernel = np.zeros(((window.size//32+1)*32,))
kernel[:window.size] = window

gpuR = cuda.to_device(references)
gpuW = cuda.to_device(kernel)

W = kernel.size
N, S = signal.shape
M = references.shape[0]

BX, BY = W, min(1024//W, S)
blockdim = (BX, BY)
griddim = (M, (S-1)//BY+1)

# Calculate the size of shared memory required for a block
smem_size = signal.itemsize * (BX//32 * BY)

cuda.profile_start()

stream = cuda.stream()

gpuS = cuda.to_device(signal, stream=stream)
buffer = cuda.device_array((S, N), np.float64, stream=stream)

with stream.auto_synchronize():   
    for i in range(gpuS.shape[0]):
        convolve[griddim, blockdim, stream, smem_size](gpuS[i,:], gpuR, gpuW, buffer)
        
        cpbuffer = cp.asarray(buffer)
        output = cp.sum(cpbuffer, axis=1)

cuda.profile_stop() 