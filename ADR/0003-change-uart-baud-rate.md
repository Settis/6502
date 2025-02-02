# Increase uart baud rate

Status: accepted

## Context
I'm using 9600 baud rate for connecting to the 6502.
I've found that it is a kind of standard baud rate that guarantees a stable connection.
Recently I started sending and receiving a lot of data, so the low baud rate slows things down.

## Decision
Rise the baud rate up to 115200.
Hoping that it will increase my speed up to 12 times without introducing transfer errors due to short connecting wires.

## Consequences
