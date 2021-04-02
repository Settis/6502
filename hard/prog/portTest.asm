    INCDIR "std"
    INCLUDE "std.asm"

PORT_ADDR = VIA_FIRST_RB

start:
; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$FF
    STA VIA_FIRST_DDRA
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%10101010
    STA VIA_FIRST_PCR

    LDA #$80
    STA PORT_ADDR

    LDA #$40
    STA PORT_ADDR

    LDA #$20
    STA PORT_ADDR

    LDA #$10
    STA PORT_ADDR

    LDA #$08
    STA PORT_ADDR

    LDA #$04
    STA PORT_ADDR

    LDA #$02
    STA PORT_ADDR

    LDA #$01
    STA PORT_ADDR

    
    RESET_VECTOR start, start, start
