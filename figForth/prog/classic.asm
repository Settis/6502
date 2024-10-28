; Memory map:
;       6502 internal
;   0000..00FF pseudo registers
;   0100..01FF 6502 stack

;       Forth
;   0200..     dictionary `DP`
;       ..     PAD
;       ..7DFF data stack `S0` & `SP`
;   7E00..     `TIB` (terminal input buffer) & `IN`
;       ..7EFF Return stack `R0` & `RP`
;   7F00..7FFF user area

; Constants
; S0  = 7DFF
; TIB = 7E00
; R0  = 7EFF

; Variables
; DP  - dictionary pointer
; PAD - DP + XX / text buffer
; SP  - data stack pointer
; IN  - terminal input buffer pointer
; RP  - return stack pointer

;   Minimum from https://wiki.forth-ev.de/doku.php/en:words:kernel_embedded:minimum_word_set
; `:dodoes` as generalized entry point for all high-level definitions, or
; `Call` for primitive-centric implementations.
; `@` and `!` to access the memory.
; `>R` and `R>` for the return stack, so anything can be moved.
; `+` or `2*` for Artihmetik.
; And `NAND` as a universal bit instruction.
; `0=` for branches.
; And finally `;S` and
; `EXECUTE` for execution.

; Boolean flags: 0 - false, non-zero - true

;    Dictionary record:
; NFA |1|P|S|Length|   p - immediate flag, s - smudge flag
;     |0| ASCII #0 |
;     |0| ASCII #1 |
;     |   ...      |
;     |1| ASCII #n |
; LFA | link field |
; CFA | code field |
; PFA | parameter  |
;     |   field    |
;     |   ...      |

    PROCESSOR 6502

S0_CONST = $7DFE
TIB0_CONST = $7E00
R0_CONST = $7EFE

; Debug output
DEBUG_EXECUTE = 0
DEBUG_DOCOL = 0
DEBUG_NEXT = 0
DEBUG_DOSEMICOL = 0
DEBUG_CLEAN_STACK = 0

    seg.u UserArea
    org $7F00
    ; It's empty for now

    seg.u zp
    org 0
STACK_TMP: ds 2 ; [internal] for transfering data between stacks
INTERNAL_TMP: ds 2 ; [internal]
TMP_LENGTH: ds 1 ; [internal] for string length
DP_ADDR: ds 2
SP_ADDR: ds 2
TIB_ADDR: ds 2
IN_ADDR: ds 2
RP_ADDR: ds 2
IP_ADDR: ds 2 ; [internal] interpretive pointer for call executor
W_ADDR:  ds 2 ; [internal] current word pointer for call executor
FORTH_VOCABULARY: ds 2
STATE_VALUE: ds 2
UART_PRINT_STRING_ADDR: ds 2 ; [for debug]
TIMER_COUNTER: ds 2
TIMER_START_VALUE: ds 2

    seg CODE
    org $C000
    
    MAC WRITE_WORD_TO ; 1 - data, 2 - addr
        LDA #<{1}
        STA {2}
        LDA #>{1}
        STA {2}+1
    ENDM
    MAC COPY_WORD_TO ; 1 - word addr, 2 - dst addr
        LDA {1}
        STA {2}
        LDA {1}+1
        STA {2}+1
    ENDM

START:
    JSR INIT_HW
    CLI

    ; init
    WRITE_WORD_TO $0200, DP_ADDR
    WRITE_WORD_TO S0_CONST, SP_ADDR
    WRITE_WORD_TO 0, TIB_ADDR
    WRITE_WORD_TO TEXT, IN_ADDR
    WRITE_WORD_TO R0_CONST, RP_ADDR
    WRITE_WORD_TO LAST_F_WORD, FORTH_VOCABULARY
    WRITE_WORD_TO 0, STATE_VALUE

TEXT_LOOP:
    JSR COPY_WORD_FROM_TEXT

    COPY_WORD_TO DP_ADDR, STACK_TMP
    JSR PUSH_TO_S
    COPY_WORD_TO FORTH_VOCABULARY, STACK_TMP
    JSR PUSH_TO_S
    JSR FIND_IN_DICTIONARY

    JSR PULL_FROM_S
    LDA STACK_TMP
    BEQ .parseNumber

    JSR PREPARE_CFA_NFA

    LDA INTERNAL_TMP
    CMP STATE_VALUE  ; check if we need to run or compile this word
    BCS .executeWord
.compileWord:
    JSR F_WORD_COMMA_SUBROUTINE
    JMP .endTextLoop
.executeWord:
    WRITE_WORD_TO JMP_END_TEXT_LOOP_WORDS, IP_ADDR
    JMP EXECUTE

