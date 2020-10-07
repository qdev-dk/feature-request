# Implementation of our demodulation functions
# Dereferencing in cython goes with [0] -> https://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#types

import numpy as np
cimport numpy as cnp

cimport cython
cimport cipp

from libc.stdlib cimport malloc, free
from cython.parallel import parallel, prange

# Activate IPP on module import
cipp.ippInit()

cdef void convolve(double* pdata1, const int len1, double* pdata2, const int len2, const int bufsize, double* presult) nogil:
	cdef cipp.Ipp8u* p_buffer
	
	p_buffer = cipp.ippsMalloc_8u(bufsize);
	cipp.ippsConvolve_64f(pdata1, len1, pdata2, len2, presult, 0, p_buffer)
	cipp.ippsFree( p_buffer );

@cython.boundscheck(False) 
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cpdef cnp.ndarray[cnp.float64_t, ndim=2] ipp_mt(double[:,::1] signal, double[:,::1] reference, double[::1] window):
	cdef Py_ssize_t nsignal = signal.shape[1]
	cdef Py_ssize_t N = signal.shape[0]
	cdef Py_ssize_t nreference = reference.shape[0]
	cdef Py_ssize_t nwindow = window.shape[0]
	cdef Py_ssize_t i, j 

	# Pointers to malloc allocated memory
	cdef double* yref
	cdef double* conv
			
	# Parameter for IPP functions
	cdef int bufsize = 0
	
	# Storing the average demodulation result
	#trace = np.zeros((nreference,nsignal), dtype=np.float64)							# TRACES
	#cdef double[:,::1] trace_view = trace												# TRACES

	# Storing the 'integration' result
	average = np.zeros((N,nreference), dtype=np.float64)
	cdef double[:,::1] average_view = average

	# Calculate the buffer size for convolution step
	# AlgType -> https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-1-signal-and-data-processing/filtering-functions/convolution-and-correlation-functions/special-arguments.html
	cipp.ippsConvolveGetBufferSize(nsignal, nwindow, cipp.ipp64f, cipp.ippAlgFFT, &bufsize)

	with nogil, parallel():
		yref = <double*> malloc(sizeof(double) * nsignal) # signal * reference
		conv = <double *> malloc(sizeof(double) * (nsignal + nwindow - 1)) # convolution result

		# ippAlgHintFast -> https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-2-image-processing/intel-integrated-performance-primitives-concepts-1/structures-and-enumerators-1.html
		for j in prange(N, schedule ='guided'):
			for i in range(nreference):
				cipp.ippsMul_64f(&signal[0,0]+j*nsignal, &reference[0,0]+i*nsignal, yref, nsignal)
				convolve(yref, nsignal, &window[0], nwindow, bufsize, conv)

				# Calculate the mean of a trace and store -> generates (N,2) data
				cipp.ippsMean_64f(conv, nsignal, &average_view[0,0] + j*nreference + i)

				# Accumulates the demodulation result per 'channel' -> generates (nreference, nsignal) data
				#cipp.ippsAdd_64f_I(conv, &trace_view[0,0] + i*nsignal, nsignal) 				# TRACES

		free(yref)
		free(conv)

		# Divide the accumulated demodulation result to get the average
		#for j in prange(nreference, schedule ='guided'): 								# TRACES
		#	cipp.ippsMulC_64f_I(1/<double>N, &trace_view[0,0] + j*nsignal, nsignal)		# TRACES

	return average

