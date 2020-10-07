A study in how to make cython multi-threading modules and interface with Intel IIP.
Author: David van Zanten

To compile a tutorial 
- cd to the folder (e.g. Tutorial_01)
- execute python setup.py clean --all build_ext inplace
To make this a little easier, there is a vscode build task defined in the .vscode folder.

Before starting you will need to make sure you have a compiler installed (compatible with you python version). 
Check out: https://wiki.python.org/moin/WindowsCompilers#Which_Microsoft_Visual_C.2B-.2B-_compiler_to_use_with_a_specific_Python_version_.3F

You don't need to install the complete Visual Studio Community package, just the build tools is enough.
Check out: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2019 

You need to install Python (3.8 is ok) and some packages (cython, line_profiler)

The study is based on information from many sources among which:

-   https://cython.readthedocs.io/en/latest/src/tutorial/cython_tutorial.html
    General information on how to make a cython modules
    http://okigiveup.net/an-introduction-to-cython/
    General information on how to work with cython

-   https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html
    Very usefull information about compiling cython code (without and withou external libraries).

-   https://cython.readthedocs.io/en/latest/src/userguide/parallelism.html
    Some introduction to running multi-threading code (read section 'Compiling' very carefully!)
    http://nealhughes.net/parallelcomp2/
    Very useful information about running ulti-threading code
    https://software.intel.com/content/www/us/en/develop/articles/thread-parallelism-in-cython.html
    Very useful information about running ulti-threading code

-   https://cython.readthedocs.io/en/latest/src/userguide/numpy_tutorial.html#numpy-tutorial
    Information on how to interface with Python Numpy input using memoryviews. 
    https://cython.readthedocs.io/en/latest/src/tutorial/numpy.html
    The older way of working with numpy in cython. 
    https://cython.readthedocs.io/en/latest/src/userguide/memoryviews.html
    General information on memoryviews (don't miss the last paragrapg).

-   https://cython.readthedocs.io/en/latest/src/userguide/sharing_declarations.html
    How to share using cython declaration files (.pxd). Note that the function of .pxd files is different when another .pyx file exists with the same make or not.
    https://cython.readthedocs.io/en/latest/src/tutorial/pxd_files.html
    ...

-   https://cython.readthedocs.io/en/latest/src/tutorial/clibraries.html
    How to setup interfacing and linking with external libraries. 
    https://cython.readthedocs.io/en/latest/src/tutorial/external.html
    How to setup interfacing and linking with external libraries (mostly usefull for linking).
    https://cython.readthedocs.io/en/latest/src/userguide/external_C_code.html
    More in depth details on how to work with external libraries (not linking information).
    
-   https://cython.readthedocs.io/en/latest/src/userguide/language_basics.html#types   
    Useful generay info (especially about pointers!)

-   https://acsgsoc15.wordpress.com/2015/04/09/optimizing-array-in-cython/
    About the speed of handling numpy arrays!

-   https://github.com/IntelPython/scikit-ipp
    Example to how to implement Numpy and IPP in cython (uses fully external C to interface IPP which is not necessary)
    https://github.com/motmot/fastimage
    Another example on how to use IPP libraries in cython
    https://github.com/strawlab/cython_ipp
    Some example of how to right the .pxd interface definition file. 

Other unspecified resource (only limited useful):
- https://notes-on-cython.readthedocs.io/en/latest/function_declarations.html
- https://github.com/jingxu10/py-ipp-mkl
- https://flothesof.github.io/optimizing-python-code-numpy-cython-pythran-numba.html
