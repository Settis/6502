# FORTH reusage of line input buffer for files

Status: accepted

## Context

FORTH-83 uses a line input buffer to collect a line from user input.
FORTH files have fixed line length and a disk block contains an integer number of lines.
Lines read from a file can be directly executed from the block.
I want to use a modern text file format with lines ending with '\n'.
Those lines can't be executed from the memory-mapped block.

## Decision

Reuse the line input buffer for working with files too.
Before execution a line will be copied from the disk block into the buffer.
In case the line starts in one block but ends in another, it will be correctly collected in the buffer.

## Consequences

It will be impossible to have something after the "import <file>" command because the import execution overwrites this line buffer.
