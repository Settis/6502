# UART chip bug workaround

Status: accepted

## Context

Swapping DTR and RTS lines reveals another hardware bug.
When I setup that the data terminal is not ready, the terminal transfers bytes, and receive bytes.
Unfortunately, it stopped generating interrupts.

## Decision

Luckily, the DTR line is used as RTS and should stop the connected device from sending data.
Ideally, the other device should send no more than one byte after the RTS line is switched.
Even though the interrupt was not generated, chip status flags are updated accordingly.
Before allowing the other device sending data, 6502 should check flags and handle the received byte.

## Consequences
