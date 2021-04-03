    PROCESSOR 6502
    INCDIR "std"
    INCLUDE "std.asm"

start:
    LDA #$0
    STA VIA_FIRST_IFR
    LDA #$0
    STA VIA_FIRST_ACR
    LDA #%11000000
    STA VIA_FIRST_IER
    CLI
    LDA #$40
    STA VIA_FIRST_T1C_L
    LDA #$0
    STA VIA_FIRST_T1C_H

loop:
    INC $2
    JMP loop

IRQ:
    LDA #$3
    STA $3
    JMP end

NMI:
    LDA #$5
    STA $3

end:
    LDX #0

    RESET_VECTOR start, IRQ, NMI
