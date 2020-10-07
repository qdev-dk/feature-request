# -*- coding: utf-8 -*-
"""
Created on Tue Sep 29 08:55:16 2020

@author: David van Zanten

Notes
- https://cython.readthedocs.io/en/latest/src/tutorial/cython_tutorial.html
    + Memory management
    "You cannot create very large arrays in this manner, because they are allocated on the C function call stack, which is a rather precious and scarce resource. To request larger arrays, or even arrays with a length only known at runtime, you can learn how to make efficient use of C memory allocation, Python arrays or NumPy arrays with Cython." 

    + When do you get C speed
    "Because no Python objects are referred to, the loop is translated entirely into C code, and thus runs very fast. You will notice the way we iterate over the p C array."

    + Conversion
    "You’ll notice we declare a Python list exactly the same way it would be in Python. Because the variable result_as_list hasn’t been explicitly declared with a type, it is assumed to hold a Python object, and from the assignment, Cython also knows that the exact type is a Python list."
"""

def make(int nb_primes):
    cdef int n, i, len_p
    cdef int p[1000]
    if nb_primes > 1000:
        nb_primes = 1000

    len_p = 0  # The current number of elements in p.
    n = 2
    while len_p < nb_primes:
        # Is n prime?
        for i in p[:len_p]:
            if n % i == 0:
                break

        # If no break occurred in the loop, we have a prime.
        else:
            p[len_p] = n
            len_p += 1
        n += 1

    # Let's return the result in a python list:
    result_as_list  = [prime for prime in p[:len_p]]
    return result_as_list