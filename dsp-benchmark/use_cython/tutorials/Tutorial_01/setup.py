# -*- coding: utf-8 -*-
"""
Created on Tue Sep 29 08:55:16 2020

@author: David van Zanten

To run execute 
python setup.py build_ext --inplace

Notes:
- https://cython.readthedocs.io/en/latest/src/quickstart/build.html
    "One caveat: the default action when running python setup.py install is to create a zipped egg file which will not work with cimport for pxd files when you try to use them from a dependent package. To prevent this, include zip_safe=False in the arguments to setup()."
"""

from setuptools import setup
from Cython.Build import cythonize

setup(
    name = 'Primes',
    ext_modules = cythonize("primes.pyx", annotate=True, build_dir="build"),
    zip_safe = False,
    libraries = [],
    library_dirs = [],         
    include_dirs=[]
)