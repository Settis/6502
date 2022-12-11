; Results
; || ==Digits== || ==Time==   || ==Time shift== ||
; |  $10        |      0,398s  |      0,419s     |
; |  $20        |      2,21s   |      1,604s     |
; |  $30        |      6,391s  |      3,445s     |
; |  $40        |     14,079s  |      6,041s     |
; |  $50        |     26,590s  |      9,492s     |
; |  $60        |     44,089s  |     13,475s     |
; |  $70        |  1m  7,973s  |     18,272s     |
; |  $80        |  1m 39,073s  |     23,803s     |
; |  $90        |  2m 18,804s  |     30,130s     |
; |  $a0        |  3m  7,187s  |     37,143s     |
; |  $b0        |  4m  5,504s  |     44,877s     |
; |  $c0        |  5m 15,651s  |     53,440s     |
; |  $d0        |  6m 38,734s  |  1m  2,950s     |
; |  $e0        |  8m 10,720s  |  1m 12,596s     |
; |  $f0        |  9m 59,723s  |  1m 23,384s     |
; |  $ff        | 11m 54,544s  |  1m 34,118s     |

    PROCESSOR 6502

    .org $0200

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
; For div on sub
;DIV_REM_L = $09
;DIV_REM_H = $0A
; For div on shift
DIV_REM_L = $0F
DIV_REM_H = $10

CARRY_L = $11
CARRY_H = $12

DIGIT_FROM_CARRY = $13
NEXT_DIGIT = $14

ARRAY_POINTER_L = $15
ARRAY_POINTER_H = $16
ARRAY_INDEX_L = $17
ARRAY_INDEX_H = $18

TMP_WORD_L = $19
TMP_WORD_H = $1A
TMP_FOR_XY = $1B

; CONST
TO_PRINT = $FF
;ARRAY_LENGTH = $353
ARRAY_LENGTH = [10*TO_PRINT]/3+1
ARRAY_END = ARRAY_ADDR + ARRAY_LENGTH*2

main:
    ; Init vars
    LDA #0
    STA NINE_COUNT
    STA PRINTED
    LDA #2
    STA PREV_DIGIT

    ; Fill array by 2
    LDA #<ARRAY_END
    STA ARRAY_POINTER_L
    LDA #>ARRAY_END
    STA ARRAY_POINTER_H
.fill_loop
    LDY #0
    LDA #2
    STA (ARRAY_POINTER_L),Y
    INY
    LDA #0
    STA (ARRAY_POINTER_L),Y
    
    SEC
    LDA ARRAY_POINTER_L
    SBC #2
    STA ARRAY_POINTER_L
    LDA ARRAY_POINTER_H
    SBC #0
    STA ARRAY_POINTER_H

    CMP #>ARRAY_ADDR
    BEQ .cpm_array_addr_l
    BMI .fill_end
    JMP .fill_loop
.cpm_array_addr_l
    LDA ARRAY_POINTER_L
    CMP #<ARRAY_ADDR
    BNE .fill_loop

.fill_end:
    subroutine

    ; For by printed
    ; not really loop for each digit without cascade carry resolving
.print_loop:
    LDA #0
    STA CARRY_L
    STA CARRY_H

    ; Go throught array
    LDA #<ARRAY_END
    STA ARRAY_POINTER_L
    LDA #>ARRAY_END
    STA ARRAY_POINTER_H
    LDA #<ARRAY_LENGTH
    STA ARRAY_INDEX_L
    LDA #>ARRAY_LENGTH
    STA ARRAY_INDEX_H
.array_loop:
    ; x = a[i] * 10
    LDY #0
    LDA (ARRAY_POINTER_L),Y
    STA MUL_1_L
    INY
    LDA (ARRAY_POINTER_L),Y
    STA MUL_1_H

    LDA #10
    STA MUL_2_L
    LDA #0
    STA MUL_2_H
    JSR MUL

    ; x += carry
    ; x in MULTIPLY result
    ; result is puted for DIV
    CLC
    LDA MUL_RES_L
    ADC CARRY_L
    STA DIV_1_L
    LDA MUL_RES_H
    ADC CARRY_H
    STA DIV_1_H

    ; x / numerator
    ; DIV_1 is already here
    ; save numerator
    LDA ARRAY_INDEX_L
    SEC
    ROL
    STA DIV_2_L
    LDA ARRAY_INDEX_H
    ROL
    STA DIV_2_H
    JSR DIV

    ; a[i] = x % numerator
    ; Y is 1
    LDA DIV_REM_H
    STA (ARRAY_POINTER_L),Y
    DEY
    LDA DIV_REM_L
    STA (ARRAY_POINTER_L),Y

    ; carry = Math.floor(x / numerator) * i;
    LDA DIV_CEIL_L
    STA MUL_1_L
    LDA DIV_CEIL_H
    STA MUL_1_H

    LDA ARRAY_INDEX_L
    STA MUL_2_L
    LDA ARRAY_INDEX_H
    STA MUL_2_H
    JSR MUL

    LDA MUL_RES_L
    STA CARRY_L
    LDA MUL_RES_H
    STA CARRY_H

    ; Decrement array index by 1
    SEC
    LDA ARRAY_INDEX_L
    SBC #1
    STA ARRAY_INDEX_L
    LDA ARRAY_INDEX_H
    SBC #0
    STA ARRAY_INDEX_H

    ; Decrement array pointer by 2
    SEC
    LDA ARRAY_POINTER_L
    SBC #2
    STA ARRAY_POINTER_L
    LDA ARRAY_POINTER_H
    SBC #0
    STA ARRAY_POINTER_H

    CMP #>ARRAY_ADDR
    BEQ .cpm_array_addr_l
    BMI .array_loop_end
    JMP .array_loop
