    SEG.U zpVars
CRC_SUM ds 1

    SEG code

; Uses X
CRC_A:
    subroutine
    EOR CRC_SUM
    STA CRC_SUM
    TXA
    PHA
    LDA CRC_SUM
    LDX #8
.loop
    ASL
    BCC .next
    EOR #$07
.next
    DEX
    BNE .loop
    STA CRC_SUM
    PLA
    TAX
    RTS
