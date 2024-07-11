#!/bin/bash

# Compile and run

set -e

dasm $1 -f3 -llist.txt
java -Dsun.java2d.uiScale=2.0 -jar ~/Downloads/symon-1.4.0.jar -r a.out -b
