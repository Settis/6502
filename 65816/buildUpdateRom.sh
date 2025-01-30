#!/bin/bash
set -e

cl65 src/updateRom.a65 \
 --obj-path lib \
 --obj uart.o \
 --obj delay.o \
 --obj uartDebugMsg.o \
 --obj atariWriter.o \
 --no-target-lib \
 -C uart.conf -m map.txt \
 -o /tmp/a.out

uart6502 write -f /tmp/a.out
uart6502 run 200
