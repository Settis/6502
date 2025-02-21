# FORTH NFA all name's high bit is 0

Status: accepted

## Context

The NFA section consists of the first byte with name length & flags, and ascii name.
The last character in the name has a 7th bit set into 1.
The first byte of the NFA section has a 7th bit set to 1 too.
So, the high bit of the first and last bytes in the NFA is 1, but the high bit of all bytes in the middle is set to 0.
Knowing that you can traverse the NFA section from the start to the end and back.
But during a search in a dictionary, the high bit should be ignored, which creates unneeded complications.

## Decision

Only the first byte will have the high bit set to 1.
The name will be presented in NFA as is.
This allows us to check if names are equal easily.
This data structure still can be traversed.
From the end to the beginning, it can be traversed as usual.
From the beginning we can extract the exact name length from the first bit without the need for a high bit check.

## Consequences
