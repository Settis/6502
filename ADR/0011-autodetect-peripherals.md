# Peripherals board should be autodetected

Status: accepted

## Context
Current FORTH implementation initialize display.
Before sending a command to display it checks its busy state.

Most often I want to connect to 6502 via UART only wihtout display, keyboard, etc.
See ADR-0000.
But without peritherals connected, FORTH stuck infinitly waiting for display to answer.

## Decision
Create an ability to detect if the peritheral board is connected.

Connect P2 and P3 pins together on port B.
They are not used in the peripheral board.
6502 can write signal to P2 and read it back via P3, detecting the board.

## Conseqences

