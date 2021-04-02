    INCDIR "std"
    INCLUDE "std.asm"
    INCLUDE "display.asm"

home_made_srt:
    DC "Home made comp", 0

wdc_srt:
    ; DC "WDC 6502", 0
    DC %11101010
    DC %00100010
    DC %11000010
    DC %00000100
    DC %01101100
    DC %10101100
    DC %00001100
    DC %01001100
    DC 0

INIT_DISPLAY_2:
    LDX #$0

; 3 times first part of 8-bit mode
    LDA #%00000011
    STA (DISPLAY_ADDR,X)
    STA (DISPLAY_ADDR,X)
    STA (DISPLAY_ADDR,X)

; first part of 4-bit mode
    LDA #%00000100
    STA (DISPLAY_ADDR,X)

; 4-bit mode command
    LDA #%00000100
    STA (DISPLAY_ADDR,X)
    LDA #%00000000
    STA (DISPLAY_ADDR,X)

; Display ON
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%00000111
    STA (DISPLAY_ADDR,X)

; Clear display
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%00001000
    STA (DISPLAY_ADDR,X)

; Entry mode set
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%00000110
    STA (DISPLAY_ADDR,X)

    RTS

PRINT_STRING_2:
    LDY #$0
    LDX #$0

PS_LOOP_2:
    LDA (DISPLAY_STRING_ADDR),Y
    BEQ PS_END_2
    STA DISPLAY_TMP
    AND #$0F
    ORA #$80
    STA (DISPLAY_ADDR,X)
    LDA DISPLAY_TMP
    ROR
    ROR
    ROR
    ROR
    AND #$0F
    ORA #$80
    STA (DISPLAY_ADDR,X)
    INY
    JMP PS_LOOP_2

PS_END_2:
    RTS

start:
; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$F3
    STA VIA_FIRST_DDRA
    LDA #$CF
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%10101010
    STA VIA_FIRST_PCR

; Init display 1
    WRITE_WORD VIA_FIRST_RA, DISPLAY_ADDR
    JSR INIT_DISPLAY

; Init display 2
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    JSR INIT_DISPLAY_2

    WRITE_WORD VIA_FIRST_RA, DISPLAY_ADDR
    WRITE_WORD home_made_srt, DISPLAY_STRING_ADDR
    JSR PRINT_STRING

    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    WRITE_WORD wdc_srt, DISPLAY_STRING_ADDR
    JSR PRINT_STRING_2   
    
    RESET_VECTOR start, start, start
