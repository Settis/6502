    INCDIR "std"
    INCLUDE "in_ram.asm"
    
    RTI

    INCLUDE "display.asm"


debug_start:
reset_start:
start:

; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$F3
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%11001100
    STA VIA_FIRST_PCR

    LDA #%00100000
    STA DISPLAY_PCR_MASK

; Init display 2
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR

    ; LDA #%00110000
    ; JSR WRITE_TO_DISPLAY

    JSR INIT_DISPLAY

    LDA #"!"
    JSR PRINT_CHAR

    LDA #"3"
    JSR PRINT_CHAR

    DC $FF
    