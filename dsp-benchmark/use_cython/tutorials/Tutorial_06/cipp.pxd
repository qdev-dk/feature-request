# Contains a selective set of IPP functions
# Check out https://software.intel.com/content/www/us/en/develop/documentation/ipp-dev-reference/top.html

from libc cimport stdint

cdef extern from "ipp.h" nogil:
    pass
    
cdef extern from "ipptypes.h" nogil:
    ctypedef int IppEnum
    ctypedef int IppStatus

    ctypedef enum IppHintAlgorithm:
        ippAlgHintNone
        ippAlgHintFast
        ippAlgHintAccurate
    
    ctypedef enum IppWinType:
        ippWinBartlett
        ippWinBlackman
        ippWinHamming
        ippWinHann
        ippWinRect

    ctypedef enum IppAlgType:
        ippAlgAuto    = 0x00000000
        ippAlgDirect  = 0x00000001
        ippAlgFFT     = 0x00000002
        ippAlgMask    = 0x000000FF

    enum cpuFeatures:    
        ippCPUID_MMX             = 0x00000001
        ippCPUID_SSE             = 0x00000002
        ippCPUID_SSE2            = 0x00000004
        ippCPUID_SSE3            = 0x00000008
        ippCPUID_SSSE3           = 0x00000010
        ippCPUID_MOVBE           = 0x00000020
        ippCPUID_SSE41           = 0x00000040
        ippCPUID_SSE42           = 0x00000080
        ippCPUID_AVX             = 0x00000100
        ippAVX_ENABLEDBYOS       = 0x00000200
        ippCPUID_AES             = 0x00000400
        ippCPUID_CLMUL           = 0x00000800
        ippCPUID_ABR             = 0x00001000
        ippCPUID_RDRAND          = 0x00002000
        ippCPUID_F16C            = 0x00004000
        ippCPUID_AVX2            = 0x00008000
        ippCPUID_ADCOX           = 0x00010000
        ippCPUID_RDSEED          = 0x00020000
        ippCPUID_PREFETCHW       = 0x00040000
        ippCPUID_SHA             = 0x00080000
        ippCPUID_AVX512F         = 0x00100000
        ippCPUID_AVX512CD        = 0x00200000
        ippCPUID_AVX512ER        = 0x00400000
        ippCPUID_AVX512PF        = 0x00800000
        ippCPUID_AVX512BW        = 0x01000000
        ippCPUID_AVX512DQ        = 0x02000000
        ippCPUID_AVX512VL        = 0x04000000
        ippCPUID_AVX512VBMI      = 0x08000000
        ippCPUID_MPX             = 0x10000000
        ippCPUID_AVX512_4FMADDPS = 0x20000000
        ippCPUID_AVX512_4VNNIW   = 0x40000000
        ippCPUID_KNC             = 0x80000000

cdef extern from "ippbase.h" nogil:
    ctypedef unsigned char      Ipp8u
    ctypedef unsigned short     Ipp16u
    ctypedef unsigned int       Ipp32u
    ctypedef stdint.uint64_t    Ipp64u

    ctypedef signed char        Ipp8s
    ctypedef signed short       Ipp16s
    ctypedef signed int         Ipp32s
    ctypedef stdint.int64_t     Ipp64s
    
    ctypedef Ipp16s              Ipp16f
    ctypedef float              Ipp32f
    ctypedef double             Ipp64f
    
    ctypedef struct Ipp8sc:
        Ipp8s  re
        Ipp8s  im
    
    ctypedef struct Ipp16sc:
        Ipp16s  re
        Ipp16s  im
    
    ctypedef struct Ipp16uc:
        Ipp16u  re
        Ipp16u  im

    ctypedef struct Ipp32sc: 
        Ipp32s  re
        Ipp32s  im

    ctypedef struct Ipp32fc:
        Ipp32f  re
        Ipp32f  im

    ctypedef struct Ipp64sc:
        Ipp64s  re
        Ipp64s  im

    ctypedef struct Ipp64fc:
        Ipp64f  re
        Ipp64f  im

    ctypedef enum IppDataType:
        ippUndef = -1
        ipp1u    =  0
        ipp8u    =  1
        ipp8uc   =  2
        ipp8s    =  3
        ipp8sc   =  4
        ipp16u   =  5
        ipp16uc  =  6
        ipp16s   =  7
        ipp16sc  =  8
        ipp32u   =  9
        ipp32uc  = 10
        ipp32s   = 11
        ipp32sc  = 12
        ipp32f   = 13
        ipp32fc  = 14
        ipp64u   = 15
        ipp64uc  = 16
        ipp64s   = 17
        ipp64sc  = 18
        ipp64f   = 19
        ipp64fc  = 20

    ctypedef struct IppLibraryVersion:
        int major
        int minor
        int majorBuild
        int build
        char targetCpu[4]
        const char* Name
        const char* Version
        const char* BuildDate