.parseNumber:
    JSR READ_NUMBER
    LDA STATE_VALUE
    BEQ .endTextLoop
    WRITE_WORD_TO F_LIT_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_COMMA_SUBROUTINE
    JSR F_WORD_COMMA_SUBROUTINE
.endTextLoop:
    ; check if it's end of the text
    LDY #0
    LDA (IN_ADDR),Y
    BNE TEXT_LOOP

    PRINT_STRING "Stack:"
    JSR PRINT_NEW_LINE
    JSR PRINT_STACK
    BRK

PREPARE_CFA_NFA:
    JSR PULL_FROM_S 
    LDA STACK_TMP
    STA INTERNAL_TMP
    
    JSR PULL_FROM_S ; pull PFA
    SEC
    LDA STACK_TMP
    SBC #2
    STA STACK_TMP
    LDA STACK_TMP+1
    SBC #0
    STA STACK_TMP+1
    JSR PUSH_TO_S  ; convert PFA to CFA
    RTS

JMP_END_TEXT_LOOP_WORDS:
    DC.W JMP_END_TEXT_LOOP_ADDR
    DC.W JMP_END_TEXT_LOOP_ADDR
JMP_END_TEXT_LOOP_ADDR:
    DC.W .endTextLoop

COPY_WORD_FROM_TEXT:
    SUBROUTINE
    COPY_WORD_TO DP_ADDR, STACK_TMP
    INC STACK_TMP
    BNE .skipUp
    INC STACK_TMP+1
.skipUp:
    LDY #0
.copyLoop:
    LDA (IN_ADDR),Y
    CMP #'   ; check for space
    BEQ .end
    STA (STACK_TMP),Y
    INY
    JMP .copyLoop
.end:
    LDX #0
    TYA
    STA (DP_ADDR,X)
    SEC ; For increase text pointer by word size +1 for space
    ADC IN_ADDR
    STA IN_ADDR
    LDA IN_ADDR+1
    ADC #0
    STA IN_ADDR+1
    TYA ; check if we read 0 characters
    BEQ .skipUp ; we skip the space and try to read again
    RTS

FIND_IN_DICTIONARY: ; (FIND) primitive ( NAME_ADDR DICTIONARY_RECORD_ADDR -- PFA NAME_LENGTH TF / FF )
    SUBROUTINE
    JSR PULL_FROM_S
    COPY_WORD_TO STACK_TMP, INTERNAL_TMP ; INTERNAL_TMP for distionary record addr
    JSR PULL_FROM_S                      ; STACK_TMP for name addr
    LDY #0
    LDA (STACK_TMP),Y
    CMP #32
    BCC .normalSize
    LDA #31  ; the maximum name size
.normalSize:
    STA TMP_LENGTH
.checkName:
    LDY #0
    LDA (INTERNAL_TMP),Y
    TAX
    AND #$20  ; check smudge flag
    BNE .nextRecord
    TXA
    AND #$1F  ; to extract only size
    CMP TMP_LENGTH
    BNE .nextRecord
.nextChar:
    INY
    LDA (INTERNAL_TMP),Y
    AND #$7F  ; to clear high bit
    CMP (STACK_TMP),Y
    BNE .nextRecord
    CPY TMP_LENGTH
    BNE .nextChar
    ; We found it!
    TYA
    CLC
    ADC #[1+2+2] ; 1 for point to the LFA, 2 for CFA, 2 for PFA
    ADC INTERNAL_TMP
    STA STACK_TMP
    LDA INTERNAL_TMP+1
    ADC #0
    STA STACK_TMP+1
    JSR PUSH_TO_S
    LDY #0
    LDA (INTERNAL_TMP),Y
    STA STACK_TMP
    LDA #0
    STA STACK_TMP+1
    JSR PUSH_TO_S
    JMP PUSH_TRUE_TO_S 

.nextRecord:
    LDY #0
    LDA (INTERNAL_TMP),Y
    AND #$1F  ; to extract only size
    TAY
    INY
    ; Reading LFA to X and A
    LDA (INTERNAL_TMP),Y
    TAX
    INY 
    LDA (INTERNAL_TMP),Y
    BEQ .notFound ; if upper byte of address is 0 I don't need to check the lover part
    ; Store LFA to INTERNAL_TMP, go to the next record
    STA INTERNAL_TMP+1
    TXA
    STA INTERNAL_TMP
    JMP .checkName
.notFound:
    JMP PUSH_FALSE_TO_S

