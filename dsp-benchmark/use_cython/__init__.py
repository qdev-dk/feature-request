""" Demodulation of periodic data
	During demodulation 1) the signal data (columns of 'signal') is multiplied with reference data (columns of 'reference') before being convoluted with a window and averaged.  The results are saved to the function arguments 'traces', 'averages' and 'statistics' if provided (default is None).

	Args:
	- signal: A (N,k) numpy array (np.float64) containing the data. Demodulation will be applied along the second dimension (k).
	- reference: A (M, k) numpy array (np.float64) containing the reference(s) for convolution. Each column in reference will generate a seperate demodulation result per column in signal. 
	- windows: A (q) numpy array (np.float64) containing the window data. 

	- traces: A (M,k) numpy array (np.float64) buffer for the averages of convolution result along the first dimension of signal. This can be considered as the average of the convolution 'channels' along the first dimension of signal data. 
	- averages: A (M, N) numpy array (np.float64) buffer for the average of the convolution result along the second dimension of the signal data. This can be considered as the demodulation result for each demodulation channel. 
	- statistics: A (M,2) numpy array (np.float64) buffer for the average (first column) and std (second column) of the demodulation results along the first dimension of the signal data. This can be considered as average and standard deviation of the demodulation result for each demodulation channel. 

traces = np.zeros((ref.shape[0], signal.shape[1]))
averages = np.zeros((ref.shape[0], N))
statistics = np.zeros((ref.shape[0], 2))
demodulation.ipp_mk(signal, ref, taps, 
                    traces=traces, 
                    averages=averages, 
                    statistics=statistics)
"""

from .demodulation import ipp_mk as go_with_mt
from .demodulation import ipp_sk as go