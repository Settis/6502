# UART monitor should send data with the right timing

Status: accepted

## Context
UART chip W65C51 has a bug in interrupt logic.
I can't detect by interrupt when the byte is sent out.
Luckily interrupt of incoming byte works.

To make the UART monitor simple I decided to send only one byte at once.
If 6502 logically has to send several bytes, like when I read memory, it sends only one byte and waits for ack from a laptop.
I do not have to care about timing, but this is slow.

## Decision
I'll change the protocol, so 6502 can send subsequent bytes independently without requesting information byte-by-byte.

## Consequences