.cpm_array_addr_l
    LDA ARRAY_POINTER_L
    CMP #<ARRAY_ADDR
    BNE .array_loop

.array_loop_end:

    ; const digitFromCarry = Math.floor(carry / 10);
    LDA CARRY_L
    STA DIV_1_L
    LDA CARRY_H
    STA DIV_1_H
    
    LDA #10
    STA DIV_2_L
    LDA #0
    STA DIV_2_H
    JSR DIV

    ; const digitFromCarry assignment
    LDA DIV_CEIL_L
    STA DIGIT_FROM_CARRY

    ; const nextDigit = carry % 10;
    LDA DIV_REM_L
    STA NEXT_DIGIT

    ; Check if we have cascade carry
    CMP #9
    BNE .not_cascade_carry
    INC NINE_COUNT
    JMP .print_loop
.not_cascade_carry:

    CLC
    LDA DIGIT_FROM_CARRY
    ADC PREV_DIGIT
    LDX PRINTED
    STA RESULT_ADDR,X
    INX

    ; check if we have 9s
    LDY NINE_COUNT
    BEQ .nine_print_loop_end

    ; if previous digit is followed by 9s, then print them 
    ;   or 0s, if we have cascade carry
    LDA DIGIT_FROM_CARRY
    BEQ .short_jump
    LDA #0
    JMP .loop_for_nine
.short_jump:
    LDA #9

.loop_for_nine
    STA RESULT_ADDR,X
    INX
    DEY
    BNE .loop_for_nine
.nine_print_loop_end
    
    ; After loop y==0
    STY NINE_COUNT
    ; X is printed
    STX PRINTED

    LDA NEXT_DIGIT
    STA PREV_DIGIT

    CPX #TO_PRINT
    BCC .jump_to_print_loop

    RTS
.jump_to_print_loop
    JMP .print_loop

; MUL_RES_H .. MUL_RES_L = MUL_1_H .. MUL_1_L * MUL_2_H .. MUL_2_L
MUL_ADD:
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

; MUL on shifts
MUL:
    subroutine
    LDA #0
    STA TMP_WORD_H
    STA TMP_WORD_L
    STY TMP_FOR_XY
    LDY #16
.loop:
    LSR MUL_1_H
    ROR MUL_1_L
    BCC .no_add
    CLC
    LDA MUL_2_L
    ADC TMP_WORD_L
    STA TMP_WORD_L
    LDA MUL_2_H
    ADC TMP_WORD_H
    STA TMP_WORD_H
.no_add:
    LSR TMP_WORD_H
    ROR TMP_WORD_L
    ROR MUL_RES_H
    ROR MUL_RES_L
    DEY
    BNE .loop
    LDY TMP_FOR_XY
    RTS


; DIV_CEIL_H .. DIV_CEIL_L = DIV_1_H .. DIV_1_L // DIV_2_H .. DIV_2_L
; DIV_REM_H .. DIV_REM_L = DIV_1_H .. DIV_1_L % DIV_2_H .. DIV_2_L
; NB: DIV_1 points the same area as DIV_REM
DIV_SUB:
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

; DIV via shift
DIV:
    subroutine
    LDA #0
    STA DIV_REM_H
    STA DIV_REM_L
    STY TMP_FOR_XY
    LDY #16
.loop:
    ASL DIV_1_L
    ROL DIV_1_H
    ROL DIV_REM_L
    ROL DIV_REM_H

    CLC
    ROL TMP_WORD_L
    ; if DIV_REM >= DIV_2
    LDA DIV_REM_H
    CMP DIV_2_H
    BEQ .cmp_l
    BMI .no_subtract
    JMP .subtract
.cmp_l:
    LDA DIV_REM_L
    CMP DIV_2_L
    BCC .no_subtract

.subtract:
    SEC
    LDA DIV_REM_L
    SBC DIV_2_L
    STA DIV_REM_L
    LDA DIV_REM_H
    SBC DIV_2_H
    STA DIV_REM_H

    ROL TMP_WORD_L

.no_subtract:
    ROR TMP_WORD_L
    ROL DIV_CEIL_L
    ROL DIV_CEIL_H
    DEY
    BNE .loop
    LDY TMP_FOR_XY
    RTS
