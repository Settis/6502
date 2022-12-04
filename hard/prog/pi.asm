    PROCESSOR 6502

    .org $0200

ARRAY_ADDR = $1000
RESULT_ADDR = $1080

; ZP vars
PREV_DIGIT = $00
NINE_COUNT = $01
PRINTED = $02
MUL_1 = $03
MUL_2 = $04

DIV_1 = $05
DIV_2 = $06
DIV_CEIL = $07

CARRY = $08

DIGIT_FROM_CARRY = $09
NEXT_DIGIT = $0A

; CONST
TO_PRINT = $0A

main:
    ; Init vars
    LDA #0
    STA NINE_COUNT
    STA PRINTED
    LDA #2
    STA PREV_DIGIT

    ; Fill array by 2
    ; LDA #2
    ; A must be 2 already
    LDX #0
.loop:
    STA ARRAY_ADDR,X
    INX
    BNE .loop
    subroutine

    ; For by printed
.print_loop:
    LDA #0
    STA CARRY
    ; Go throught array
    LDX #$30
.array_loop:
    ; x = a[i] * 10
    LDA ARRAY_ADDR,X
    STA MUL_1
    LDA #10
    STA MUL_2
    JSR MUL
    ; x += carry
    ADC CARRY

    ; x / numerator
    STA DIV_1
    ; save numerator
    TXA
    SEC
    ROL
    STA DIV_2
    JSR DIV
    ; a[i] = x % numerator
    STA ARRAY_ADDR,X

    ; carry = Math.floor(x / numerator) * i;
    LDA DIV_CEIL
    STA MUL_1
    STX MUL_2
    JSR MUL
    STA CARRY
    STA ARRAY_ADDR+$90,X

    DEX
    ; CPX #1
    BNE .array_loop

    ; [debug] print carry 
    ; LDX PRINTED
    ; STA ARRAY_ADDR+$90,X

    ; const digitFromCarry = Math.floor(carry / 10);
    LDA CARRY
    STA DIV_1
    LDA #10
    STA DIV_2
    JSR DIV

    ; const nextDigit = carry % 10;
    STA NEXT_DIGIT
    LDA DIV_CEIL
    STA DIGIT_FROM_CARRY

    CLC
    ADC PREV_DIGIT
    LDX PRINTED
    STA RESULT_ADDR,X
    INX
    STX PRINTED

    LDA NEXT_DIGIT
    STA PREV_DIGIT

    CPX #TO_PRINT
    BNE .print_loop

    RTS

; A = MUL_1 * MUL_2
; affects Y
MUL:
    subroutine
    CLC
    LDA #0
    LDY MUL_2
    BNE .loop
    LDA #0
    RTS
.loop:
    ADC MUL_1
    DEY
    BNE .loop
    RTS

; DIV_CEIL = DIV_1 // DIV_2
; A = DIV_1 % DIV_2
; affects Y
DIV:
    subroutine
    LDY #0
    LDA DIV_1
    SEC
.loop
    INY
    SBC DIV_2
    BCS .loop
    ADC DIV_2
    DEY
    STY DIV_CEIL
    STA $0F
    RTS
