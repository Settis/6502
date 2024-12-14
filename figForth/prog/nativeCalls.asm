; Memory map:
;       6502 internal
;   0000..00FF pseudo registers
;   0100..01FF 6502 stack
;              Return stack `R0` & `RP` 

;       Forth
;   0200..     dictionary `DP`
;       ..     PAD
;       ..7DFF data stack `S0` & `SP`
;   7E00..7EFF `TIB` (terminal input buffer) & `IN`
;   7F00..7F7F UART input buffer
;   7F80..7FFF user area

; Constants
; S0  = 7DFF
; TIB = 7E00

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
;     | actual code|
;     |   ...      |

    PROCESSOR 6502

IN_RAM = 1

S0_CONST = $7DFE
TIB0_CONST = $7E00

; Debug output
DEBUG_EXECUTE = 0
DEBUG_DOCOL = 0
DEBUG_NEXT = 0
DEBUG_DOSEMICOL = 0
DEBUG_CLEAN_STACK = 0

    seg.u UARTInputBuffer
UART_INPUT_BUFFER_ADDR = $7F00
    org UART_INPUT_BUFFER_ADDR

    seg.u UserArea
    org $7F80
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
IP_ADDR: ds 2 ; [internal] interpretive pointer for call executor
W_ADDR:  ds 2 ; [internal] current word pointer for call executor
FORTH_VOCABULARY: ds 2
STATE_VALUE: ds 2
UART_PRINT_STRING_ADDR: ds 2 ; [for debug]
TIMER_COUNTER: ds 2
TIMER_START_VALUE: ds 2
UART_input_buffer_start: ds 1
UART_input_buffer_end: ds 1

    seg CODE
    
    IF IN_RAM = 1
        org $0200
    ELSE
        org $C000
    ENDIF
    
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

MAIN:
START:
    JSR INIT_HW

    LDA #0
    STA UART_input_buffer_start
    STA UART_input_buffer_end

    CLI

    ; init
    IF IN_RAM = 1
        WRITE_WORD_TO END_OF_CODE, DP_ADDR
    ELSE
        WRITE_WORD_TO $0200, DP_ADDR
    ENDIF
    WRITE_WORD_TO S0_CONST, SP_ADDR
    WRITE_WORD_TO 0, TIB_ADDR
    WRITE_WORD_TO TEXT, IN_ADDR
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
    LDA #$20 ; JSR
    JSR F_WORD_COMMA_CHAR_SUBROUTINE
    JSR F_WORD_COMMA_SUBROUTINE
    JMP .endTextLoop
.executeWord:
    JSR PULL_FROM_S
    ; self modified code!
    IF IN_RAM = 0
        ECHO "It can't run in ROM"
        ERR
    ENDIF
    COPY_WORD_TO STACK_TMP, jsrCommand+1
jsrCommand:
    JSR $FFFF
    JMP .endTextLoop

.parseNumber:
    JSR READ_NUMBER
    LDA STATE_VALUE
    BEQ .endTextLoop
    LDA #$20 ; JSR
    JSR F_WORD_COMMA_CHAR_SUBROUTINE
    LDA #<READ_LITERAL
    JSR F_WORD_COMMA_CHAR_SUBROUTINE
    LDA #>READ_LITERAL
    JSR F_WORD_COMMA_CHAR_SUBROUTINE
    JSR F_WORD_COMMA_SUBROUTINE
.endTextLoop:
    ; check if it's end of the text
    LDY #0
    LDA (IN_ADDR),Y
    BNE TEXT_LOOP

    PRINT_STRING "Stack:"
    JSR PRINT_NEW_LINE
    JSR PRINT_STACK
    RTS

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

    MACRO PUSH_TO_R
        LDA STACK_TMP
        PHA
        LDA STACK_TMP+1
        PHA
    ENDM

    MACRO PULL_FROM_R
        PLA
        STA STACK_TMP+1
        PLA
        STA STACK_TMP
    ENDM

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

CREATE_DICTIONARY_HEADER: ; ( -- ) reads the next word for a name
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
    RTS

