    INCDIR "std"
    INCLUDE "std.asm"
    ORG $200
    INCLUDE "display.asm"


wdc_srt: STRING "WDC 6502!"

main:
; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup handshakes
    LDA #%11001100
    STA VIA_FIRST_PCR

    LDA #%00100000
    STA DISPLAY_PCR_MASK

; Init display 2
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RA, DISPLAY_ADDR
    WRITE_WORD VIA_FIRST_DDRA, DISPLAY_DDR
    LDA #%00100010
    STA DISPLAY_PCR_MASK
    JSR INIT_DISPLAY

    WRITE_WORD wdc_srt, DISPLAY_STRING_ADDR
    JSR PRINT_STRING   

    ; JSR CLEAR_DISPLAY
    
    ; LDA #"!"
    ; JSR PRINT_CHAR

    ; LDA #"3"
    ; JSR PRINT_CHAR

    RTS
    