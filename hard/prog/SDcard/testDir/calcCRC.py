#!/bin/python
import sys

POLY = 0x107

def crc(array):
    result = 0
    for byte in array:
        result ^= byte
        for _ in range(8):
            result <<= 1
            if result & 0x100:
                result ^= POLY
    return result

with open(sys.argv[1], 'rb') as file:
    print(f"{sys.argv[1]}: {hex(crc(file.read()))}")
