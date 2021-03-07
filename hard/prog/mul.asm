    PROCESSOR 6502

FIRST equ 7
SECOND equ 7

STP = $DB

firstPos equ 1
secondPos equ 2
resultPos equ 3

    ORG $8000

    CLI

    ; initial
    LDA #FIRST
    STA firstPos
    LDA #SECOND
    STA secondPos

    ; multiply
    LDX firstPos
    LDA #0
    CLC
loop: ; loop for adding
    ADC secondPos
    DEX
    bne loop
    STA resultPos

;    DC STP

    org $FFFC
    DC.W $8000
