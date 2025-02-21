# Eliminate BASE in FORTH

Status: accepted

## Context

FORTH has the BASE variable.
Number literals and output behave according to the BASE.
So the same code can be executed differently depending on the BASE value.

## Decision

Do not use the BASE at all.
Number literal consisting of digits should be treated as a decimal number.
Hexadecimal numbers should start with '$' sign.
Dot word will output numbers in decimal.
For hexadecimal output, you should use 'H.'.

## Consequences

I'm changing the language conventions.
Existing programs written for standard FORTH will not work.
