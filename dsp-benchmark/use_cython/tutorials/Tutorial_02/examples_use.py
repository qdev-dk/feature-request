#%%
import numpy as np
import my1_numpy

N = 1001
f = np.arange(N*N, dtype=np.int).reshape((N,N))
g = np.arange(81, dtype=np.int).reshape((9, 9))

my1_numpy.naive_convolve(f, g)
# %%