READ_NUMBER:
    SUBROUTINE
    LDY #0
    LDA (DP_ADDR),Y
    STA TMP_LENGTH ; Store size here
    STY STACK_TMP
    STY STACK_TMP+1
.digitLoop:
    INY
    LDA (DP_ADDR),Y 
    ; shift TMP
    LDX #4
.shifting:
    ASL STACK_TMP
    ROL STACK_TMP+1
    DEX
    BNE .shifting
    ; add number
    SEC
    SBC #'0
    CMP #10
    BCC .digitChar
    ; carry is set already
    SBC #['A-'9-1]
    CMP #10
    BCC .nan
    CMP #$10
    BCC .digitChar
.nan:
    JMP PRINT_NAN
.digitChar:
    ORA STACK_TMP
    STA STACK_TMP
    CPY TMP_LENGTH ; check size
    BNE .digitLoop
    JMP PUSH_TO_S

EXECUTE:  ; FORTH ( CFA -- )
    SUBROUTINE
    JSR PULL_FROM_S
    JSR PUSH_TO_S
    IF DEBUG_EXECUTE
        PRINT_STRING "EXECUTE CFA:"
        LDA STACK_TMP+1
        JSR PRINT_BYTE_HEX
        LDA STACK_TMP
        JSR PRINT_BYTE_HEX
    ENDIF
    CLC
    LDA STACK_TMP
    ADC #2
    STA W_ADDR
    LDA STACK_TMP+1
    ADC #0
    STA W_ADDR+1
    IF DEBUG_EXECUTE
        PRINT_STRING " W:"
        LDA W_ADDR+1
        JSR PRINT_BYTE_HEX
        LDA W_ADDR
        JSR PRINT_BYTE_HEX
    ENDIF
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JSR PULL_FROM_S
    IF DEBUG_EXECUTE
        PRINT_STRING " jump:"
        LDA STACK_TMP+1
        JSR PRINT_BYTE_HEX
        LDA STACK_TMP
        JSR PRINT_BYTE_HEX
        JSR PRINT_NEW_LINE
    ENDIF
    JMP (STACK_TMP)

; Transfering data between stacks goes via TMP 
PUSH_TO_S:
    SUBROUTINE
    LDY #$0
    LDA STACK_TMP
    STA (SP_ADDR),Y
    INY
    LDA STACK_TMP+1
    STA (SP_ADDR),Y

    SEC
    LDA SP_ADDR
    SBC #2
    STA SP_ADDR
    BCS .end
    DEC SP_ADDR+1
.end:
    RTS

PULL_FROM_S:
    SUBROUTINE
    CLC
    LDA SP_ADDR
    ADC #2
    STA SP_ADDR
    BCC .end
    INC SP_ADDR+1
.end:

    LDY #$0
    LDA (SP_ADDR),Y
    STA STACK_TMP
    IF DEBUG_CLEAN_STACK
        LDA #0
        STA (SP_ADDR),Y
    ENDIF
    INY
    LDA (SP_ADDR),Y
    STA STACK_TMP+1
    IF DEBUG_CLEAN_STACK
        LDA #0
        STA (SP_ADDR),Y
    ENDIF
    RTS

PUSH_TO_R:
    LDY #$0
    LDA STACK_TMP
    STA (RP_ADDR),Y
    INY
    LDA STACK_TMP+1
    STA (RP_ADDR),Y
    DEC RP_ADDR ; return stack will fit in one page, I don't care about upper byte
    DEC RP_ADDR
    RTS

PULL_FROM_R:
    INC RP_ADDR
    INC RP_ADDR
    LDY #$0
    LDA (RP_ADDR),Y
    STA STACK_TMP
    IF DEBUG_CLEAN_STACK
        LDA #0
        STA (RP_ADDR),Y
    ENDIF
    INY
    LDA (RP_ADDR),Y
    STA STACK_TMP+1
    IF DEBUG_CLEAN_STACK
        LDA #0
        STA (RP_ADDR),Y
    ENDIF
    RTS

PUSH_TRUE_TO_S:
    LDA #$FF
    STA STACK_TMP
    STA STACK_TMP+1
    JMP PUSH_TO_S

PUSH_FALSE_TO_S:
    LDA #$00
    STA STACK_TMP
    STA STACK_TMP+1
    JMP PUSH_TO_S

