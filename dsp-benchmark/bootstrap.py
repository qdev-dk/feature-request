""" Bootstrap your testing data 

This module provides functions to create testing data.
"""

import numpy as np
import ctypes as C
from collections import namedtuple
import matplotlib.pyplot as plt
from scipy.signal import firwin, fftconvolve, lfilter, kaiserord

pi = np.pi 
Harmonic = namedtuple('Harmonic', ['frequency', 'amplitude', 'phase'])

def default(N=500, p=5001, f0=(2.5,)):
    """ Generate standard data for benchmarking 
    Return:
    - signal: data to demodulate
    - window: the filter window for the convolution step
    """
    #N = N
    #f0=f0
    nsamples = p
    fsample = 400

    ripple_db = 40.0
    cutoff_hz = 10.0
    
    harmonics = [Harmonic(1, 0.5, 0), 
                 Harmonic(0.4, 2.5, pi/2 + 0.1),
                 Harmonic(0.2, 15.3, pi/2),
                 Harmonic(0.1, 23.45, pi/2 + 0.8)]
    
    t = np.arange(nsamples) / fsample
    signal = np.zeros((N, nsamples))
    for ampl, freq, phase in harmonics:
        ampl = ampl*np.ones(t.shape)
        ampl = np.tile(ampl, (N,1)) + np.outer(0.2*np.random.randint(2, size=(N,)), ampl)
    
        phase = phase*np.ones(t.shape)
        phase = np.tile(phase, (N,1)) + np.outer(0.5*np.random.randint(2, size=(N,)), phase)
    
        x = ampl * np.cos(2*pi*freq*t + phase)
        signal += np.random.normal(0, 0.8*ampl, (N, nsamples)) + x
    
    references = np.zeros((2*len(f0), nsamples))
    for i, fx in enumerate(f0):
        references[2*i,:] = np.cos(2*pi*fx*t)
        references[2*i+1,:] = np.sin(2*pi*fx*t)
    
    nyq_rate = fsample/2.
    width = 5. / nyq_rate
    
    ntaps, beta = kaiserord(ripple_db, width)
    window = firwin(ntaps, cutoff_hz/nyq_rate, window=('kaiser', beta))

    return signal, references, window
