# Use atari binary format

Status: accepted

## Context

Because DASM does not support W65C816 CPU I switched to ca65.
In DASM I used the default output format where ROM data were prefixed with the origin address.
ca65 does not have such an output option.

I can either: 
- replicate DASM output format with cc65 toolchain
- use simple raw ROM format without any headers
- use Atari format provided by cc65 toolchain

## Decision
Using Atari format.
It's supported in cc65 out of the box.
I don't have to invent anything else to keep tracking where the origin is.

## Consequences
I have to rewrite my toolchain for program loading.