CREATE_DICTIONARY_HEADER_WITH_CFA: ; ( CFA -- ) reads the next word for a name
    JSR COPY_WORD_FROM_TEXT
    LDY #0
    LDA (DP_ADDR),Y
    TAX
    ORA #$80
    STA (DP_ADDR),Y
    TXA
    TAY
    LDA (DP_ADDR),Y
    ORA #$80
    STA (DP_ADDR),Y   ; Set high bits for NFA

    INY
    LDA FORTH_VOCABULARY
    STA (DP_ADDR),Y
    INY
    LDA FORTH_VOCABULARY+1
    STA (DP_ADDR),Y   ; LFA set
    COPY_WORD_TO DP_ADDR, FORTH_VOCABULARY ; Update context value

    INY
    CLC
    TYA
    ADC DP_ADDR
    STA DP_ADDR
    LDA DP_ADDR+1
    ADC #0
    STA DP_ADDR+1   ; Update dictionary pointer

    JSR F_WORD_COMMA_SUBROUTINE ; CFA set

    RTS

F_WORD_COMMA_SUBROUTINE: ; , ( n -- )
    JSR PULL_FROM_S
    LDY #0
    LDA STACK_TMP
    STA (DP_ADDR),Y
    INY
    LDA STACK_TMP+1
    STA (DP_ADDR),Y

    CLC
    LDA DP_ADDR
    ADC #2
    STA DP_ADDR
    LDA DP_ADDR+1
    ADC #0
    STA DP_ADDR+1   ; Update dictionary pointer
    RTS

DOCOL:
    COPY_WORD_TO IP_ADDR, STACK_TMP
    JSR PUSH_TO_R
    COPY_WORD_TO W_ADDR, IP_ADDR
    IF DEBUG_DOCOL
        PRINT_STRING "DOCOL OLD_IP:"
        LDA STACK_TMP+1
        JSR PRINT_BYTE_HEX
        LDA STACK_TMP
        JSR PRINT_BYTE_HEX
        PRINT_STRING " W=IP="
        LDA IP_ADDR+1
        JSR PRINT_BYTE_HEX
        LDA IP_ADDR
        JSR PRINT_BYTE_HEX
    ENDIF
    JMP NEXT

NEXT:
    COPY_WORD_TO IP_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    CLC
    LDA IP_ADDR
    ADC #2
    STA IP_ADDR
    LDA IP_ADDR+1
    ADC #0
    STA IP_ADDR+1
    JSR PULL_FROM_S
    JSR PUSH_TO_S
    CLC 
    LDA STACK_TMP
    ADC #2
    STA W_ADDR
    LDA STACK_TMP+1
    ADC #0
    STA W_ADDR+1
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JSR PULL_FROM_S
    IF DEBUG_NEXT
        PRINT_STRING " Next IP:"
        LDA IP_ADDR+1
        JSR PRINT_BYTE_HEX
        LDA IP_ADDR
        JSR PRINT_BYTE_HEX
        PRINT_STRING " W:"
        LDA W_ADDR+1
        JSR PRINT_BYTE_HEX
        LDA W_ADDR
        JSR PRINT_BYTE_HEX
        PRINT_STRING " jump:"
        LDA STACK_TMP+1
        JSR PRINT_BYTE_HEX
        LDA STACK_TMP
        JSR PRINT_BYTE_HEX
        JSR PRINT_NEW_LINE
    ENDIF
    JMP (STACK_TMP)

DOSEMICOL_ADDR:
    DC.W DOSEMICOL
DOSEMICOL:
    JSR PULL_FROM_R
    COPY_WORD_TO STACK_TMP, IP_ADDR
    IF DEBUG_DOSEMICOL
        PRINT_STRING "DOSEMICOL IP:"
        LDA IP_ADDR+1
        JSR PRINT_BYTE_HEX
        LDA IP_ADDR
        JSR PRINT_BYTE_HEX
    ENDIF
    JMP NEXT

F_LIT_ADDR:
    DC.W F_LIT
F_LIT:
    COPY_WORD_TO IP_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    CLC 
    LDA IP_ADDR
    ADC #2
    STA IP_ADDR
    LDA IP_ADDR+1
    ADC #0
    STA IP_ADDR+1
    JMP NEXT

;  ======= Forth words ========    
F_WORD_TO_RETURN_STACK: ; >R
    DC 2  | $80
    DC '>
    DC 'R | $80
    DC.W 0
    DC.W F_WORD_TO_RETURN_STACK_CODE
F_WORD_TO_RETURN_STACK_CODE:    
    JSR PULL_FROM_S
    JSR PUSH_TO_R
    JMP NEXT


F_WORD_FROM_RETURN_STACK: ; R>
    DC 2  | $80
    DC 'R
    DC '> | $80
    DC.W F_WORD_TO_RETURN_STACK
    DC.W F_WORD_FROM_RETURN_STACK_CODE
