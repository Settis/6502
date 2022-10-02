    PROCESSOR 6502
    ORG $0A00

    SED
    LDX A
    LDA #0
    CLC
loop: ; loop for adding
    ADC B
    DEX
    bne loop
    STA R
    CLD
    
    RTS

A:  DC 7
B:  DC 6
R:  DC 0
