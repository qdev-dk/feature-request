# -*- coding: utf-8 -*-
"""
Created on Tue Sep 29 08:55:16 2020

@author: David van Zanten

To run execute 
python setup.py build_ext --inplace

Notes:
What cython does is 
- create a .obj file from the transpiles .c
- create a .dll file (but renamed to .pyd) using external libs


https://stackoverflow.com/a/62723124

https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=vs-2019

"""

from setuptools import setup, Extension
from Cython.Build import cythonize

import numpy

ipp_root = 'C:/Program Files (x86)/IntelSWTools/sw_dev_tools/compilers_and_libraries_2020.2.254/windows'
setup(
    name = 'Trying to get Intel IPP in Cython',
    ext_modules = cythonize([
        Extension("my1_ipps", ["my1_ipps.pyx"],
                  include_dirs= [ipp_root+'/ipp/include', numpy.get_include()],
                  libraries=['ipps'],
                  library_dirs=[ipp_root+'/ipp/lib/intel64_win'])
    ], annotate=True, build_dir="build", language_level = "3"),
    zip_safe = False,
    
)