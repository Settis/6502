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
TIB_CONST = $7E00
R0_CONST = $7EFE

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
IN_ADDR: ds 2
RP_ADDR: ds 2
IP_ADDR: ds 2 ; [internal] interpretive pointer for call executor
W_ADDR:  ds 2 ; [internal] current word pointer for call executor
TEXT_ADDR: ds 2 ; [internal] pointer for initial text interpreter
CONTEXT_VALUE: ds 2
STATE_VALUE: ds 2
UART_PRINT_STRING_ADDR: ds 2 ; [for debug]

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
    JSR INIT_UART

    ; init
    WRITE_WORD_TO $0200, DP_ADDR
    WRITE_WORD_TO S0_CONST, SP_ADDR
    WRITE_WORD_TO TIB_CONST, IN_ADDR
    WRITE_WORD_TO R0_CONST, RP_ADDR
    WRITE_WORD_TO LAST_F_WORD, CONTEXT_VALUE
    WRITE_WORD_TO 0, STATE_VALUE

    WRITE_WORD_TO TEXT, TEXT_ADDR
TEXT_LOOP:
    JSR COPY_WORD_FROM_TEXT

    COPY_WORD_TO DP_ADDR, STACK_TMP
    JSR PUSH_TO_S
    COPY_WORD_TO CONTEXT_VALUE, STACK_TMP
    JSR PUSH_TO_S
    JSR FIND_IN_DICTIONARY

    JSR PULL_FROM_S
    LDA STACK_TMP
    BEQ .parseNumber

    JSR PULL_FROM_S 
    COPY_WORD_TO STACK_TMP, INTERNAL_TMP ; name size in internal tmp
    CLC 
    LDA INTERNAL_TMP
    ADC #3
    STA INTERNAL_TMP  ; name size + LFA size + 1 for the first byte in NFA
    JSR PULL_FROM_S ; pull PFA
    SEC
    LDA STACK_TMP
    SBC #2
    STA STACK_TMP
    LDA STACK_TMP+1
    SBC #0
    STA STACK_TMP+1
    JSR PUSH_TO_S  ; convert PFA to CFA

    SEC
    LDA STACK_TMP
    SBC INTERNAL_TMP
    STA INTERNAL_TMP
    LDA STACK_TMP+1
    SBC INTERNAL_TMP+1
    STA INTERNAL_TMP+1 ; INTERNAL_TMP contains pointer to NFA

    LDX #0
    LDA (INTERNAL_TMP,X)
    CMP STATE_VALUE  ; check if we need to run or compile this word
    BCS .executeWord
.compileWord:
    JSR F_WORD_COMMA_CODE
    JMP .endTextLoop
.executeWord:
    WRITE_WORD_TO JMP_END_TEXT_LOOP_WORDS, IP_ADDR
    JSR EXECUTE
    JMP .endTextLoop

JMP_END_TEXT_LOOP_WORDS:
    DC.W JMP_END_TEXT_LOOP_ADDR
    DC.W JMP_END_TEXT_LOOP_ADDR
JMP_END_TEXT_LOOP_ADDR:
    DC.W .endTextLoop

.parseNumber:
    JSR READ_NUMBER
.endTextLoop:
    ; check if it's end of the text
    LDY #0
    LDA (TEXT_ADDR),Y
    BNE TEXT_LOOP

    PRINT_STRING "Stack:"
    JSR PRINT_NEW_LINE
    JSR PRINT_STACK
    BRK

COPY_WORD_FROM_TEXT:
    SUBROUTINE
    COPY_WORD_TO DP_ADDR, STACK_TMP
    INC STACK_TMP
    BNE .skipUp
    INC STACK_TMP+1
.skipUp:
    LDY #0
.copyLoop:
    LDA (TEXT_ADDR),Y
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
    ADC TEXT_ADDR
    STA TEXT_ADDR
    LDA TEXT_ADDR+1
    ADC #0
    STA TEXT_ADDR+1
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
    LDA TMP_LENGTH
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
    JSR PUSH_FALSE_TO_S
    RTS

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
.digitChar:
    ORA STACK_TMP
    STA STACK_TMP
    CPY TMP_LENGTH ; check size
    BNE .digitLoop
    JMP PUSH_TO_S

DEBUG_EXECUTE = 1
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
    JSR F_WORD_READ_FROM_ADDR_CODE
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
    INY
    LDA (SP_ADDR),Y
    STA STACK_TMP+1
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
    INY
    LDA (RP_ADDR),Y
    STA STACK_TMP+1
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
    LDA CONTEXT_VALUE
    STA (DP_ADDR),Y
    INY
    LDA CONTEXT_VALUE+1
    STA (DP_ADDR),Y   ; LFA set
    COPY_WORD_TO DP_ADDR, CONTEXT_VALUE ; Update context value

    INY
    CLC
    TYA
    ADC DP_ADDR
    STA DP_ADDR
    LDA DP_ADDR+1
    ADC #0
    STA DP_ADDR+1   ; Update dictionary pointer

    JSR F_WORD_COMMA_CODE ; CFA set

    RTS

