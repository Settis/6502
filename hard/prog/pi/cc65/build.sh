#!/bin/bash

cc65 -Os pi.c
ca65 pi.s
cl65 -m map.txt -C uartMon.cfg pi.o uartMon.lib

echo -n -e "\x00\x02" > a.out
cat pi >> a.out
grep "^STARTUP" map.txt
