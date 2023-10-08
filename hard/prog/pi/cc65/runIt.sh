#!/bin/bash

./build.sh
START=`grep "^STARTUP" map.txt | awk '{ print $2 }'`

uart6502 write
time uart6502 run $START

uart6502 read -o 900 -r | hexdump -C > result.txt

# echo "Array:"
# uart6502 read -o 1000 -s 20

# echo "Result:"
# uart6502 read -o 900 -s 10
