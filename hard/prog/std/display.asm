DISPLAY_ADDR = $01
DISPLAY_STRING_ADDR = $03
DISPLAY_TMP = $05
DISPLAY_DDR = $09

    INCLUDE "delay.asm"

INIT_DISPLAY:
    LDX #$0

; 3 times first part of 8-bit mode
    LDA #%00110000
    ;STA (DISPLAY_ADDR,X)
    ; JSR delay
    ;STA (DISPLAY_ADDR,X)
    ; JSR delay
    ;STA (DISPLAY_ADDR,X)
    ; JSR delay

; first part of 4-bit mode
    LDA #%00100000
    STA (DISPLAY_ADDR,X)
    ; JSR delay

; 4-bit mode command
    LDA #%00100000
    STA (DISPLAY_ADDR,X)
    ; JSR delay
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    ; JSR delay

; Display ON
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    ; JSR delay
    LDA #%11100000
    STA (DISPLAY_ADDR,X)
    ; JSR delay

; Clear display
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    ; JSR delay
    LDA #%00010000
    STA (DISPLAY_ADDR,X)
    ; JSR delay

; Entry mode set
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    ; JSR delay
    LDA #%01100000
    STA (DISPLAY_ADDR,X)
    ; JSR delay

    RTS

PRINT_STRING:
    LDY #$0
    LDX #$0

PS_LOOP:
    LDA (DISPLAY_STRING_ADDR),Y
    BEQ PS_END
    JSR PRINT_CHAR
    INY
    JMP PS_LOOP

PS_END:
    RTS

PRINT_CHAR:
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
    ; JSR delay
    RTS

; WAIT_IF_BUSY:
;     ; Set bit 7 as input
;     LDA #$03
;     STA (DISPLAY_DDR,X)
;     LDA #$02
;     STA (DISPLAY_ADDR,X)
; ;wait_loop:
;     LDA (DISPLAY_ADDR,X)
;     LDA #$02
;     STA (DISPLAY_ADDR,X)
;     LDA (DISPLAY_ADDR,X)
; ;    AND #$80
; ;    BNE wait_loop
;     LDA #$F3
;     STA (DISPLAY_DDR,X)
;     RTS
