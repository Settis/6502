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

SPACE_ASCII = $20
ZERO_ASCII = $30
CAPITAL_A_ASCII = $41

    seg.u UserArea
    org $7F00
    ; It's empty for now

    seg.u zp
    org 0
TMP:     ds 2 ; [internal] for transfering data between stacks
DP_ADDR: ds 2
SP_ADDR: ds 2
IN_ADDR: ds 2
RP_ADDR: ds 2
IP_ADDR: ds 2 ; [internal] interpretive pointer for call executor
W_ADDR:  ds 2 ; [internal] current word pointer for call executor
TEXT_ADDR: ds 2 ; [internal] pointer for initial text interpreter

    seg CODE
    org $C000
    
    MAC WRITE_WORD_TO ; 1 - data, 2 - addr
        LDA #<{1}
        STA {2}
        LDA #>{1}
        STA {2}+1
    ENDM

START:
    ; init
    WRITE_WORD_TO $0200, DP_ADDR
    WRITE_WORD_TO S0_CONST, SP_ADDR
    WRITE_WORD_TO TIB_CONST, IN_ADDR
    WRITE_WORD_TO R0_CONST, RP_ADDR

    WRITE_WORD_TO TEXT, TEXT_ADDR
TEXT_LOOP:
    JSR READ_NUMBER
    LDY #0
    LDA (TEXT_ADDR),Y
    BNE TEXT_LOOP

    BRK

READ_NUMBER:
    SUBROUTINE
    LDY #0
    STY TMP
    STY TMP+1
.digitLoop:
    LDA (TEXT_ADDR),Y ; read next character
    INC TEXT_ADDR     ; increase pointer
    BNE .skipUp
    INC TEXT_ADDR+1
.skipUp:
    CMP #SPACE_ASCII
    BNE .proceed
    JMP PUSH_TO_S
.proceed
    ; shift TMP
    LDX #4
.shifting:
    ASL TMP
    ROL TMP+1
    DEX
    BNE .shifting
    ; add number
    SEC
    SBC #ZERO_ASCII
    CMP #10
    BCC .digitChar
    ; carry is set already
    SBC #7 ; Convert ABC to hex
.digitChar:
    ORA TMP
    STA TMP
    JMP .digitLoop


; Transfering data between stacks goes via TMP 
PUSH_TO_S:
    SUBROUTINE
    LDY #$0
    LDA TMP
    STA (SP_ADDR),Y
    INY
    LDA TMP+1
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
    STA TMP
    INY
    LDA (SP_ADDR),Y
    STA TMP+1
    RTS

PUSH_TO_R:
    LDY #$0
    LDA TMP
    STA (RP_ADDR),Y
    INY
    LDA TMP+1
    STA (RP_ADDR),Y
    DEC RP_ADDR ; return stack will fit in one page, I don't care about upper byte
    DEC RP_ADDR
    RTS

PULL_FROM_R:
    INC RP_ADDR
    INC RP_ADDR
    LDY #$0
    LDA (RP_ADDR),Y
    STA TMP
    INY
    LDA (RP_ADDR),Y
    STA TMP+1
    RTS

IRQ:
    RTI

TEXT:
    dc "1 23 456 789A BCDE FFFF "
    dc 0

; system vectors

    seg VECTORS
    org $FFFA

    word IRQ         ; NMI vector
    word START       ; RESET vector
    word IRQ         ; IRQ vector
