# Implementation of our demodulation functions

import numpy as np
cimport numpy as cnp

cimport cython
from libc cimport math

from cython.parallel import parallel, prange
from libc.stdlib cimport malloc, free

cdef void c_convolve(double *signal, int nsignal, double *window, int nwindow) nogil:
  cdef Py_ssize_t i, j
  cdef int ji
  cdef double sum

  for i in range(nsignal):
    sum = 0
    for j in range(nwindow):
        ji = i - j + nwindow
        if (ji >= 0) and (ji < nsignal):  
            sum += window[j] * signal[ji]
    signal[i] = sum

@cython.boundscheck(False) 
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cpdef cnp.ndarray[cnp.float64_t, ndim=2] pure_c_mt(double[:,::1] signal, double[::1] t, double[::1] window, double f0):
  cdef Py_ssize_t nsignal = signal.shape[1]
  cdef Py_ssize_t N = signal.shape[0]
  cdef Py_ssize_t nwindow = window.shape[0]
  
  cdef Py_ssize_t i, j 

  cdef float pi = np.pi
  cdef double * yI
  cdef double * yQ

  result = np.zeros((N,2), dtype=np.float64)
  cdef double[:,::1] rview = result

  with nogil, parallel(num_threads=12):
    yI = <double *> malloc(sizeof(double) * nsignal)
    yQ = <double *> malloc(sizeof(double) * nsignal)

    for j in prange(N, schedule ='guided'):
      for i in range(nsignal):
        yI[i] = signal[j, i] * math.cos(2*pi*f0*t[i])
        yQ[i] = signal[j, i] * math.sin(2*pi*f0*t[i])

      c_convolve(yI, nsignal, &window[0], nwindow)
      c_convolve(yQ, nsignal, &window[0], nwindow)

      for i in range(nsignal):
        rview[j,0] += yI[i]/nsignal
        rview[j,1] += yQ[i]/nsignal

    free(yI)
    free(yQ)
  
  return result
