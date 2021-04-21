#!/usr/bin/env python3

# Test
# size_x=1920 size_y=1080 ./lcg.py "$(bc <<< "$size_x * $size_y")" | display -size "${size_x}"x"${size_y}" -depth 8 -format GRAY GRAY:-

import os
import sys
import argparse

def msb(val):
    return val >> (val.bit_length() - 8)

def lsb(val):
    return val & 0xFF

def ceildiv(a, b):
    return -(-a // b)
#This works because Python's division operator does floor division (unlike in C, where integer division truncates the fractional part).
#This also works with Python's big integers, because there's no (lossy) floating-point conversion.


def generate_lcg_RANDU( size ):
    """
    LCG RANDU- generates as many random numbers as requested by user, using a Linear Congruential Generator
    LCG uses the formula: X_(i+1) = (aX_i + c) mod m.
    This LCG uses the RANDU initial setting, a=65539; c=0; m=2^31.
    RANDU is known to have an issue: its values fall into 15 parallel 2D planes.
    """
    # Initialize variables
    x_value = 123456789      # Our seed, or X_0 = 123456789
    a = 65539                # Our "a" base value
    c = 0                    # Our "c" base value
    m = (2 ** 31)            # Our "m" base value

    block_size = 8*1024
    lcg_bytes = bytearray(block_size)
    blocks = ceildiv(size, block_size)


    # counter for how many iterations we've run
    block_count = 0
    total_bytes = 0

    #Perfom number of iterations requested by user
    with os.fdopen(sys.stdout.fileno(), "wb", closefd=False) as stdout:
        while block_count < blocks:
            pos = 0
            while pos < block_size:
                # Store value of each iteration
                x_value = (a * x_value + c) % m
                lcg_bytes[pos] = lsb(x_value)
                pos += 1
            block_count += 1
            total_bytes += block_size
            if total_bytes <= size:
                stdout.write(lcg_bytes[:block_size])
            else:
                rem = size % block_size
                stdout.write(lcg_bytes[:rem])
        stdout.flush()


parser = argparse.ArgumentParser(description='Generate random bytes using LCG')
parser.add_argument('size', metavar='N', type=int, help='Number of bytes')
args = parser.parse_args()

generate_lcg_RANDU(args.size)