F_WORD_FROM_RETURN_STACK_CODE:
    JSR PULL_FROM_R
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_READ_FROM_ADDR: ; @
    DC 1   | $80
    DC '@  | $80
    DC.W F_WORD_FROM_RETURN_STACK
    DC.W F_WORD_READ_FROM_ADDR_CODE
F_WORD_READ_FROM_ADDR_CODE:
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JMP NEXT
F_WORD_READ_FROM_ADDR_SUBROUTINE:
    JSR PULL_FROM_S
    LDY #0
    LDA (STACK_TMP),Y
    TAX
    INY
    LDA (STACK_TMP),Y
    STA STACK_TMP+1
    TXA
    STA STACK_TMP
    JMP PUSH_TO_S

F_WORD_WRITE_TO_ADDR: ; !
    DC 1  | $80
    DC '! | $80
    DC.W F_WORD_READ_FROM_ADDR
    DC.W F_WORD_WRITE_TO_ADDR_CODE
F_WORD_WRITE_TO_ADDR_CODE:
    JSR PULL_FROM_S
    COPY_WORD_TO STACK_TMP, INTERNAL_TMP
    JSR PULL_FROM_S
    LDY #0
    LDA STACK_TMP
    STA (INTERNAL_TMP),Y
    INY
    LDA STACK_TMP+1
    STA (INTERNAL_TMP),Y
    JMP NEXT

F_WORD_PLUS: ; +
    DC 1  | $80
    DC '+ | $80
    DC.W F_WORD_WRITE_TO_ADDR
    DC.W F_WORD_PLUS_CODE
F_WORD_PLUS_CODE:
    JSR PULL_FROM_S
    COPY_WORD_TO STACK_TMP, INTERNAL_TMP
    JSR PULL_FROM_S
    CLC
    LDA INTERNAL_TMP
    ADC STACK_TMP
    STA STACK_TMP
    LDA INTERNAL_TMP+1
    ADC STACK_TMP+1
    STA STACK_TMP+1
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_MUL_BY_2: ; 2*
    DC 2  | $80
    DC '2
    DC '* | $80
    DC.W F_WORD_PLUS
    DC.W F_WORD_MUL_BY_2_CODE
F_WORD_MUL_BY_2_CODE:
    JSR PULL_FROM_S
    ASL STACK_TMP
    ROL STACK_TMP+1
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_DIV_BY_2: ; 2/
    DC 2  | $80
    DC '2
    DC '/ | $80
    DC.W F_WORD_MUL_BY_2
    DC.W F_WORD_DIV_BY_2_CODE
F_WORD_DIV_BY_2_CODE:
    JSR PULL_FROM_S
    LSR STACK_TMP+1
    ROR STACK_TMP
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_NAND: ; NAND
    DC 4  | $80
    DC "NAN"
    DC 'D | $80
    DC.W F_WORD_DIV_BY_2
    DC.W F_WORD_NAND_CODE
F_WORD_NAND_CODE:
    JSR PULL_FROM_S
    COPY_WORD_TO STACK_TMP, INTERNAL_TMP
    JSR PULL_FROM_S
    LDA STACK_TMP
    AND INTERNAL_TMP
    EOR #$FF  ; for NOT
    STA STACK_TMP
    LDA STACK_TMP+1
    AND INTERNAL_TMP+1
    EOR #$FF  ; for NOT
    STA STACK_TMP+1
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_EQUALS_0: ; 0=
    DC 2  | $80
    DC '0
    DC '= | $80
    DC.W F_WORD_NAND
    DC.W F_WORD_EQUALS_0_CODE
F_WORD_EQUALS_0_CODE:
    SUBROUTINE
    JSR PULL_FROM_S
    LDA STACK_TMP
    BNE .notZero
    LDA STACK_TMP+1
    BNE .notZero
    JSR PUSH_TRUE_TO_S
    JMP NEXT
.notZero:
    JSR PUSH_FALSE_TO_S
    JMP NEXT

F_WORD_FIND_INT: ; (FIND)
    DC 6  | $80
    DC "(FIND"
    DC ') | $80
    DC.W F_WORD_EQUALS_0
    DC.W FIND_IN_DICTIONARY_CODE
FIND_IN_DICTIONARY_CODE:
    JSR FIND_IN_DICTIONARY
    JMP NEXT

F_WORD_WORD_INT: ; (WORD)
    DC 6  | $80
    DC "(WORD"
    DC ') | $80
    DC.W F_WORD_FIND_INT
    DC.W F_WORD_WORD_INT_CODE
F_WORD_WORD_INT_CODE:
    JSR COPY_WORD_FROM_TEXT
    JMP NEXT

