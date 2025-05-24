# FORTH input line ending with backslash

Status: accepted

## Context

User input is collected into the line input buffer.
At first glance, the line ends with 0x00, like a C-style string.
But one character with zero inside is a registered FORTH word, so ENCLOSE should find it at the end of the line.
The ENCLOSE extracts words between provided delimiters (usually space).
And for the "end of line" recognition, I have to wrap the zero character with spaces, or implement ENCLOSE in a way it can recognize zero.

## Decision

ENCLOSE should do simple and straightforward work: extract the word between delimiters.
So "DROP<0>" should be converted to "DROP <0> ".
FORTH has the '\' symbol, which specifies a comment till the end of the line.
Taking this into account, I can replace <0> with '\'.
For compilation and interpretation it doesn't matter if this backslash is an end-of-line marker or introduces a comment that should be ignored.
In both cases FORTH can move to the next line.

## Consequences

It will be impossible to print the line having a comment.
For example if a program is executed from a file and an error occurs, for debug purposes it will be good to print the whole line containing the error.
If this line has a comment it will be printed without it.
