    INCDIR "std"
    INCLUDE "std.asm"
    ORG $200
    INCLUDE "display.asm"

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

    ; Set cursor to second line 3rd character
    LDA #%11000011
    JSR SEND_DISPLAY_COMMAND

    LDA #"1"
    JSR PRINT_CHAR

    ; Set cursor to first line 7th character
    LDA #%10000111
    JSR SEND_DISPLAY_COMMAND

    LDA #"5"
    JSR PRINT_CHAR

    RTS
    