F_WORD_EXECUTE: ; EXECUTE
    DC 7  | $80
    DC "EXECUT"
    DC 'E | $80
    DC.W F_WORD_WORD_INT
    DC.W EXECUTE

F_WORD_COMMA: ; ,
    DC 1  | $80
    DC ', | $80
    DC.W F_WORD_EXECUTE
    DC.W F_WORD_COMMA_CODE
F_WORD_COMMA_CODE:
    JSR F_WORD_COMMA_SUBROUTINE
    JMP NEXT

F_WORD_CONSTANT: ; CONSTANT
    DC 8  | $80
    DC "CONSTAN"
    DC 'T | $80
    DC.W F_WORD_COMMA
    DC.W F_WORD_CONSTANT_CODE
F_WORD_CONSTANT_CODE:
    WRITE_WORD_TO F_WORD_CONSTANT_RUNTIME, STACK_TMP
    JSR PUSH_TO_S ; push CFA to stack
    
    JSR CREATE_DICTIONARY_HEADER_WITH_CFA

    JSR F_WORD_COMMA_SUBROUTINE ; store constant
    JMP NEXT
F_WORD_CONSTANT_RUNTIME:
    COPY_WORD_TO W_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JMP NEXT

F_WORD_VARIABLE: ; VARIABLE
    DC 8  | $80
    DC "VARIABL"
    DC 'E | $80
    DC.W F_WORD_CONSTANT
    DC.W F_WORD_VARIABLE_CODE
F_WORD_VARIABLE_CODE:
    ; It looks the same as constant from the beggining
    WRITE_WORD_TO F_WORD_VARIABLE_RUNTIME, STACK_TMP
    JSR PUSH_TO_S ; push CFA to stack
    JSR CREATE_DICTIONARY_HEADER_WITH_CFA 
    LDA #0
    STA STACK_TMP
    STA STACK_TMP+1
    JSR PUSH_TO_S
    JSR F_WORD_COMMA_SUBROUTINE
    JMP NEXT
F_WORD_VARIABLE_RUNTIME:
    COPY_WORD_TO W_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_DP: ; DP
    DC 2  | $80
    DC 'D
    DC 'P | $80
    DC.W F_WORD_VARIABLE
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W DP_ADDR

F_WORD_TIB: ; TIB
    DC 3  | $80
    DC "TI"
    DC 'B | $80
    DC.W F_WORD_DP
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W TIB_ADDR

F_WORD_IN: ; IN
    DC 2  | $80
    DC 'I
    DC 'N | $80
    DC.W F_WORD_TIB
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W IN_ADDR
    
F_WORD_STATE: ; STATE
    DC 5  | $80
    DC "STAT"
    DC 'E | $80
    DC.W F_WORD_IN
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W STATE_VALUE

F_WORD_FORTH: ; FORTH
    DC 5  | $80
    DC "FORT"
    DC 'H | $80
    DC.W F_WORD_STATE
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W FORTH_VOCABULARY

F_WORD_COLON: ; :
    DC 1  | $80
    DC ': | $80
    DC.W F_WORD_FORTH
    DC.W F_WORD_COLON_CODE
F_WORD_COLON_CODE:
    WRITE_WORD_TO DOCOL, STACK_TMP
    JSR PUSH_TO_S
    JSR CREATE_DICTIONARY_HEADER_WITH_CFA
    LDA #$C0
    STA STATE_VALUE
    JMP NEXT

F_WORD_SEMICOLON: ; ;
    DC 1  | $80 | $40
    DC '; | $80
    DC.W F_WORD_COLON
    DC.W F_WORD_SEMICOLON_CODE
F_WORD_SEMICOLON_CODE:
    WRITE_WORD_TO DOSEMICOL_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_COMMA_SUBROUTINE
    LDA #0
    STA STATE_VALUE
    JMP NEXT

F_WORD_BRANCH: ; BRANCH
    DC 6  | $80
    DC "BRANC"
    DC 'H | $80
    DC.W F_WORD_SEMICOLON
    DC.W F_WORD_BRANCH_CODE
F_WORD_BRANCH_CODE:
    COPY_WORD_TO IP_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JSR PULL_FROM_S
    CLC
    LDA STACK_TMP
    ADC IP_ADDR
    STA IP_ADDR
    LDA STACK_TMP+1
    ADC IP_ADDR+1
    STA IP_ADDR+1
    JMP NEXT

F_WORD_0BRANCH: ; 0BRANCH
    DC 7  | $80
    DC "0BRANC"
    DC 'H | $80
    DC.W F_WORD_BRANCH
    DC.W F_WORD_0BRANCH_CODE
