    PROCESSOR 6502
    INCLUDE "../std/std.asm"

    SEG code

start:
    LDA #$0
    STA VIA_FIRST_IFR
    LDA #$0
    STA VIA_FIRST_ACR
    LDA #%11000000
    STA VIA_FIRST_IER
    CLI
    LDA #$00
    STA VIA_FIRST_T1C_L
    LDA #$0F
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
