# Disable Arduino autoreboot

Status: accepted

## Context
By default the Arduino board reboots each time the laptop establishes a connection to it.
It's useful for access Arduino bootloader and updating the firmware.

The UART monitor expects a connection per command.

When uart6502 connects to the Arduino, it reboots.
The whole Arduino is unrechible for some time, and some bytes sended via UART are lost.
Arduino reboot sequence changnes levels on GPIO, which cause some unpredictable 6502 reaction, line another clock cycle, memory write, etc.

## Decision
Restrict Arduino reboot by adding a capacitor between RST and GND.
The capacitor smooths out short reboot pulses during UART connection.
But a manual (button-press) reboot is long enough to discharge the capacitor.

The capacitor should be added to the display shield.
It would prevent reboots during debugging.
But I can easily disconnect the shield with the capacitor in case of updating the Arduino firmware.

## Conseqences
