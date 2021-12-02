DISPLAY_ADDR = $01
DISPLAY_STRING_ADDR = $03
DISPLAY_TMP = $05
DISPLAY_PCR = $09
DISPLAY_PCR_MASK = $0B

STEPS = 0

; Longer delay 1.52 ms
; other delay 37 µs

; 5 KHz = 200 µs
; 1.52 ms => Y=1, X=7
; 4.1 ms  => Y=1, X=20

; 6 MHz = 0.16 µs
; 4.1 ms  => (25625) Y=171, X=150
; 1.52 ms =>  (9500)  Y=95, X=100
; 100 µs  =>   (625)   Y=5, X=125
; 37 µs   =>   (231)   Y=1, X=230

    INCLUDE "delay.asm"

 if STEPS = 1
delay_4.1:
    LDA #1
    STA DELAY_Y
    LDA #20
    STA DELAY_X
    JSR delayxy
    RTS

delay_1.52:
    LDA #1
    STA DELAY_Y
    LDA #7
    STA DELAY_X
    JSR delayxy
    RTS

delay_100:
    RTS

delay_37:
    RTS

 else
delay_4.1:
    LDA #171
    STA DELAY_Y
    LDA #150
    STA DELAY_X
    JSR delayxy
    RTS

delay_1.52:
    LDA #95
    STA DELAY_Y
    LDA #100
    STA DELAY_X
    JSR delayxy
    RTS

delay_100:
    LDA #5
    STA DELAY_Y
    LDA #125
    STA DELAY_X
    JSR delayxy
    RTS

delay_37:
    LDA #1
    STA DELAY_Y
    LDA #230
    STA DELAY_X
    JSR delayxy
    RTS
 endif

INIT_DISPLAY:
    LDX #$0

; 3 times first part of 8-bit mode
    LDA #%00110000
    JSR WRITE_TO_DISPLAY
    JSR delay_4.1
    JSR WRITE_TO_DISPLAY
    JSR delay_100
    JSR WRITE_TO_DISPLAY

; first part of 4-bit mode
    LDA #%00100000
    JSR WRITE_TO_DISPLAY

; 4-bit mode command
    LDA #%00100000
    JSR WRITE_TO_DISPLAY
    LDA #%00000000
    JSR WRITE_TO_DISPLAY

; Display ON
    LDA #%00000000
    JSR WRITE_TO_DISPLAY
    LDA #%11100000
    JSR WRITE_TO_DISPLAY

; Clear display
    JSR CLEAR_DISPLAY

; Entry mode set
    LDA #%00000000
    JSR WRITE_TO_DISPLAY
    LDA #%01100000
    JSR WRITE_TO_DISPLAY

    RTS

CLEAR_DISPLAY:
    LDA #%00000000
    JSR WRITE_TO_DISPLAY
    LDA #%00010000
    JSR WRITE_TO_DISPLAY
    JSR delay_1.52
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
    LDX #0
    STA DISPLAY_TMP
    AND #$F0
    ORA #$01
    JSR WRITE_TO_DISPLAY
    LDA DISPLAY_TMP
    ROL
    ROL
    ROL
    ROL
    AND #$F0
    ORA #$01
    JSR WRITE_TO_DISPLAY
    RTS

WRITE_TO_DISPLAY:
    ; Write data to port
    STA (DISPLAY_ADDR,X)
    ; Invert Enable
    LDA (DISPLAY_PCR,X)
    EOR DISPLAY_PCR_MASK
    STA (DISPLAY_PCR,X)
    ; enable pulse must be >450ns
    NOP
    NOP
    ; Invert Enable
    EOR DISPLAY_PCR_MASK
    STA (DISPLAY_PCR,X)
    ; commands need > 37us to settle
    JSR delay_37
    RTS
