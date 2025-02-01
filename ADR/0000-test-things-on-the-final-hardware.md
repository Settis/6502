# Test things as close to the final hardware as possible

Status: accepted

## Context

Sure thing I have to test the hardware and software.

When I started the project I put an Arduino into the bus and it was my in-circuit debugger.
On one hand, it was really useful allowing me to debug in step-by-step mode.
On the other hand, disconnecting the 6502 computer from Arduino to work on its own was painful.
Because Arduino pulled lines and initiated things, steps that I didn't replicate in my hardware.

Another example is my experiments with FORTH.
I started them in an emulator, but because the emulator didn't support timers I decided to switch it to the hardware.
Unfortunately, emulator's 65C51 worked correctly, but my hardware has a bug.
So I lost some time debugging this weird behavior.

## Decision

Do everything in the real hardware.
Even if it's hard to debug, I better should invent tools for debugging and testing with my hardware.

Create the initial ADR with this for not to forget.

Recently I started development with 65C816 features, that are not compatible with 6502.
Since there are lack of 65C816 emulators it will be easy to keep things working on my hardware.

## Consequences