cdef extern from "ippcore.h" nogil:
    IppStatus ippInit()
    char* ippGetStatusString( IppStatus StsCode )

    IppStatus ippGetNumThreads( int* pNumThr )
    IppStatus ippSetNumThreads( int numThr )

    Ipp64u ippGetEnabledCpuFeatures()
    IppStatus ippGetCpuFeatures( Ipp64u* pFeaturesMask, Ipp32u pCpuidInfoRegs[4])
    IppStatus ippSetCpuFeatures( Ipp64u cpuFeatures)

cdef extern from "ipps.h" nogil:
    Ipp8u* ippsMalloc_8u(int len)
    void ippsFree(void* ptr)

    IppStatus ippSetFlushToZero( int value, unsigned int* pUMask )
    IppStatus ippSetDenormAreZeros( int value )

    # Initializes a vector to zero. 
    # -> Don't know whether required
    IppStatus ippsZero_8u(Ipp8u* pDst, int len)
    IppStatus ippsZero_16s(Ipp16s* pDst, int len)
    IppStatus ippsZero_32s(Ipp32s* pDst, int len)
    IppStatus ippsZero_32f(Ipp32f* pDst, int len)
    IppStatus ippsZero_64s(Ipp64s* pDst, int len)
    IppStatus ippsZero_64f(Ipp64f* pDst, int len)
    IppStatus ippsZero_16sc(Ipp16sc* pDst, int len)
    IppStatus ippsZero_32sc(Ipp32sc* pDst, int len)
    IppStatus ippsZero_32fc(Ipp32fc* pDst, int len)
    IppStatus ippsZero_64sc(Ipp64sc* pDst, int len)
    IppStatus ippsZero_64fc(Ipp64fc* pDst, int len)

    # Multiplies the elements of two vectors.
    # -> Create I(ni, t), Q(ni, t) raw time traces
    IppStatus ippsMul_32f(const Ipp32f* pSrc1, const Ipp32f* pSrc2, Ipp32f* pDst, int len)
    IppStatus ippsMul_64f(const Ipp64f* pSrc1, const Ipp64f* pSrc2, Ipp64f* pDst, int len)
    IppStatus ippsMul_32f_I(const Ipp32f* pSrc, Ipp32f* pSrcDst, int len)
    IppStatus ippsMul_64f_I(const Ipp64f* pSrc, Ipp64f* pSrcDst, int len)

    IppStatus ippsMulC_32f_I(Ipp32f val, Ipp32f* pSrcDst, int len)
    IppStatus ippsMulC_64f_I(Ipp64f val, Ipp64f* pSrcDst, int len)

    # Convolutions
    # -> Apply a low pass filter
    IppStatus ippsConvolveGetBufferSize (int src1Len, int src2Len, IppDataType dataType, IppEnum algType, int* pBufferSize)
    IppStatus ippsConvolve_32f (const Ipp32f* pSrc1, int src1Len, const Ipp32f* pSrc2, int src2Len, Ipp32f* pDst, IppEnum algType, Ipp8u* pBuffer)
    IppStatus ippsConvolve_64f (const Ipp64f* pSrc1, int src1Len, const Ipp64f* pSrc2, int src2Len, Ipp64f* pDst, IppEnum algType, Ipp8u* pBuffer)

    # Copy actions
    IppStatus ippsCopy_32f(const Ipp32f* pSrc, Ipp32f* pDst, int len)
    IppStatus ippsCopy_64f(const Ipp64f* pSrc, Ipp64f* pDst, int len)

    # In place additional
    IppStatus ippsAdd_32f_I(const Ipp32f* pSrc, Ipp32f* pSrcDst, int len)
    IppStatus ippsAdd_64f_I(const Ipp64f* pSrc, Ipp64f* pSrcDst, int len)


    # Computes the mean value of a vector.
    # -> Apply 'integration' to get I(ni), Q(ni)
    IppStatus ippsMean_32f(const Ipp32f* pSrc, int len, Ipp32f* pMean, IppHintAlgorithm hint)
    IppStatus ippsMean_32fc(const Ipp32fc* pSrc, int len, Ipp32fc* pMean, IppHintAlgorithm hint)
    IppStatus ippsMean_64f(const Ipp64f* pSrc, int len, Ipp64f* pMean)
    IppStatus ippsMean_64fc(const Ipp64fc* pSrc, int len, Ipp64fc* pMean)

    # Computes the mean value and the standard deviation value of a vector.
    IppStatus ippsMeanStdDev_32f(const Ipp32f* pSrc, int len, Ipp32f* pMean, Ipp32f* pStdDev, IppHintAlgorithm hint)
    IppStatus ippsMeanStdDev_64f(const Ipp64f* pSrc, int len, Ipp64f* pMean, Ipp64f* pStdDev)
    IppStatus ippsMeanStdDev_16s_Sfs(const Ipp16s* pSrc, int len, Ipp16s* pMean, Ipp16s* pStdDev, int scaleFactor)
    IppStatus ippsMeanStdDev_16s32s_Sfs(const Ipp16s* pSrc, int len, Ipp32s* pMean, Ipp32s* pStdDev, int scaleFactor)

    # Returns a complex vector constructed from the real and imaginary parts of two real vectors.
    IppStatus ippsRealToCplx_32f(const Ipp32f* pSrcRe, const Ipp32f* pSrcIm, Ipp32fc* pDst, int len)
    IppStatus ippsRealToCplx_64f(const Ipp64f* pSrcRe, const Ipp64f* pSrcIm, Ipp64fc* pDst, int len)

    # Normalizes elements of a real or complex vector using offset and division operations.
    IppStatus ippsNormalize_32f(const Ipp32f* pSrc, Ipp32f* pDst, int len, Ipp32f vSub, Ipp32f vDiv)
    IppStatus ippsNormalize_64f(const Ipp64f* pSrc, Ipp64f* pDst, int len, Ipp64f vSub, Ipp64f vDiv)
    IppStatus ippsNormalize_32fc(const Ipp32fc* pSrc, Ipp32fc* pDst, int len, Ipp32fc vSub, Ipp32f vDiv)
    IppStatus ippsNormalize_64fc(const Ipp64fc* pSrc, Ipp64fc* pDst, int len, Ipp64fc vSub, Ipp64f vDiv)
    IppStatus ippsNormalize_16s_Sfs(const Ipp16s* pSrc, Ipp16s* pDst, int len, Ipp16s vSub, int vDiv, int scaleFactor)
    IppStatus ippsNormalize_16sc_Sfs(const Ipp16sc* pSrc, Ipp16sc* pDst, int len, Ipp16sc vSub, int vDiv, int scaleFactor)

    # Computes the magnitudes of the elements of a complex vector.
    IppStatus ippsMagnitude_32f(const Ipp32f* pSrcRe, const Ipp32f* pSrcIm, Ipp32f* pDst, int len)
    IppStatus ippsMagnitude_64f(const Ipp64f* pSrcRe, const Ipp64f* pSrcIm, Ipp64f* pDst, int len)
    IppStatus ippsMagnitude_32fc(const Ipp32fc* pSrc, Ipp32f* pDst, int len)
    IppStatus ippsMagnitude_64fc(const Ipp64fc* pSrc, Ipp64f* pDst, int len)
    IppStatus ippsMagnitude_16s32f(const Ipp16s* pSrcRe, const Ipp16s* pSrcIm, Ipp32f* pDst, int len)
    IppStatus ippsMagnitude_16sc32f(const Ipp16sc* pSrc, Ipp32f* pDst, int len)
    IppStatus ippsMagnitude_16s_Sfs(const Ipp16s* pSrcRe, const Ipp16s* pSrcIm, Ipp16s* pDst, int len, int scaleFactor)
    IppStatus ippsMagnitude_16sc_Sfs(const Ipp16sc* pSrc, Ipp16s* pDst, int len, int scaleFactor)
    IppStatus ippsMagnitude_32sc_Sfs(const Ipp32sc* pSrc, Ipp32s* pDst, int len, int scaleFactor)

    # Computes the phase angles of elements of a complex vector.
    IppStatus ippsPhase_64fc(const Ipp64fc* pSrc, Ipp64f* pDst, int len)
    IppStatus ippsPhase_32fc(const Ipp32fc* pSrc, Ipp32f* pDst, int len)
    IppStatus ippsPhase_16sc32f(const Ipp16sc* pSrc, Ipp32f* pDst, int len)
    IppStatus ippsPhase_64f(const Ipp64f* pSrcRe, const Ipp64f* pSrcIm, Ipp64f* pDst, int len)
    IppStatus ippsPhase_32f(const Ipp32f* pSrcRe, const Ipp32f* pSrcIm, Ipp32f* pDst, int len)
    IppStatus ippsPhase_16s32f(const Ipp16s* pSrcRe, const Ipp16s* pSrcIm, Ipp32f* pDst, int len)
    IppStatus ippsPhase_16sc_Sfs(const Ipp16sc* pSrc, Ipp16s* pDst, int len, int scaleFactor)
    IppStatus ippsPhase_16s_Sfs(const Ipp16s* pSrcRe, const Ipp16s* pSrcIm, Ipp16s* pDst, int len, int scaleFactor)

    # Returns the real part of a complex vector in a second vector.
    IppStatus ippsReal_16sc(const Ipp16sc* pSrc, Ipp16s* pDstRe, int len)
    IppStatus ippsReal_32fc(const Ipp32fc* pSrc, Ipp32f* pDstRe, int len)
    IppStatus ippsReal_64fc(const Ipp64fc* pSrc, Ipp64f* pDstRe, int len)

    # Returns the imaginary part of a complex vector in a second vector.
    IppStatus ippsImag_16sc(const Ipp16sc* pSrc, Ipp16s* pDstIm, int len)
    IppStatus ippsImag_32fc(const Ipp32fc* pSrc, Ipp32f* pDstIm, int len)
    IppStatus ippsImag_64fc(const Ipp64fc* pSrc, Ipp64f* pDstIm, int len)

    # Returns the real and imaginary parts of a complex vector in two respective vectors.
    IppStatus ippsCplxToReal_16sc(const Ipp16sc* pSrc, Ipp16s* pDstRe, Ipp16s* pDstIm, int len)
    IppStatus ippsCplxToReal_32fc(const Ipp32fc* pSrc, Ipp32f* pDstRe, Ipp32f* pDstIm, int len)
    IppStatus ippsCplxToReal_64fc(const Ipp64fc* pSrc, Ipp64f* pDstRe, Ipp64f* pDstIm, int len)
