    INCDIR "std"
    INCLUDE "std.asm"

MEM = $00
DATA = $45F7

start:
    WRITE_WORD DATA, MEM

    RESET_VECTOR start, start, start
