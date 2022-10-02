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

PC sends to 6502 the command ID, starting address (2 bytes), length of data (1 byte), and the actual data.
The 6502 will return CRC8 (0x07) checksum of the data.

*Example:*

> **PC -> 6502:** 0x02 0x02 0x05 0x09 "123456789"
>
> **6502 -> PC:** 0xF4

## Read data
Command number: 3

PC sends to 6502 the command ID, starting address (2 bytes), length of data (1 byte).
The 6502 will return the data and CRC8 sum.

*Example:*

> **PC -> 6502:** 0x3 0x02 0x05 0x09
> 
> **6502 -> PC:** "123456789" 0xF4

## Run subroutine
Command number: 4

PC sends to 6502 the command ID and subroutine address (2 bytes).
When 6502 is ended the subroutine it sends the command ID back.

*Example:*

> **PC -> 6502:** 0x4 0x03 0x00
> 
> **6502 -> PC:** 0x4

