# Allow 6502 to write ROM independently

Status: accepted

## Context
For updating the ROM I use Arduino board.
Arduino can control the clock and disconnect the CPU from the bus.
This allows to update the ROM content without taking the chip out of the board.
But in any case, I have to manipulate the hardware: take out the module with the clock generator and insert the Arduino connector.

For extra writing protection, EEPROM's WE line is not connected to WE line controlled by CPU.
EEPROM writing happens only during the "write" signal on WE as well as OE is disabled.
Since most of the time I need only read the OE pin is controlled by jumper.

There is software data protection in my EEPROM.
Unfortunately, I can't use it because unlocking sequence requires several writings to particular addresses.
Not all EEPROM's addresses are available to the CPU, because the A14 pin is controlled by jumper.
So I can work with software data protection in lower bank only.

## Decision
Connect EEPROM's WE line to CPU controlled WE line.
This allows to update EEPROM's content without connecting Arduino into the bus.
Meanwhile, OE pin will be controlled by jumber.
On one hand it's hardware data protection, on another hand CPU can't read bytes from the EEPROM, so it can't detect when the writing cycle will be over.
I have to implement writing logic based on timeouts.

## Consequences
