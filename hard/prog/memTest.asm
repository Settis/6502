    INCDIR "std"
    INCLUDE "in_ram.asm"

MEM = $00
DATA = $45F7

debug_start:
reset_start:
start:
    WRITE_WORD DATA, MEM
 
    DC $FF

