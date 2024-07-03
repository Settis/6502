    INCLUDE "../std/std.asm"

    .org $0200

; RTS connected to port B
; Pin 7 - DATA
; Pin 6 - Clock
; Pin 4 - RST / CS

    SEG.U zpVars
command ds 1
argument ds 1

    SEG code

main:
    JSR init
    JSR setupTime
    JSR readTime
    RTS

init:
    ; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER
    ; Setup output pins
    LDA #%11010000
    STA VIA_FIRST_DDRB
    ; Disable RTS
    LDA #$0
    STA VIA_FIRST_RB
    RTS

setupTime:
    ; Disable WP
    LDA #$8E
    STA command
    LDA #$0
    STA argument
    JSR write

    ; Year
    LDA #$8C
    STA command
    LDA #$23
    STA argument
    JSR write

    ; Day of week
    LDA #$8A
    STA command
    LDA #$6
    STA argument
    JSR write

    ; Month
    LDA #$88
    STA command
    LDA #$2
    STA argument
    JSR write

    ; Date
    LDA #$86
    STA command
    LDA #$4
    STA argument
    JSR write

    ; Hour
    LDA #$84
    STA command
    LDA #$15
    STA argument
    JSR write

    ; Minutes
    LDA #$82
    STA command
    LDA #$11
    STA argument
    JSR write

    ; Seconds
    LDA #$80
    STA command
    LDA #$0
    STA argument
    JSR write

    ; Enable WP
    LDA #$8E
    STA command
    LDA #$80
    STA argument
    JSR write
    RTS

readTime:
    ; Year
    LDA #$8D
    STA command
    JSR read
    LDA argument
    STA $10

    ; Day of week
    LDA #$8B
    STA command
    JSR read
    LDA argument
    STA $11

    ; Month
    LDA #$89
    STA command
    JSR read
    LDA argument
    STA $12

    ; Date
    LDA #$87
    STA command
    JSR read
    LDA argument
    STA $13

    ; Hour
    LDA #$85
    STA command
    JSR read
    LDA argument
    STA $14

    ; Minutes
    LDA #$83
    STA command
    JSR read
    LDA argument
    STA $15

    ; Seconds
    LDA #$81
    STA command
    JSR read
    LDA argument
    STA $16

    RTS

read_tcr:
    LDA #$91
    STA command
    JSR read
    RTS

read:
    JSR sendCommand
    subroutine
    ; Switch to reading
    LDA #%01010000
    STA VIA_FIRST_DDRB

    LDY #$8
.argumentLoop:
    LDA VIA_FIRST_RB
    ROL 
    ROR argument
    ; Clock ON
    LDA #%01010000
    STA VIA_FIRST_RB
    ; Clock OFF
    AND #%00010000
    STA VIA_FIRST_RB
    DEY
    BNE .argumentLoop

    ; Shut off RTS
    LDA #%11010000
    STA VIA_FIRST_DDRB
    LDA #$0
    STA VIA_FIRST_RB
    RTS

write:
    JSR sendCommand
    LDA argument
    STA command
    JSR sendCommand
    ; Shut off RTS
    LDA #$0
    STA VIA_FIRST_RB
    RTS

sendCommand:
    subroutine
    ; Enable CS
    LDA #%00010000
    STA VIA_FIRST_RB

    LDY #$8
.commandLoop:
    ROR command
    LDA #%00100000
    ROR
    STA VIA_FIRST_RB
    ; Clock ON
    ORA #%01000000
    STA VIA_FIRST_RB
    ; Clock OFF
    AND #%10010000
    STA VIA_FIRST_RB
    DEY
    BNE .commandLoop
    RTS
