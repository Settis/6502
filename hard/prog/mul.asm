    PROCESSOR 6502

FIRST equ 7
SECOND equ 7

firstPos equ 1
secondPos equ 2
resultPos equ 3

accPos equ 5
decPos equ 6

    ORG $8000

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
    ;jmp loop
end:
    STA resultPos

    org $FFFC
    DC.W $8000