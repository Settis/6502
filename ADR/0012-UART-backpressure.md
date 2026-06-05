# UART chip flow control lines changes

Status: accepted

## Context

According to the specs, the RTS line from the W65C51 should be connected to the CTS line on another device.
Unfortunately, there is a bug in W65C51, and while the RTS line is activated, the chip stops sending data to the device.

## Decision

Use the DTR line on W65C51 instead of RTS.
Though the line is designed for other purposes, I can control it independently.
And, luckily, changing the signal on the line doesn't affect data sent from W65C51.

## Consequnces

It may be confusing that now DTR and RTS are swapped physically, but not in the code.
In order to change what should be RTS according to the specs, the 6502 code would work with DTR instead.