F_WORD_0BRANCH_CODE:
    SUBROUTINE
    JSR PULL_FROM_S
    LDA STACK_TMP
    BNE .next
    LDA STACK_TMP+1
    BNE .next
    JMP F_WORD_BRANCH_CODE
.next:
    CLC 
    LDA #2
    ADC IP_ADDR
    STA IP_ADDR
    LDA #0
    ADC IP_ADDR+1
    STA IP_ADDR+1
    JMP NEXT

F_WORD_EMIT: ; EMIT
    DC 4  | $80
    DC "EMI"
    DC 'T | $80
    DC.W F_WORD_0BRANCH
    DC.W F_WORD_EMIT_CODE
F_WORD_EMIT_CODE:
    JSR PULL_FROM_S
    LDA STACK_TMP
    JSR PRINT_CHAR
    JMP NEXT

F_WORD_KEY: ; key
    DC 3  | $80
    DC "KE"
    DC 'Y | $80
    DC.W F_WORD_EMIT
    DC.W F_WORD_KEY_CODE
F_WORD_KEY_CODE:
    SUBROUTINE
.loop:
    LDA KEY_CODE
    BEQ .loop
    STA STACK_TMP
    LDA #0
    STA KEY_CODE
    STA STACK_TMP+1
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_RESET_TIB: ; TIB!
    DC 4  | $80
    DC "TIB"
    DC '! | $80
    DC.W F_WORD_KEY
    DC.W F_WORD_RESET_TIB_CODE
F_WORD_RESET_TIB_CODE:
    WRITE_WORD_TO TIB0_CONST, TIB_ADDR
    JMP NEXT

F_WORD_RESET_SP: ; SP!
    DC 3  | $80
    DC "SP"
    DC '! | $80
    DC.W F_WORD_RESET_TIB
    DC.W F_WORD_RESET_SP_CODE
F_WORD_RESET_SP_CODE:
    WRITE_WORD_TO S0_CONST, SP_ADDR
    JMP NEXT

F_WORD_RESET_RP: ; RP!
    DC 3  | $80
    DC "RP"
    DC '! | $80
    DC.W F_WORD_RESET_SP
    DC.W F_WORD_RESET_RP_CODE
F_WORD_RESET_RP_CODE:
    WRITE_WORD_TO R0_CONST, RP_ADDR
    JMP NEXT

F_WORD_SP_ADDR: ; SP@
    DC 3  | $80
    DC "SP"
    DC '@ | $80
    DC.W F_WORD_RESET_RP
    DC.W F_WORD_SP_ADDR_CODE
F_WORD_SP_ADDR_CODE:
    COPY_WORD_TO SP_ADDR, STACK_TMP
    JSR PUSH_TO_S 
    JMP NEXT

F_WORD_S0: ; S0
    DC 2  | $80
    DC 'S
    DC '0 | $80
    DC.W F_WORD_SP_ADDR
    DC.W F_WORD_S0_CODE
F_WORD_S0_CODE:
    WRITE_WORD_TO S0_CONST, STACK_TMP
    JSR PUSH_TO_S
    JMP NEXT

F_WORD_DOCOL: ; (DOCOL)
    DC 7  | $80
    DC "(DOCOL"
    DC ') | $80
    DC.W F_WORD_S0
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W DOCOL

F_WORD_DOVAR: ; (DOVAR)
    DC 7  | $80
    DC "(DOVAR"
    DC ') | $80
    DC.W F_WORD_DOCOL
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W F_WORD_VARIABLE_RUNTIME

F_WORD_DOCONST: ; (DOCONST)
    DC 9  | $80
    DC "(DOCONST"
    DC ') | $80
    DC.W F_WORD_DOVAR
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W F_WORD_CONSTANT_RUNTIME

F_WORD_T_CNT: ; T_CNT
    DC 5  | $80
    DC "T_CN"
    DC 'T | $80
    DC.W F_WORD_DOCONST
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W TIMER_COUNTER

F_WORD_T_START_VAL: ; T_START_VAL
    DC 11 | $80
    DC "T_START_VA"
    DC 'L | $80
    DC.W F_WORD_T_CNT
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W TIMER_START_VALUE

F_WORD_T_START: ; T_START
    DC 7  | $80
    DC "T_STAR"
    DC 'T | $80
    DC.W F_WORD_T_START_VAL
    DC.W F_WORD_T_START_CODE
F_WORD_T_START_CODE:
    LDA #%01000000
    STA VIA_AUXILARY_CONTROL
    LDA #0
    STA TIMER_COUNTER
    STA TIMER_COUNTER+1
    LDA TIMER_START_VALUE
    STA T1COUNTER_L
    LDA TIMER_START_VALUE+1
    STA T1COUNTER_H
    JMP NEXT

