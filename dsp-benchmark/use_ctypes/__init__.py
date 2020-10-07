# -*- coding: utf-8 -*-
"""
Created on Mon Sep 28 12:11:28 2020

@author: David van Zanten

Documentation:

- Some example on Github:
https://github.com/jingxu10/py-ipp-mkl/blob/master/resize_fft.py    

- Using numpy arrays with ctypes:
https://scipy-cookbook.readthedocs.io/items/Ctypes.html    
https://numpy.org/doc/stable/reference/generated/numpy.ndarray.ctypes.html

- Casting return type in the right form:
https://docs.python.org/3/library/ctypes.html#return-types    

- INTEL IIP Development reference:
https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-1-signal-and-data-processing/filtering-functions/convolution-and-correlation-functions/convolve.html
https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-1-signal-and-data-processing/filtering-functions/convolution-and-correlation-functions/convolvegetbuffersize.html
https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-1-signal-and-data-processing/support-functions/memory-allocation-functions/malloc.html

"""
import numpy as np
import ctypes as C

# Loading the requires libaries
ipps = C.cdll.LoadLibrary("ipps.dll")

# Define the ctypes interfaces
GetBufferSize = ipps.ippsConvolveGetBufferSize
GetBufferSize.argtypes = [C.c_int, C.c_int, C.c_int, C.c_int, C.POINTER(C.c_int)]
GetBufferSize.restype = None

Convolve_64f = ipps.ippsConvolve_64f
Convolve_64f.argtypes = [C.POINTER(C.c_double), C.c_int,
                         C.POINTER(C.c_double), C.c_int,
                         C.POINTER(C.c_double),
                         C.c_int, C.POINTER(C.c_ubyte)]
Convolve_64f.restype = None

Malloc_8u = ipps.ippsMalloc_8u
Malloc_8u.argtypes = [C.c_int]
Malloc_8u.restype = C.POINTER(C.c_ubyte)

def ctype_convolve(signal, window):
    bufsize = C.c_int(0)
    GetBufferSize(signal.size, window.size, 19, 0, C.byref(bufsize))

    psignal = signal.ctypes.data_as(C.POINTER(C.c_double))
    pwindow = window.ctypes.data_as(C.POINTER(C.c_double))

    result = np.empty((signal.size+window.size-1))
    presult = result.ctypes.data_as(C.POINTER(C.c_double))

    # https://medium.com/@tpl2go/a-beginners-introduction-to-intel-performance-primitives-d6fecb67795c
    pBuffer = Malloc_8u(bufsize)
    Convolve_64f(psignal, int(signal.size), pwindow, int(window.size), presult, 0, pBuffer)
    ipps.ippsFree(pBuffer)

    return result 

def go(signal, references, window):
    N, k = signal.shape
    M = references.shape[0]

    results = np.zeros((M, N))
    for j in range(M):
        for i in range(N):
            buffer = references[j,:] * signal[i,:]
            buffer = ctype_convolve(buffer, window)

            results[j,i] = np.mean(buffer)
 
    return results