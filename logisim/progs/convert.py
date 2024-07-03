#!/usr/bin/python

binary = []
with open('a.out', 'rb') as outFile:
    binary = list(outFile.read())

with open('a.rom', 'w') as rom:
    rom.write('v2.0 raw\n')
    i = 0
    for byte in binary:
        rom.write("%02x " % byte)
        i+=1
        if i == 8:
            rom.write('\n')
            i = 0

