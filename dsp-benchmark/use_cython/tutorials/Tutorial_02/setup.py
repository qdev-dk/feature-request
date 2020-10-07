# -*- coding: utf-8 -*-
"""
Created on Tue Sep 29 08:55:16 2020

@author: David van Zanten

To run execute 
python setup.py build_ext --inplace

Notes:
- Need to add numpy to the path
  SEE https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html#configuring-the-c-build
  SEE https://docs.python.org/3/distutils/apiref.html
  See https://stackoverflow.com/a/14657667
  See https://cython.readthedocs.io/en/latest/src/tutorial/clibraries.html#dynamic-linking
"""


from setuptools import setup, Extension
from Cython.Build import cythonize

import numpy

setup(
    name = 'Trying to get Numpy in Cython',
    ext_modules = cythonize([
        Extension("my1_numpy", ["my1_numpy.pyx"],
                  include_dirs= [numpy.get_include()])
    ], annotate=True, build_dir="build",),
    zip_safe = False,
    
)