F_WORD_T_STOP: ; T_STOP
LAST_F_WORD:
    DC 6  | $80
    DC "T_STO"
    DC 'P | $80
    DC.W F_WORD_T_START
    DC.W F_WORD_T_STOP_CODE
F_WORD_T_STOP_CODE:
    LDA #%00000000
    STA VIA_AUXILARY_CONTROL
    JMP NEXT

    seg.u zp
KEY_CODE: ds 1

    seg CODE
IRQ:
    SUBROUTINE
    PHA
    LDA IOSTATUS
    AND #$80
    BEQ .timer
.keyboard_interrupt:
    LDA IOBASE
    STA KEY_CODE
    JMP .other
.timer:
    BRK
    LDA VIA_IFR
    AND #%01000000
    BEQ .other
    LDA T1COUNTER_L
    INC TIMER_COUNTER
    BNE .other
    INC TIMER_COUNTER+1
    JMP .other
.other:
    PLA
    RTI

TEXT:
    INCBIN "stripped.txt"
    dc " "
    dc 0

IOBASE   = $8800
IOSTATUS = IOBASE + 1
IOCMD    = IOBASE + 2
IOCTRL   = IOBASE + 3

VIABASE     = $8000
T1COUNTER_L = $8004
T1COUNTER_H = $8005
T1LATCH_L   = $8006
T1LATCH_H   = $8007
VIA_AUXILARY_CONTROL = $800B
VIA_IER     = $800E
VIA_IFR     = $800D

INIT_HW:
    LDA #$09
    STA IOCMD      ; Set command status
    LDA #$1A
    STA IOCTRL     ; 0 stop bits, 8 bit word, 2400 baud
    LDA #%11000000 ; enable T1 interrupts
    STA VIA_IER
    RTS

tmp set 0
    MAC PRINT_STRING
tmp set .string
    WRITE_WORD_TO tmp, UART_PRINT_STRING_ADDR
    JSR PRINT_STRING_ROUTINE
    JMP .endString
.string:
    DC {1}
    DC 0
.endString:
    ENDM

PRINT_STRING_ROUTINE:
    SUBROUTINE
    LDY #0
.loop:
    LDA (UART_PRINT_STRING_ADDR),Y
    BNE .print
    RTS
.print:
    JSR PRINT_CHAR
    INY
    JMP .loop

PRINT_STACK:
    SUBROUTINE
.loop:
    LDA SP_ADDR
    CMP #<S0_CONST
    BNE .print
    LDA SP_ADDR+1
    CMP #>S0_CONST
    BEQ .halt
.print:
    JSR PULL_FROM_S
    LDA STACK_TMP+1
    JSR PRINT_BYTE_HEX
    LDA STACK_TMP
    JSR PRINT_BYTE_HEX
    JSR PRINT_NEW_LINE
    JMP .loop

.halt:
    RTS

PRINT_NEW_LINE:
    LDA #$0D
    JMP PRINT_CHAR

PRINT_BYTE_HEX:
    PHA
    LSR
    LSR
    LSR
    LSR
    JSR PRINT_DIGIT
    PLA
    ; JSR PRINT_DIGIT

PRINT_DIGIT:
    SUBROUTINE
    AND #$0F
    CLC
    CMP #10
    BCC .lower
    ADC #6
.lower:
    ADC #'0
    ; It is the next subroutine
    ; JSR PRINT_CHAR
    ; RTS

PRINT_CHAR:
    SUBROUTINE
        PHA             ; Save accumulator
.ECHO1:  LDA IOSTATUS    ; Read the ACIA status
        AND #$10        ; Is the tx register empty?
        BEQ .ECHO1       ; No, wait for it to empty
        PLA             ; Otherwise, load saved accumulator,
        STA IOBASE      ; write to output,
        CMP #$0D        ; check if it was CR
        BNE .END
        LDA #$0A        ; then output LF too
        PHA
        JMP .ECHO1
.END:    RTS             ; and return

PRINT_NAN:
    PRINT_STRING "NaN: "
    SUBROUTINE
    LDY #0
    LDA (DP_ADDR),Y
    STA TMP_LENGTH ; Store size here
.loop:
    INY
    LDA (DP_ADDR),Y
    JSR PRINT_CHAR
    CPY TMP_LENGTH
    BNE .loop
    BRK

; system vectors

    seg VECTORS
    org $FFFA

    word IRQ         ; NMI vector
    word START       ; RESET vector
    word IRQ         ; IRQ vector
