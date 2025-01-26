#!/bin/bash
set -e

cl65 src/testDisplay.a65 \
 --obj-path lib/ \
 --obj charDisplay.o  \
 --obj delay.o \
 --obj uart.o \
 --obj uartDebugMsg.o \
 --no-target-lib \
 -C uart.conf -m map.txt

uart6502 write -f src/testDisplay
uart6502 run 200
