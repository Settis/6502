DISPLAY_ADDR = $01
DISPLAY_STRING_ADDR = $03
DISPLAY_TMP = $05
DISPLAY_DDR = $09

STEPS = 1

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
    LDA #1
    STA DELAY_Y
    LDA #1
    STA DELAY_X
    JSR delayxy
    RTS

delay_37:
    LDA #1
    STA DELAY_Y
    LDA #1
    STA DELAY_X
    JSR delayxy
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
    STA (DISPLAY_ADDR,X)
    JSR delay_4.1
    STA (DISPLAY_ADDR,X)
    JSR delay_100
    STA (DISPLAY_ADDR,X)
    JSR delay_37

; first part of 4-bit mode
    LDA #%00100000
    STA (DISPLAY_ADDR,X)
    JSR delay_37

; 4-bit mode command
    LDA #%00100000
    STA (DISPLAY_ADDR,X)
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    JSR delay_37

; Display ON
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%11100000
    STA (DISPLAY_ADDR,X)
    JSR delay_37

; Clear display
    JSR CLEAR_DISPLAY

; Entry mode set
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    LDA #%01100000
    STA (DISPLAY_ADDR,X)
    JSR delay_37

    RTS

CLEAR_DISPLAY:
    LDA #%00000000
    STA (DISPLAY_ADDR,X)
    JSR delay_4.1
    LDA #%00010000
    STA (DISPLAY_ADDR,X)
    JSR delay_4.1
    JSR delay_4.1
    JSR delay_4.1
    JSR delay_4.1
    JSR delay_4.1
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
    JSR delay_37
    RTS

; WAIT_IF_BUSY:
;     ; Set bit 7 as input
;     LDA #$03
;     STA (DISPLAY_DDR,X)

;     ; This depends on the port


; wait_loop:
;     LDA #$02
;     STA (DISPLAY_ADDR,X)
;     LDA (DISPLAY_ADDR,X)  
;     AND #$80
;     BNE wait_loop
;     LDA #$F3
;     STA (DISPLAY_DDR,X)
;     RTS