@cython.boundscheck(False) 
@cython.wraparound(False)
@cython.nonecheck(False)
@cython.cdivision(True)
cpdef void ipp_mk(double[:,::1] signal, double[:,::1] reference, double[::1] window,
			 double[:,::1] traces = None,
			 double[:,::1] averages = None,
			 double[:,::1] statistics = None):
	""" Demodulation of periodic data
	During demodulation 1) the signal data (columns of 'signal') is multiplied with reference data (columns of 'reference') before being convoluted with a window and averaged.  The results are saved to the function arguments 'traces', 'averages' and 'statistics' if provided (default is None).

	Args:
	- signal: A (N,k) numpy array (np.float64) containing the data. Demodulation will be applied along the second dimension (k).
	- reference: A (M, k) numpy array (np.float64) containing the reference(s) for convolution. Each column in reference will generate a seperate demodulation result per column in signal. 
	- windows: A (q) numpy array (np.float64) containing the window data. 

	- traces: A (M,k) numpy array (np.float64) buffer for the averages of convolution result along the first dimension of signal. This can be considered as the average of the convolution 'channels' along the first dimension of signal data. 
	- averages: A (M, N) numpy array (np.float64) buffer for the average of the convolution result along the second dimension of the signal data. This can be considered as the demodulation result for each demodulation channel. 
	- statistics: A (M,2) numpy array (np.float64) buffer for the average (first column) and std (second column) of the demodulation results along the first dimension of the signal data. This can be considered as average and standard deviation of the demodulation result for each demodulation channel. 
	"""

	cdef Py_ssize_t nsignal = signal.shape[1]
	cdef Py_ssize_t N = signal.shape[0]
	cdef Py_ssize_t nreference = reference.shape[0]
	cdef Py_ssize_t nwindow = window.shape[0]
	cdef Py_ssize_t i, j 

	# Pointers to malloc allocated memory
	cdef double* yref
	cdef double* conv
			
	# Parameter for IPP functions
	cdef int bufsize = 0
	
	cdef int output_flags = 0

	# Storing the average demodulation result
	if (traces != None):
		if (tuple(traces.shape) != (nreference, nsignal, 0,0,0,0,0,0)):
			raise ValueError('The shape of the trace output is not conistent with input.') 
		else: 
			output_flags |= 0b001 

	# Storing the 'integration' result
	if (averages != None):
		if (tuple(averages.shape) != (nreference, N, 0,0,0,0,0,0)):
			raise ValueError('The shape of the avarage output is not conistent with input.') 
		else: 
			output_flags |= 0b010 

	# Storing the statistics result
	if (statistics != None):
		if (tuple(statistics.shape) != (nreference, 2, 0,0,0,0,0,0)):
			raise ValueError('The shape of the avarage output is not conistent with input.') 
		else: 
			output_flags |= 0b100 

	# Calculate the buffer size for convolution step
	# AlgType -> https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-1-signal-and-data-processing/filtering-functions/convolution-and-correlation-functions/special-arguments.html
	cipp.ippsConvolveGetBufferSize(nsignal, nwindow, cipp.ipp64f, cipp.ippAlgFFT, &bufsize)

	with nogil, parallel():
		yref = <double*> malloc(sizeof(double) * nsignal) 					# signal * reference
		conv = <double *> malloc(sizeof(double) * (nsignal + nwindow - 1)) 	# convolution result

		# ippAlgHintFast -> https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top/volume-2-image-processing/intel-integrated-performance-primitives-concepts-1/structures-and-enumerators-1.html
		for j in prange(N, schedule ='guided'):
			for i in range(nreference):
				cipp.ippsMul_64f(&signal[0,0]+j*nsignal, &reference[0,0]+i*nsignal, yref, nsignal)
				convolve(yref, nsignal, &window[0], nwindow, bufsize, conv)

				# Accumulates the demodulation result per 'channel' -> generates (nreference, nsignal) data
				if (output_flags & 0b001):
					cipp.ippsAdd_64f_I(conv, &traces[0,0] + i*nsignal, nsignal) 	

				# Calculate the mean of a trace and store -> generates (nreference, N) data
				if (output_flags & 0b010):
					cipp.ippsMean_64f(conv, nsignal, &averages[0,0] + i*N + j)

		free(yref)
		free(conv)

		# Divide the accumulated demodulation result to get the average
		if (output_flags & 0b101):
			for j in prange(nreference, schedule ='guided'): 	
				if output_flags & 0b001:							
					cipp.ippsMulC_64f_I(1/<double>N, &traces[0,0] + j*nsignal, nsignal)		

				if output_flags & 0b100:	
					cipp.ippsMeanStdDev_64f(&averages[0,0]+j*N, N, &statistics[0,0]+2*j, &statistics[0,0]+2*j+1)
		