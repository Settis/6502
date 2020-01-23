#!/bin/bash

../dasm/dasm $1 -v4 -f3
./convert.py
