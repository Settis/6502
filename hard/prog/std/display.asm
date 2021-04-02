DISPLAY_ADDR = $01
DISPLAY_STRING_ADDR = $03
DISPLAY_TMP = $05

INIT_DISPLAY:
    LDX #$0

; 3 times first part of 8-bit mode
    LDA #%00110000
    STA (DISPLAY_ADDR,X)
    STA (DISPLAY_ADDR,X)
    STA (DISPLAY_ADDR,X)

; first part of 4-bit mode
    LDA #%00100000
    STA (DISPLAY_ADDR,X)

; 4-bit mode command
    LDA #%00100000
    STA (DISPLAY_ADDR,X)
    LDA #%00000000
    STA (DISPLAY_ADDR,X)

; Display ON
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%11100000
    STA (DISPLAY_ADDR,X)

; Clear display
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%00010000
    STA (DISPLAY_ADDR,X)

; Entry mode set
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%01100000
    STA (DISPLAY_ADDR,X)

    RTS

PRINT_STRING:
    LDY #$0
    LDX #$0

PS_LOOP:
    LDA (DISPLAY_STRING_ADDR),Y
    BEQ PS_END
    STA DISPLAY_TMP
    AND #$F0
    ORA #$01
    STA (DISPLAY_ADDR,X)
    LDA DISPLAY_TMP
    ROL
    ROL
    ROL
    ROL
    AND #$F0
    ORA #$01
    STA (DISPLAY_ADDR,X)
    INY
    JMP PS_LOOP

PS_END:
    RTS