F_WORD_COMMA_SUBROUTINE: ; , ( n -- )
    JSR PULL_FROM_S
F_WORD_COMMA_SUBROUTINE_FROM_STACK_TMP:
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

F_WORD_COMMA_CHAR_SUBROUTINE: ; from A
    LDY #0
    STA (DP_ADDR),Y

    SUBROUTINE
    INC DP_ADDR
    BNE .skip
    INC DP_ADDR+1
.skip:
    RTS

DOCOL:
    COPY_WORD_TO IP_ADDR, STACK_TMP
    PUSH_TO_R
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
    PULL_FROM_R
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
    JSR PULL_FROM_S
    PLA 
    TAX
    PLA
    TAY
    PUSH_TO_R
    TYA
    PHA
    TXA
    PHA
    RTS

F_WORD_FROM_RETURN_STACK: ; R>
    DC 2  | $80
    DC 'R
    DC '> | $80
    DC.W F_WORD_TO_RETURN_STACK
    PLA 
    TAX
    PLA
    TAY
    PULL_FROM_R
    TYA
    PHA
    TXA
    PHA
    JSR PUSH_TO_S
    RTS

F_WORD_READ_FROM_ADDR: ; @
    DC 1   | $80
    DC '@  | $80
    DC.W F_WORD_FROM_RETURN_STACK
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

    JSR PULL_FROM_S
    COPY_WORD_TO STACK_TMP, INTERNAL_TMP
    JSR PULL_FROM_S
    LDY #0
    LDA STACK_TMP
    STA (INTERNAL_TMP),Y
    INY
    LDA STACK_TMP+1
    STA (INTERNAL_TMP),Y
    RTS

F_WORD_PLUS: ; +
    DC 1  | $80
    DC '+ | $80
    DC.W F_WORD_WRITE_TO_ADDR
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
    JMP PUSH_TO_S

F_WORD_MUL_BY_2: ; 2*
    DC 2  | $80
    DC '2
    DC '* | $80
    DC.W F_WORD_PLUS
    JSR PULL_FROM_S
    ASL STACK_TMP
    ROL STACK_TMP+1
    JMP PUSH_TO_S

F_WORD_DIV_BY_2: ; 2/
    DC 2  | $80
    DC '2
    DC '/ | $80
    DC.W F_WORD_MUL_BY_2
    JSR PULL_FROM_S
    LSR STACK_TMP+1
    ROR STACK_TMP
    JMP PUSH_TO_S

F_WORD_NAND: ; NAND
    DC 4  | $80
    DC "NAN"
    DC 'D | $80
    DC.W F_WORD_DIV_BY_2
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
    JMP PUSH_TO_S

F_WORD_EQUALS_0: ; 0=
    DC 2  | $80
    DC '0
    DC '= | $80
    DC.W F_WORD_NAND
    SUBROUTINE
    JSR PULL_FROM_S
    LDA STACK_TMP
    BNE .notZero
    LDA STACK_TMP+1
    BNE .notZero
    JMP PUSH_TRUE_TO_S
.notZero:
    JMP PUSH_FALSE_TO_S

F_WORD_FIND_INT: ; (FIND)
    DC 6  | $80
    DC "(FIND"
    DC ') | $80
    DC.W F_WORD_EQUALS_0
    JMP FIND_IN_DICTIONARY

F_WORD_WORD_INT: ; (WORD)
    DC 6  | $80
    DC "(WORD"
    DC ') | $80
    DC.W F_WORD_FIND_INT
    JMP COPY_WORD_FROM_TEXT

F_WORD_EXECUTE: ; EXECUTE TODO:rewrite
    DC 7  | $80
    DC "EXECUT"
    DC 'E | $80
    DC.W F_WORD_WORD_INT
    DC.W EXECUTE

F_WORD_COMMA: ; ,
    DC 1  | $80
    DC ', | $80
    DC.W F_WORD_EXECUTE
    JMP F_WORD_COMMA_SUBROUTINE

