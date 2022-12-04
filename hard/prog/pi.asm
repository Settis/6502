    PROCESSOR 6502

    .org $0200

    MAC WRITE_WORD
    LDA #<{1}
    STA {2}
    LDA #>{1}
    STA {2}+1
    ENDM

ARRAY_ADDR = $1000
RESULT_ADDR = $900

; ZP vars
PREV_DIGIT = $00
NINE_COUNT = $01
PRINTED = $02
MUL_1_L = $03
MUL_1_H = $04
MUL_2_L = $05
MUL_2_H = $06
MUL_RES_L = $07
MUL_RES_H = $08

DIV_1_L = $09
DIV_1_H = $0A
DIV_2_L = $0B
DIV_2_H = $0C
DIV_CEIL_L = $0D
DIV_CEIL_H = $0E
DIV_REM_L = $09
DIV_REM_H = $0A

CARRY_L = $11
CARRY_H = $12

DIGIT_FROM_CARRY = $13
NEXT_DIGIT = $14

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

; MUL_RES_H .. MUL_RES_L = MUL_1_H .. MUL_1_L * MUL_2_H .. MUL_2_L
MUL:
    subroutine
    ; put 0 to result
    LDA #0
    STA MUL_RES_L
    STA MUL_RES_H
    LDA MUL_2_L
    BNE .loop
    LDA MUL_2_H
    BNE .loop
    ; Multiply by 0
    RTS
.loop:
    CLC
    LDA MUL_1_L
    ADC MUL_RES_L
    STA MUL_RES_L
    LDA MUL_1_H
    ADC MUL_RES_H
    STA MUL_RES_H
    
    SEC
    LDA MUL_2_L
    SBC #1
    STA MUL_2_L
    LDA MUL_2_H
    SBC #0
    STA MUL_2_H

    BNE .loop
    LDA MUL_2_L
    BNE .loop   
    RTS

; DIV_CEIL_H .. DIV_CEIL_L = DIV_1_H .. DIV_1_L // DIV_2_H .. DIV_2_L
; DIV_REM_H .. DIV_REM_L = DIV_1_H .. DIV_1_L % DIV_2_H .. DIV_2_L
DIV:
    subroutine
    LDA #0
    STA DIV_CEIL_H
    STA DIV_CEIL_L

.cmp_h:
    ; Check if DIV_1 >= DIV_2
    LDA DIV_1_H
    CMP DIV_2_H
    BEQ .cmp_l
    BMI .end
    JMP .loop
.cmp_l:
    LDA DIV_1_L
    CMP DIV_2_L
    BCC .end

.loop:
    SEC
    LDA DIV_1_L
    SBC DIV_2_L
    STA DIV_1_L
    LDA DIV_1_H
    SBC DIV_2_H
    STA DIV_1_H

    CLC
    LDA DIV_CEIL_L
    ADC #1
    STA DIV_CEIL_L
    LDA DIV_CEIL_H
    ADC #0
    STA DIV_CEIL_H
    JMP .cmp_h

.end:
    RTS
