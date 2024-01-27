    INCDIR "std"
    INCLUDE "std.asm"
    INCLUDE "display.asm"

home_made_srt:
    DC "Home made comp", 0

wdc_srt:
    DC "WDC 6502", 0

start:
; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$F3
    STA VIA_FIRST_DDRA
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%10101010
    STA VIA_FIRST_PCR

; Init display 1
    WRITE_WORD VIA_FIRST_RA, DISPLAY_ADDR
    JSR INIT_DISPLAY

; Init display 2
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    JSR INIT_DISPLAY

    WRITE_WORD VIA_FIRST_RA, DISPLAY_ADDR
    WRITE_WORD home_made_srt, DISPLAY_STRING_ADDR
    JSR PRINT_STRING

    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    WRITE_WORD wdc_srt, DISPLAY_STRING_ADDR
    JSR PRINT_STRING   
    
    RESET_VECTOR start, start, start