F_WORD_CONSTANT: ; CONSTANT
    DC 8  | $80
    DC "CONSTAN"
    DC 'T | $80
    DC.W F_WORD_COMMA

    JSR CREATE_DICTIONARY_HEADER
    JSR PULL_FROM_S
    JSR WRITE_CODE_LOAD_TO_S
    JMP UPDATE_DP_ADDR_FROM_Y

WRITE_CODE_LOAD_TO_S: ; from STACK_TMP
    LDY #0

    ; JSR READ_LITERAL
    LDA #$20 ; JSR absolute
    STA (DP_ADDR),Y
    INY
    LDA #<READ_LITERAL
    STA (DP_ADDR),Y
    INY
    LDA #>READ_LITERAL
    STA (DP_ADDR),Y
    INY

    ; the literal from STACK_TMP
    LDA STACK_TMP
    STA (DP_ADDR),Y
    INY
    LDA STACK_TMP+1
    STA (DP_ADDR),Y
    INY

    ; RTS
    LDA #$60 ; JSR absolute
    STA (DP_ADDR),Y
    INY

    RTS

UPDATE_DP_ADDR_FROM_Y:
    CLC
    TYA
    ADC DP_ADDR
    STA DP_ADDR
    LDA DP_ADDR+1
    ADC #0
    STA DP_ADDR+1   ; Update dictionary pointer
    RTS

READ_LITERAL:
    PLA
    STA INTERNAL_TMP
    PLA
    STA INTERNAL_TMP+1
    LDY #1
    LDA (INTERNAL_TMP),Y
    STA STACK_TMP
    INY
    LDA (INTERNAL_TMP),Y
    STA STACK_TMP+1
    JSR PUSH_TO_S
    CLC
    LDA #2
    ADC INTERNAL_TMP
    STA INTERNAL_TMP
    LDA #0
    ADC INTERNAL_TMP+1
    PHA
    LDA INTERNAL_TMP
    PHA
    RTS

    MACRO F_CONSTANT
        WRITE_WORD_TO {1}, STACK_TMP
        JSR PUSH_TO_S
        RTS
    ENDM

F_WORD_VARIABLE: ; VARIABLE
    DC 8  | $80
    DC "VARIABL"
    DC 'E | $80
    DC.W F_WORD_CONSTANT

    JSR CREATE_DICTIONARY_HEADER
    COPY_WORD_TO DP_ADDR, STACK_TMP
    CLC
    LDA #6 ; offset for code that loads data to stack
    ADC STACK_TMP
    STA STACK_TMP
    LDA STACK_TMP+1
    ADC #0
    STA STACK_TMP+1

    JSR WRITE_CODE_LOAD_TO_S
    INY ; reserve two bytes for the value
    INY
    JMP UPDATE_DP_ADDR_FROM_Y

F_WORD_DP: ; DP
    DC 2  | $80
    DC 'D
    DC 'P | $80
    DC.W F_WORD_VARIABLE
    F_CONSTANT DP_ADDR

F_WORD_TIB: ; TIB
    DC 3  | $80
    DC "TI"
    DC 'B | $80
    DC.W F_WORD_DP
    F_CONSTANT TIB_ADDR

F_WORD_IN: ; IN
    DC 2  | $80
    DC 'I
    DC 'N | $80
    DC.W F_WORD_TIB
    F_CONSTANT IN_ADDR
    
F_WORD_STATE: ; STATE
    DC 5  | $80
    DC "STAT"
    DC 'E | $80
    DC.W F_WORD_IN
    F_CONSTANT STATE_VALUE

F_WORD_FORTH: ; FORTH
    DC 5  | $80
    DC "FORT"
    DC 'H | $80
    DC.W F_WORD_STATE
    F_CONSTANT FORTH_VOCABULARY

F_WORD_COLON: ; :
    DC 1  | $80
    DC ': | $80
    DC.W F_WORD_FORTH
    JSR CREATE_DICTIONARY_HEADER
    LDA #$C0
    STA STATE_VALUE
    RTS

F_WORD_SEMICOLON: ; ;
    DC 1  | $80 | $40
    DC '; | $80
    DC.W F_WORD_COLON

    LDA #$60 ; RTS
    JSR F_WORD_COMMA_CHAR_SUBROUTINE
    LDA #0
    STA STATE_VALUE
    RTS

