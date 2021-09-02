    PROCESSOR 6502
    INCDIR "std"
    INCLUDE "in_ram.asm"

    RTS

debug_start:
reset_start:
    LDA #$0
    LDX #$0
    CLC

loop:
    STA $0,X
    INX
    ADC #$1
    BCC loop

end_loop:
    JMP end_loop
