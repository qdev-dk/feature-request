# h1_ipps.pxd

cdef extern from "ipps.h" nogil:
    ctypedef struct IppiSize:
        int width
        int height