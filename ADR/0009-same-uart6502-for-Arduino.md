# Using the same uart6502 script for Arduino

Status: accepted

## Context
Historically, I started with an Arduino board connected to the bus.
The board emulates missing devices.
Then it was used for step-by-step debugging.
Unfortunately, it was too slow for PS2 keyboard and I stopped using it.

Currently, 6502 runs the UART monitor and executes commands from the laptop.
For communication I’ve created yet another Python script with it’s own protocol and command line arguments.

So I have two UART connected devices: 6502 uart monitor and Arduino.
And two Python scripts accordingly.

## Decision
Extend the currently used uart6502 to work with debug commands.
So I can use the same tool and the same protocol across all devices.

## Consequences
Not all commands can be supported on both devices.
So far, I’ll try to be careful.
But in case of heavily using both devices I have to change the protocol to indicate that some commands are not supported.
Or extend it with the command that reports the device type.

The UART monitor and Arduino react to the UART connection differently.
See ADR-0010.