F_WORD_BRANCH: ; BRANCH
    DC 6  | $80
    DC "BRANC"
    DC 'H | $80
    DC.W F_WORD_SEMICOLON

    SUBROUTINE
    PLA
    STA STACK_TMP
    PLA
    STA STACK_TMP+1
    INC STACK_TMP
    BNE .skip
    INC STACK_TMP+1
.skip:
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JSR PULL_FROM_S

    LDA STACK_TMP
    BNE .skipDec
    DEC STACK_TMP+1
.skipDec:
    DEC STACK_TMP

    LDA STACK_TMP+1
    PHA
    LDA STACK_TMP
    PHA
    RTS

F_WORD_0BRANCH: ; 0BRANCH
    DC 7  | $80
    DC "0BRANC"
    DC 'H | $80
    DC.W F_WORD_BRANCH

    SUBROUTINE

    JSR PULL_FROM_S
    LDA STACK_TMP
    BNE .noBranch
    LDA STACK_TMP+1
    BNE .noBranch

.doBranch:
    PLA
    STA STACK_TMP
    PLA
    STA STACK_TMP+1
    INC STACK_TMP
    BNE .skip
    INC STACK_TMP+1
.skip:
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_SUBROUTINE
    JSR PULL_FROM_S

    LDA STACK_TMP
    BNE .skipDec
    DEC STACK_TMP+1
.skipDec:
    DEC STACK_TMP
    JMP .end

.noBranch:
    CLC
    PLA
    ADC #2
    STA STACK_TMP
    PLA
    ADC #0
    STA STACK_TMP+1
    
.end:
    LDA STACK_TMP+1
    PHA
    LDA STACK_TMP
    PHA
    RTS

F_WORD_EMIT: ; EMIT
    DC 4  | $80
    DC "EMI"
    DC 'T | $80
    DC.W F_WORD_0BRANCH
    JSR PULL_FROM_S
    LDA STACK_TMP
    JMP PRINT_CHAR

F_WORD_KEY: ; key
    DC 3  | $80
    DC "KE"
    DC 'Y | $80
    DC.W F_WORD_EMIT
    SUBROUTINE
.loop:
    LDX UART_input_buffer_start
    CPX UART_input_buffer_end
    BEQ .loop
    LDA UART_INPUT_BUFFER_ADDR,X
    STA STACK_TMP
    LDA #0
    STA STACK_TMP+1
    INX
    TXA
    AND #$7F
    STA UART_input_buffer_start
    JMP PUSH_TO_S

F_WORD_RESET_TIB: ; TIB!
    DC 4  | $80
    DC "TIB"
    DC '! | $80
    DC.W F_WORD_KEY
    WRITE_WORD_TO TIB0_CONST, TIB_ADDR
    RTS

F_WORD_RESET_SP: ; SP!
    DC 3  | $80
    DC "SP"
    DC '! | $80
    DC.W F_WORD_RESET_TIB
    WRITE_WORD_TO S0_CONST, SP_ADDR
    RTS

F_WORD_RESET_RP: ; RP!
    DC 3  | $80
    DC "RP"
    DC '! | $80
    DC.W F_WORD_RESET_SP
    LDX #$FF
    TXS
    RTS

F_WORD_SP_ADDR: ; SP@
    DC 3  | $80
    DC "SP"
    DC '@ | $80
    DC.W F_WORD_RESET_RP
    COPY_WORD_TO SP_ADDR, STACK_TMP
    JMP PUSH_TO_S 

F_WORD_S0: ; S0
    DC 2  | $80
    DC 'S
    DC '0 | $80
    DC.W F_WORD_SP_ADDR
    WRITE_WORD_TO S0_CONST, STACK_TMP
    JMP PUSH_TO_S

F_WORD_DOCOL: ; (DOCOL)
    DC 7  | $80
    DC "(DOCOL"
    DC ') | $80
    DC.W F_WORD_S0
    F_CONSTANT DOCOL

