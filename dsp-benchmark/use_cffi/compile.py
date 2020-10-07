# -*- coding: utf-8 -*-
"""
Created on Mon Sep 28 15:41:56 2020

@author: David van Zanten


- Documentation for Cython
    https://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html
"""

from cffi import FFI
ffibuilder = FFI()

ffibuilder.cdef("""
    typedef double Ipp64f;
    typedef unsigned char Ipp8u;
    typedef signed int IppStatus;
    typedef int IppEnum;
    typedef enum {
       ippUndef = -1,
       ipp1u    =  0,
       ipp8u    =  1,
       ipp8uc   =  2,
       ipp8s    =  3,
       ipp8sc   =  4,
       ipp16u   =  5,
       ipp16uc  =  6,
       ipp16s   =  7,
       ipp16sc  =  8,
       ipp32u   =  9,
       ipp32uc  = 10,
       ipp32s   = 11,
       ipp32sc  = 12,
       ipp32f   = 13,
       ipp32fc  = 14,
       ipp64u   = 15,
       ipp64uc  = 16,
       ipp64s   = 17,
       ipp64sc  = 18,
       ipp64f   = 19,
       ipp64fc  = 20
    } IppDataType;

    void ippsFree(void* ptr);
    Ipp8u* ippsMalloc_8u(int len);
    
    IppStatus ippsConvolveGetBufferSize(int src1Len, int src2Len, IppDataType dataType, IppEnum algType, int* pBufferSize);   // list all the function prototypes from the
    IppStatus ippsConvolve_64f(const Ipp64f* pSrc1, int src1Len, const Ipp64f* pSrc2, int src2Len, Ipp64f* pDst, IppEnum algType, Ipp8u* pBuffer);    // library that we want to use
    
    IppStatus ippsMul_64f(const Ipp64f* pSrc1, const Ipp64f* pSrc2, Ipp64f* pDst, int len);

    IppStatus ippsMul_64f_I(const Ipp64f* pSrc, Ipp64f* pSrcDst, int len);

    IppStatus ippsAdd_64f_I(const Ipp64f* pSrc, Ipp64f* pSrcDst, int len);

    IppStatus ippsMean_64f(const Ipp64f* pSrc, int len, Ipp64f* pMean);
    
    """)

# set_source() gives the name of the python extension module to
# produce, and some C source code as a string.  This C code needs
# to make the declarated functions, types and globals available,
# so it is often just the "#include".
hpath = 'C:/Program Files (x86)/IntelSWTools/sw_dev_tools/compilers_and_libraries_2020.2.254/windows/ipp/include'
lpath = 'C:/Program Files (x86)/IntelSWTools/sw_dev_tools/compilers_and_libraries_2020.2.254/windows/ipp/lib/intel64_win'

ffibuilder.set_source("_ipps",
"""
     #include <ippbase.h>
     #include <ipptypes.h>
     #include <ipps.h>   // the C header of the library
""",
   library_dirs = [lpath],  # here we can provide where the library is located,
                       # as we are using C standard library empty list is enough
   libraries = ['ipps'],   # name of the library we want to interface
   include_dirs=[hpath],
)

ffibuilder.compile(verbose=True)