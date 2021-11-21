    INCDIR "std"
    INCLUDE "in_ram.asm"

    RTI

debug_start:
reset_start:
    LDA #$7F
    STA $03
    STA $13
    
    DC $FF