F_WORD_DOVAR: ; (DOVAR)  TODO: rewrite
    DC 7  | $80
    DC "(DOVAR"
    DC ') | $80
    DC.W F_WORD_DOCOL
    F_CONSTANT $FFFF

F_WORD_DOCONST: ; (DOCONST) TODO: delete maybe
    DC 9  | $80
    DC "(DOCONST"
    DC ') | $80
    DC.W F_WORD_DOVAR
    F_CONSTANT 1234

F_WORD_T_CNT: ; T_CNT
    DC 5  | $80
    DC "T_CN"
    DC 'T | $80
    DC.W F_WORD_DOCONST
    F_CONSTANT TIMER_COUNTER

F_WORD_T_START_VAL: ; T_START_VAL
    DC 11 | $80
    DC "T_START_VA"
    DC 'L | $80
    DC.W F_WORD_T_CNT
    F_CONSTANT TIMER_START_VALUE

F_WORD_T_START: ; T_START
    DC 7  | $80
    DC "T_STAR"
    DC 'T | $80
    DC.W F_WORD_T_START_VAL
    LDA #%01000000
    STA VIA_AUXILARY_CONTROL
    LDA #0
    STA TIMER_COUNTER
    STA TIMER_COUNTER+1
    LDA TIMER_START_VALUE
    STA T1COUNTER_L
    LDA TIMER_START_VALUE+1
    STA T1COUNTER_H
    RTS

F_WORD_T_STOP: ; T_STOP
    DC 6  | $80
    DC "T_STO"
    DC 'P | $80
    DC.W F_WORD_T_START
    LDA #%00000000
    STA VIA_AUXILARY_CONTROL
    RTS

F_WORD_BENCHMARK:
LAST_F_WORD:
    DC 9  | $80
    DC "BENCHMAR"
    DC 'K | $80
    DC.W F_WORD_T_STOP
    F_CONSTANT BENCHMARK

IRQ:
    SUBROUTINE
    PHA
    LDA IOSTATUS
    AND #$80
    BEQ .timer
.keyboard_interrupt:
    TXA
    PHA
    LDX UART_input_buffer_end
    LDA IOBASE
    STA UART_INPUT_BUFFER_ADDR,X
    INX
    TXA
    AND #$7F
    STA UART_input_buffer_end
    PLA
    TAX
    JMP .other
.timer:
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
    INCBIN "fullNative.txt"
    dc " "
    dc 0

BENCHMARK:
    INCBIN "benchmark.txt"
    dc " "
    dc 0

IOBASE   = %1000000000100000
IOSTATUS = IOBASE + 1
IOCMD    = IOBASE + 2
IOCTRL   = IOBASE + 3

VIABASE     = %1000000000010000
T1COUNTER_L = VIABASE + $4
T1COUNTER_H = VIABASE + $5
T1LATCH_L   = VIABASE + $6
T1LATCH_H   = VIABASE + $7
VIA_AUXILARY_CONTROL = VIABASE + $B
VIA_IER     = VIABASE + $E
VIA_IFR     = VIABASE + $D

INIT_HW:
    LDA #%11000000 ; enable T1 interrupts
    STA VIA_IER
    IF IN_RAM = 1
        WRITE_WORD_TO IRQ, $FE
    ENDIF
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
    LDA #$0A
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

    JSR WAIT

        PLA             ; Otherwise, load saved accumulator,
        STA IOBASE      ; write to output,
        ; CMP #$0D        ; check if it was CR
        ; BNE .END
        ; LDA #$0A        ; then output LF too
        ; PHA
        ; JMP .ECHO1
.END:    RTS             ; and return


WAIT:
    SUBROUTINE
    TXA
    PHA
    TYA
    PHA

    LDX #$F0
.loop:
    LDY #$F0
.innerLoop:
    DEY
    BNE .innerLoop
    DEX
    BNE .loop

    PLA
    TAY
    PLA
    TAX
    RTS

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

END_OF_CODE:

; system vectors

    IF IN_RAM = 0

        seg VECTORS
        org $FFFA

        word IRQ         ; NMI vector
        word START       ; RESET vector
        word IRQ         ; IRQ vector

    ENDIF
