import numba
import numpy as np

from numba import jit, njit, guvectorize, vectorize
from numba import cuda, float32, float64

import cupy as cp

""" 
Args:
	- signal: A (N,k) numpy array (np.float64) containing the data. Demodulation will be applied along the second dimension (k).
	- reference: A (M, k) numpy array (np.float64) containing the reference(s) for convolution. Each column in reference will generate a seperate demodulation result per column in signal. 
	- windows: A (q) numpy array (np.float64) containing the window data. 

Result:
	- averages: A (M, N) numpy array (np.float64) buffer for the average of the convolution result along the second dimension of the signal data. This can be considered as the demodulation result for each demodulation channel. 
"""

@njit(parallel=True, nogil=True)
def go_cpu_mt(signal, references, window): 
    N, k = signal.shape
    M = references.shape[0]

    results = np.zeros((M, N))
    for j in range(M):
        for i in numba.prange(N):
            buffer = references[j,:] * signal[i,:]
            buffer = np.convolve(buffer, window)

            results[j,i] = np.mean(buffer)
 
    return results

@guvectorize('float64[:,:], complex64[:]', '(n,m)->(n)', target='parallel')
def go_cpu_ufunc(x, result):
    # TODO: finish!
    pass
    # n,m = x.shape

    # for i in numba.prange(n):
    #     cI = np.convolve(taps, yI*x[i,:])
    #     cQ = np.convolve(taps, yQ*x[i,:])
    #     result[i] = complex(np.mean(cI), np.mean(cQ))

def go_cpu_vectorized(signal, reference, window):
    pass
    # Call go_cpu_ufunc
 
# CUDA ==========================
@cuda.jit('void(f8[:,:], f8[:], f8[:], f8[:,:])')
def cuda_convolve(signal, ref, window, result):
    i, j = cuda.grid(2) 
    N, M = signal.shape
    Q = window.size
    if (i >= N) or (j >= M): 
        return
    
    sum = float64(0) 
    xstride, ystride = cuda.gridsize(2)
    for num_x in range(i, result.shape[0], xstride):
        for num_y in range(j, result.shape[1], ystride):
            delta = Q//2 

            sum = 0
            for k in range(Q):
                j_k = num_y - k + delta
                if (j_k >= 0) and (j_k < M):  
                    sum += window[k] * ref[j_k]*signal[num_x, j_k]
            result[num_x, num_y] = sum
    
def init_gpu(references, window):
    """ Initialize GPU memory 
    Store the reference and window data in the gpu memory and return the handles. 
    
    Arguments:
    - reference: A (M, k) numpy array (np.float64) containing the reference(s) for convolution. Each column in reference will generate a seperate demodulation result per column in signal. 
	- windows: A (q) numpy array (np.float64) containing the window data. 
    Returns:
    - gpuR, gpuW: references to the memory on the GPU
    """
    gpuR = cuda.to_device(references)
    gpuW = cuda.to_device(window)
    return gpuR, gpuW

def go_cuda(signal, gpuR, gpuW, griddim=None, blockdim=None):
    """ Run demodulation on the GPU
    First store the reference and window data on the GPU using the init_gpu() function. The object returned are 
    required for this function.

    Returns:
    - A (M, N) numpy array (np.float64) buffer for the average of the convolution result along the second dimension of the signal data. This can be considered as the demodulation result for each demodulation channel. 
    """
    N, k = signal.shape
    M = gpuR.shape[0]
    results = np.zeros((M, N))

    if blockdim is None:
        blockdim = (8,8)

    if griddim is None:
        griddim = (N//blockdim[0] + 1, k//blockdim[1] + 1)

    # Allocate memory on the GPU
    buffer = cuda.device_array(signal.shape, np.float64)

    # Transfer the signal data to the GPU
    gpuS = cuda.to_device(signal)

    for i in range(M):
        # We apply our convolution to our image:
        cuda_convolve[griddim, blockdim](gpuS, gpuR[i,:], gpuW, buffer)

        # Take the 'integrant' (We should changed to to a GPU operation as well?)
        results[i,:] = np.mean(buffer.copy_to_host(), axis=1)

    return results