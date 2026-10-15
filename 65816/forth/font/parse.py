#!/bin/env python3

def get_lines():
    with open('font8x8_basic.h') as f:
        return f.readlines()[58:152]

def reverse_bits(n):
    return int(f'{n:08b}'[::-1], 2)

def extract_numbers(line: str):
    return [reverse_bits(int(s,16)) for s in line[6:52].split(", ")]

def to_numbers(lines):
    return [extract_numbers(line) for line in lines]


def to_forth():
    numbers = to_numbers(get_lines())
    char_number = 0x21

    for glyph in numbers:
        print(f'\\ char {chr(char_number)}')
        for line in glyph:
            print(f'${line:x} C,')
        char_number += 1

to_forth()
