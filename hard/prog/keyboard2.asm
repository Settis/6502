    INCDIR "std"
    INCLUDE "std.asm"

start:
; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Disable latch
    LDA #$00
    STA VIA_FIRST_ACR

; Setup port directions
    LDA #$00
    STA VIA_FIRST_DDRA

    LDA VIA_FIRST_RA
    STA $03

    RESET_VECTOR start, start, start
