# Protocol

## Ping
Command number: **1**

PC sends to 6502 the command ID and a random number from 1 to 200.
The 6502 must return the number incremented by 1.

*Example:*
> **PC -> 6502:** 0x01 0x0A
> 
> **6502 -> PC:** 0x0B

## Write data
Command number: **2**

PC sends to 6502 the command ID, starting address (2 bytes, little endian), length of data (1 byte), and the actual data.
The 6502 will return CRC8 (0x07) checksum of the data.

*Example:*

> **PC -> 6502:** 0x02 0x02 0x05 0x09 "123456789"
>
> **6502 -> PC:** 0xF4

## Read data
Command number: 3

PC sends to 6502 the command ID, starting address (2 bytes, little endian), length of data (1 byte).
The 6502 will return the data and CRC8 sum.

*Example:*

> **PC -> 6502:** 0x3 0x02 0x05 0x09
> 
> **6502 -> PC:** "123456789" 0xF4

## Run subroutine
Command number: 4

PC sends to 6502 the command ID and subroutine address (2 bytes, little endian).
When 6502 is ended the subroutine it sends the command ID back.

*Example:*

> **PC -> 6502:** 0x4 0x00 0x03
> 
> **6502 -> PC:** 0x4

## Step debugger
Command number: 5

PC sends to 6502 the command ID, mode, address, [data byte].

Stop by:
- address r/w
- read any
- write any
- read byte
- write byte
- report each step
- quiet

mode:
-  0x01 - any action to address
-  0x02 - check r/w direction
-  0x04 - match r/w pin
-  0x08 - check data byte
-  0x10 - quiet or send steps

The end byte is WDM opcode 0x42. It's reserved for future microporcessors and won't be used in assembly (I hope).

It should be zero terminated.

Output is the packets of 4 bytes, zero terminated
    (0x80 | r/w, byte, addr), {Opcode, addr, args size, [args], (0x80 | r/w, byte, addr)}, 0x00
    flags byte:
        0x80 - data is presented
        0x01 - r/w
        0x02 - vpa
        0x04 - vda
    data byte,
    addr (lo, hi)

*Example:*

> **PC -> 6502:** 0x5 0x1 0x00 0x03
> 
> **6502 -> PC:** 0
