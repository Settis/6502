    ORG $FD00
    INCDIR "std"
    INCLUDE "std.asm"

    INCLUDE "display.asm"

debug_start:
reset_start:
    LDX #$00
    TXS
; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$F3
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%11000001
    STA VIA_FIRST_PCR

; Init display on port B
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    LDA #%00100000
    STA DISPLAY_PCR_MASK
    JSR INIT_DISPLAY

    LDA #">"
    JSR PRINT_CHAR

main_loop:
    LDA #$FF
    STA DELAY_Y
    LDA #$FF
    STA DELAY_X
    JSR delayxy
    LDA #"Y"
    JSR PRINT_CHAR
    JMP main_loop

    RESET_VECTOR reset_start, debug_start, debug_start