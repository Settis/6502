#!/bin/bash
set -e

cl65 src/testAtariWriter.a65 \
 --obj-path lib \
 --obj uart.o \
 --obj delay.o \
 --obj uartDebugMsg.o \
 --obj atariWriter.o \
 --no-target-lib \
 -C uart.conf -m map.txt

uart6502 write -f src/testAtariWriter
uart6502 run 200
