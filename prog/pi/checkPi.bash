#!/bin/bash
set -e

dasm pi.asm
uart6502 write
time uart6502 run 200
uart6502 read -o 900 -r | hexdump -C > result.txt
