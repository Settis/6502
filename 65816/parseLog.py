#!/bin/env python3

import sys
import re

TO='trace.log'
DEBUG_FILE='/tmp/debug65.txt'

PARAMS=['IP', '(IP)', 'W', '(W)', 'SP', '(SP)', 'DP', 'BUF']

def get_vars(raw_hex):
    result = []
    for i in range(len(PARAMS)):
        result.append(f"{PARAMS[i]}: {raw_hex[4*i:4*i+4]}")
    result.append(f"RP: {raw_hex[-2:]}")
    return ' '.join(result)

def get_forth_words():
    result = {}
    with open(DEBUG_FILE, 'r') as debug_file:
        for line in debug_file.readlines():
            if line.startswith('sym'):
                match = re.match(r'.*name="FORTH_WORD_(.*?)".*val=0x(.*?),', line)
                if match:
                    value = int(match.group(2), 16)
                    name = match.group(1)
                    result[value] = name
    return result

def convert(fr, to):
    words = get_forth_words()
    with open(to, 'w') as out:
        with open(fr, 'r') as inp:
            while True:
                line = inp.readline()
                if line == '': break
                if line.startswith('NN'):
                    ch = 'N'
                    data = line[2:-1]
                elif line == '\n':
                    ch = '\\n'
                    data = inp.readline()[1:-1]
                else:
                    ch, data = line[:-1].split('N')
                
                word = ''
                ip_val = int(data[4*1:4*2], 16)
                if ip_val in words:
                    word = words[ip_val]
                    if len(word) > 10:
                        word = word[:9]+'>'

                out.write(f"{ch:3} | {word:10} {get_vars(data)}\n")


FROM = sys.argv[1]
convert(FROM, TO)
