DISPLAY_ADDR = $01
DISPLAY_STRING_ADDR = $03
DISPLAY_TMP = $05
DISPLAY_PCR = $09
DISPLAY_PCR_MASK = $0B ; 0C
DISPLAY_DDR = $0D; 0E
DISPLAY_REGISTER = $0F


    IFNCONST STEPS
STEPS = 0
    ENDIF

; Initial delay 50 ms
; Longer delay 1.52 ms
; other delay 37 µs

; 5 KHz = 200 µs
; 50 ms   => Y=1, X=250
; 1.52 ms => Y=1, X=7
; 4.1 ms  => Y=1, X=20

; 6 MHz = 0.16 µs
; 50 ms   => (312500) Y=250, X=250 *5
; 4.1 ms  =>  (25625) Y=171, X=150
; 1.52 ms =>   (9500)  Y=95, X=100
; 100 µs  =>    (625)   Y=5, X=125
; 37 µs   =>    (231)   Y=1, X=230

    INCLUDE "delay.asm"

 if STEPS = 1
delay_10:
    RTS

delay_4_1:
    delay 20, 1
    RTS

delay_1_52:
    delay 7, 1
    RTS

delay_100:
    RTS

delay_37:
    RTS

 else
delay_10:
    delay 250, 250
    RTS

delay_4_1:
    delay 150, 171
    RTS

delay_1_52:
    delay 100, 95
    RTS

delay_100:
    delay 125, 5
    RTS

delay_37:
    delay 230, 1
    RTS
 endif

INIT_DISPLAY:
; wait 50ms
    JSR delay_10
    JSR delay_10
    JSR delay_10
    JSR delay_10
    JSR delay_10

    LDX #$0
    LDA #$F3
    STA (DISPLAY_DDR,X)

; 3 times first part of 8-bit mode
    LDA #%00110000
    JSR WRITE_4_BYTES_TO_DISPLAY
    JSR delay_4_1
    LDA #%00110000
    JSR WRITE_4_BYTES_TO_DISPLAY
    JSR delay_4_1
    LDA #%00110000
    JSR WRITE_4_BYTES_TO_DISPLAY
    JSR delay_100

; first part of 4-bit mode
    LDA #%00100000
    JSR WRITE_4_BYTES_TO_DISPLAY

; 4-bit mode command
    ; 00100000 - command
    ; 00010000 - 8-bit mode
    ; 00001000 - 2 lines
    ; 00000100 - font
    ; LDA #%00100000
    ; JSR WRITE_4_BYTES_TO_DISPLAY
    ; LDA #%11000000
    ; JSR WRITE_4_BYTES_TO_DISPLAY

    LDA #%00101100
    JSR SEND_DISPLAY_COMMAND

; Display ON
    ; 00001000 - command
    ; 00000100 - ON/OFF flag
    ; 00000010 - cursor ON/OFF
    ; 00000001 - blinking ON/OFF
    ; LDA #%00000000
    ; JSR WRITE_4_BYTES_TO_DISPLAY
    ; LDA #%11110000
    ; JSR WRITE_4_BYTES_TO_DISPLAY

    LDA #%00001111
    JSR SEND_DISPLAY_COMMAND

; Clear display
    JSR CLEAR_DISPLAY

; Entry mode set
    ; 00000100 - command
    ; 00000010 - increment cursor move
    ; 00000001 - display shift
    ; LDA #%00000000
    ; JSR WRITE_4_BYTES_TO_DISPLAY
    ; LDA #%01100000
    ; JSR WRITE_4_BYTES_TO_DISPLAY

    LDA #%00000110
    JSR SEND_DISPLAY_COMMAND

    RTS

CLEAR_DISPLAY:
    ; LDA #%00000000
    ; JSR WRITE_4_BYTES_TO_DISPLAY
    ; LDA #%00010000
    ; JSR WRITE_4_BYTES_TO_DISPLAY

    LDA #%00000001
    JSR SEND_DISPLAY_COMMAND
    JSR delay_1_52
    RTS

DISPLAY_CHANGE_LINE:
    ; Load cursor position
    JSR READ_FROM_DISPLAY

    AND #$40
    EOR #$40
    ORA #$80
    ; 10000000 - command
    ; 40H address for second line
    JSR SEND_DISPLAY_COMMAND
    RTS

    subroutine
PRINT_STRING:
    LDY #$0
    LDX #$0

.PS_LOOP:
    LDA (DISPLAY_STRING_ADDR),Y
    BEQ .PS_END
    JSR PRINT_CHAR
    INY
    JMP .PS_LOOP

.PS_END:
    RTS
    subroutine

PRINT_CHAR:
    STA DISPLAY_TMP
    LDA #$01
    STA DISPLAY_REGISTER
    JSR WRITE_TO_DISPLAY
    RTS

SEND_DISPLAY_COMMAND:
    STA DISPLAY_TMP
    LDA #$00
    STA DISPLAY_REGISTER
    JSR WRITE_TO_DISPLAY
    RTS

WRITE_TO_DISPLAY:
    LDX #0
    LDA DISPLAY_TMP
    AND #$F0
    ORA DISPLAY_REGISTER
    JSR WRITE_4_BYTES_TO_DISPLAY
    LDA DISPLAY_TMP
    ROL
    ROL
    ROL
    ROL
    AND #$F0
    ORA DISPLAY_REGISTER
    JSR WRITE_4_BYTES_TO_DISPLAY
    RTS

READ_FROM_DISPLAY:
    ; Set port to input
    LDX #$0
    LDA #$03
    STA (DISPLAY_DDR,X)

    ; Send to display read from RS
    LDA #$02
    STA (DISPLAY_ADDR,X)

    JSR READ_4_BYTES_FROM_DISPLAY

    STA DISPLAY_TMP

    JSR READ_4_BYTES_FROM_DISPLAY

    CLC
    ROR
    ROR
    ROR
    ROR
    ORA DISPLAY_TMP
    STA DISPLAY_TMP

    ; Set port to output
    LDX #$0
    LDA #$F3
    STA (DISPLAY_DDR,X)

    ; Load data back to A
    LDA DISPLAY_TMP
    RTS

WRITE_4_BYTES_TO_DISPLAY:
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

; Return 4 upper bytes in A
READ_4_BYTES_FROM_DISPLAY:
    ; Invert Enable
    LDA (DISPLAY_PCR,X)
    EOR DISPLAY_PCR_MASK
    STA (DISPLAY_PCR,X)
    ; enable pulse must be >450ns
    NOP
    NOP
    ; Load upper bits
    LDA (DISPLAY_ADDR,X)
    AND #$F0
    PHA
    ; Invert Enable
    LDA (DISPLAY_PCR,X)
    EOR DISPLAY_PCR_MASK
    STA (DISPLAY_PCR,X)
    ; commands need > 37us to settle
    JSR delay_37
    PLA
    RTS