F_WORD_COMMA_CODE: ; , ( n -- )
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

DEBUG_DOCOL = 1
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
    JSR NEXT
    RTS

DEBUG_NEXT = 1 
NEXT:
    COPY_WORD_TO IP_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_CODE
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
    JSR F_WORD_READ_FROM_ADDR_CODE
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
DEBUG_DOSEMICOL = 1
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
    JSR NEXT
    RTS

;  ======= Forth words ========    
F_WORD_TO_RETURN_STACK: ; >R
    DC 2  | $80
    DC '>
    DC 'R | $80
    DC.W 0
    DC.W F_WORD_TO_RETURN_STACK_CODE
F_WORD_TO_RETURN_STACK_CODE:    
    JSR PULL_FROM_S
    JMP PUSH_TO_R

F_WORD_FROM_RETURN_STACK: ; R>
    DC 2  | $80
    DC 'R
    DC '> | $80
    DC.W F_WORD_TO_RETURN_STACK
    DC.W F_WORD_FROM_RETURN_STACK_CODE
F_WORD_FROM_RETURN_STACK_CODE:
    JSR PULL_FROM_R
    JMP PUSH_TO_S

F_WORD_READ_FROM_ADDR: ; @
    DC 1   | $80
    DC '@  | $80
    DC.W F_WORD_FROM_RETURN_STACK
    DC.W F_WORD_READ_FROM_ADDR_CODE
F_WORD_READ_FROM_ADDR_CODE:
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
    RTS

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
    JMP PUSH_TO_S

F_WORD_NAND: ; NAND
    DC 4  | $80
    DC "NAN"
    DC 'D | $80
    DC.W F_WORD_MUL_BY_2
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
    JMP PUSH_TO_S

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
    JMP PUSH_TRUE_TO_S
.notZero:
    JMP PUSH_FALSE_TO_S

F_WORD_FIND_INT: ; (FIND)
    DC 6  | $80
    DC "(FIND"
    DC ') | $80
    DC.W F_WORD_EQUALS_0
    DC.W FIND_IN_DICTIONARY

F_WORD_EXECUTE: ; EXECUTE
    DC 7  | $80
    DC "EXECUT"
    DC 'E | $80
    DC.W F_WORD_FIND_INT
    DC.W EXECUTE

F_WORD_COMMA: ; ,
    DC 1  | $80
    DC ', | $80
    DC.W F_WORD_EXECUTE
    DC.W F_WORD_COMMA_CODE

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

    JSR F_WORD_COMMA_CODE ; store constant
    RTS
F_WORD_CONSTANT_RUNTIME:
    COPY_WORD_TO W_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_READ_FROM_ADDR_CODE
    RTS

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
    JSR F_WORD_COMMA_CODE
    RTS
F_WORD_VARIABLE_RUNTIME:
    COPY_WORD_TO W_ADDR, STACK_TMP
    JSR PUSH_TO_S
    RTS

F_WORD_DP:
    DC 2  | $80
    DC 'D
    DC 'P | $80
    DC.W F_WORD_VARIABLE
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W DP_ADDR

F_WORD_SP:
    DC 2  | $80
    DC 'S
    DC 'P | $80
    DC.W F_WORD_DP
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W SP_ADDR
    
F_WORD_STATE:
    DC 5  | $80
    DC "STAT"
    DC 'E | $80
    DC.W F_WORD_SP
    DC.W F_WORD_CONSTANT_RUNTIME
    DC.W STATE_VALUE

F_WORD_COLON:
    DC 1  | $80
    DC ': | $80
    DC.W F_WORD_STATE
    DC.W F_WORD_COLON_CODE
F_WORD_COLON_CODE:
    WRITE_WORD_TO DOCOL, STACK_TMP
    JSR PUSH_TO_S
    JSR CREATE_DICTIONARY_HEADER_WITH_CFA
    LDA #$C0
    STA STATE_VALUE
    RTS

F_WORD_SEMICOLON:
LAST_F_WORD:
    DC 1  | $80 | $40
    DC '; | $80
    DC.W F_WORD_COLON
    DC.W F_WORD_SEMICOLON_CODE
F_WORD_SEMICOLON_CODE:
    WRITE_WORD_TO DOSEMICOL_ADDR, STACK_TMP
    JSR PUSH_TO_S
    JSR F_WORD_COMMA_CODE
    LDA #0
    STA STATE_VALUE
    RTS

IRQ:
    RTI

TEXT:
    dc "3 120 2000 : plus + ; : combo plus plus ; combo "
    dc 0



IOBASE   = $8800
IOSTATUS = IOBASE + 1
IOCMD    = IOBASE + 2
IOCTRL   = IOBASE + 3

INIT_UART:
    LDA #$09
    STA IOCMD      ; Set command status
    LDA #$1A
    STA IOCTRL     ; 0 stop bits, 8 bit word, 2400 baud
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


; system vectors

    seg VECTORS
    org $FFFA

    word IRQ         ; NMI vector
    word START       ; RESET vector
    word IRQ         ; IRQ vector
