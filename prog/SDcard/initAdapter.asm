UPPER_RAM_START = $7D00
    INCLUDE "../std/std.asm"

    SEG code
main:
    ; Setup output pins
    LDA #%01110000
    STA VIA_FIRST_DDRB
    LDA #2
    STA VIA_FIRST_T2C_L
    ; CS = DI = HIGH
    LDA #%11100000
    STA VIA_FIRST_RB
    LDA #%00000100
    STA VIA_FIRST_ACR
    LDA VIA_FIRST_SR
    RTS
