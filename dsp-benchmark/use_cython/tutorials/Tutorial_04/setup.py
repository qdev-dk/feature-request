# -*- coding: utf-8 -*-
"""
Created on Tue Sep 29 08:55:16 2020

@author: David van Zanten

To run execute 
python setup.py build_ext --inplace

Notes:
- What cython does is 
    - create a .obj file from the transpiles .c
    - create a .dll file (but renamed to .pyd) using external libs
    https://stackoverflow.com/a/62723124
    https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=vs-2019

- what are pxd file
    Many things in fact
    - https://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#the-implementation-file
       "Note When a .pyx file is compiled, Cython first checks to see if a corresponding .pxd file exists and processes it first. It acts like a header file for a Cython .pyx file. You can put inside functions that will be used by other Cython modules. This allows different Cython modules to use functions and classes from each other without the Python overhead. To read more about what how to do that, you can see pxd files."
    - https://cython.readthedocs.io/en/latest/src/tutorial/pxd_files.html
       "When accompanying an equally named pyx file, they provide a Cython interface to the Cython module so that other Cython modules can communicate with it using a more efficient protocol than the Python one."
    - https://cython.readthedocs.io/en/latest/src/userguide/sharing_declarations.html
       "A .pxd file that consists solely of extern declarations does not need to correspond to an actual .pyx file or Python module. This can make it a convenient place to put common declarations, for example declarations of functions from an external library that one wants to use in several modules"
"""

from setuptools import setup, Extension
from Cython.Build import cythonize

import numpy

extensions = [
    Extension("demodulation", ["demodulation.pyx"],
                include_dirs = [numpy.get_include()],
                extra_compile_args = ['/openmp'],
                extra_link_args = ['/openmp']
             )
]

setup(
    name = 'Trying to get Intel IPP in Cython',
    ext_modules = cythonize(extensions, annotate=True, build_dir="build", language_level = "3"),
    zip_safe = False,
    
)