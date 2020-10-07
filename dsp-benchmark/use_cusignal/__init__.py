import numpy as np
import cupy as cp
import cusignal

def init_gpu(references, window):
    """ Initialize GPU memory 
    Store the reference and window data in the gpu memory and return the handles. 
    
    Arguments:
    - reference: A (M, k) numpy array (np.float64) containing the reference(s) for convolution. Each column in reference will generate a seperate demodulation result per column in signal. 
	- windows: A (q) numpy array (np.float64) containing the window data. 
    Returns:
    - gpuR, gpuW: references to the memory on the GPU
    """
    gpuR = cp.asarray(references)
    gpuW = cp.asarray(window)
    return gpuR, gpuW

def go(signal, gpuR, gpuW):
    """ Run demodulation on the GPU
    First store the reference and window data on the GPU using the init_gpu() function. The object returned are 
    required for this function.

    Returns:
    - A (M, N) numpy array (np.float64) buffer for the average of the convolution result along the second dimension of the signal data. This can be considered as the demodulation result for each demodulation channel.  """
    N, k = signal.shape
    M = gpuR.shape[0]

    gpuS = cp.asarray(signal)
    gpuW = cp.tile(gpuW, (N,1))

    results = np.zeros((M, N))
    for i in range(M):
        buffer = cp.multiply(gpuS, gpuR[i,:])
        buffer = cusignal.fftconvolve(buffer, gpuW, mode='same', axes=1)
        buffer = cp.mean(buffer, axis=1)
        results[i,:] = cp.asnumpy(buffer)

    return results

def go_cupy(signal, gpuR, gpuW):
    """ Run demodulation on the GPU
    First store the reference and window data on the GPU using the init_gpu() function. The object returned are 
    required for this function.

    Returns:
    - A (M, N) numpy array (np.float64) buffer for the average of the convolution result along the second dimension of the signal data. This can be considered as the demodulation result for each demodulation channel.  """
    N, k = signal.shape
    M = gpuR.shape[0]

    gpuS = cp.asarray(signal)

    results = np.zeros((M, N))
    for i in range(M):
        buffer = cp.multiply(gpuS, gpuR[i,:])
        buffer = cp.ravel(buffer)
        buffer = cp.convolve(buffer, gpuW, mode='same')
        buffer = cp.reshape(buffer, signal.shape)
        buffer = cp.mean(buffer, axis=1)
        results[i,:] = cp.asnumpy(buffer)

    return results

