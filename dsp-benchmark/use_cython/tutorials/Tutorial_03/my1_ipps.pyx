# -*- coding: utf-8 -*-
"""
Created on Tue Sep 29 08:55:16 2020

@author: David van Zanten

Notes:
- https://cython.readthedocs.io/en/latest/src/userguide/sharing_declarations.html
    "When you cimport a module called modulename, the Cython compiler searches for a file called modulename.pxd. It searches for this file along the path for include files (as specified by -I command line options or the include_path option to cythonize()), as well as sys.path."
- https://cython.readthedocs.io/en/latest/src/userguide/sharing_declarations.html#sharing-extension-types
    "In Landscaping.pyx, the cimport Shrubbing declaration allows us to refer to the Shrubbery type as Shrubbing.Shrubbery. But it doesn’t bind the name Shrubbing in Landscaping’s module namespace at run time, so to access Shrubbing.standard_shrubbery() we also need to import Shrubbing."
    
    "One caveat if you use setuptools instead of distutils, the default action when running python setup.py install is to create a zipped egg file which will not work with cimport for pxd files when you try to use them from a dependent package. To prevent this, include zip_safe=False in the arguments to setup()."
"""

cimport h1_ipps

cdef class Size:
    cdef h1_ipps.IppiSize _csize

    def __init__(self, x, y):
        self._csize.width = x
        self._csize.height = y

    @property
    def width(self):
        return self._csize.width

    @width.setter
    def width(self, val):
        self._csize.width = val

    @property
    def height(self):
        return self._csize.height

    @height.setter
    def height(self,val):
        self._csize.height = val
