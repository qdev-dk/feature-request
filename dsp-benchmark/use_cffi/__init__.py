import numpy as np
from ._ipps import ffi, lib

def go(signal, references, window):
    N, k = signal.shape
    M = references.shape[0]
    Q = window.size

    kR = (k + Q - 1)
    results = np.zeros((M, kR))

    bufsize = 0
    bufsize = ffi.new("int *")
    lib.ippsConvolveGetBufferSize(k, Q, 19, 0, bufsize)
    bufsize = bufsize[0]

    pBuffer = lib.ippsMalloc_8u(bufsize)
    pwindow = ffi.cast("double *", ffi.from_buffer(window))
        
    result = np.empty((N, (k+window.size-1)))
    presult = ffi.cast("double *", ffi.from_buffer(result))

    line_buffer = np.empty((k, 1))
    plinebuffer = ffi.cast("double *", ffi.from_buffer(line_buffer))

    psignal = ffi.cast("double *", ffi.from_buffer(signal))
    preferences = ffi.cast("double *", ffi.from_buffer(references))

    output = np.zeros((M, N))
    for j in range(M):
        # NOTE: flatten this down to a single array and run it, is actually slower!
        for i in range(N):
            lib.ippsMul_64f(psignal+i*k, preferences+j*k, plinebuffer, k)
            lib.ippsConvolve_64f(plinebuffer, k, pwindow, Q, presult+i*kR, 0, pBuffer)

        output[j,:] = np.mean(result, axis=1)
    lib.ippsFree(pBuffer)

    return output