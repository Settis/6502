    ALLOC ASCII_FIRST ;= $20
    ALLOC ASCII_SECOND ;= $21

HEX_TO_ASCII:
    PHA
    AND #$0F
    JSR HEX_4_BIT_TO_ASCII
    STA ASCII_SECOND
    PLA
    ROR
    ROR
    ROR
    ROR
    AND #$0F
    JSR HEX_4_BIT_TO_ASCII
    STA ASCII_FIRST
    RTS

HEX_4_BIT_TO_ASCII:
    subroutine
    CMP #10
    BCS .use_letters
    ADC #"0"
    RTS
.use_letters:
    CLC
    SBC #10
    ADC #"A"
    RTS
