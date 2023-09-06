    PROCESSOR 6502
    INCDIR "dasm-structure-macros/lib"
    INCLUDE "STRUCMAC.ASM"
    INCLUDE "via_macro.asm"

    DEFINE_VIA FIRST, %1000000000010000
    INCLUDE "uart_chip.asm"

; Writes two bytes into memory
; {1} - data
; {2} - addr
    MAC WRITE_WORD
    LDA #<{1}
    STA {2}
    LDA #>{1}
    STA {2}+1
    ENDM

; Writes two bytes into named var
; {1} - data
; {2} - var_name
    MAC WRITE_WORD_BY_NAME
    LDA #<{1}
    STA {2}
    LDA #>{1}
    STA _{2}_second_byte
    ENDM

; Setup reset vector
; {1} - reset
; {2} - IRQ
; {3} - NMI
    MAC RESET_VECTOR
    ORG $FFFA
    DC.W {3}
    ORG $FFFC
    DC.W {1}
    ORG $FFFE
    DC.W {2}
    ENDM

ZP_POINTER SET 0

ZP_MAX_ADDR SET $FF
; Creates named variable in zero page and check if it no up than max addr
; {1} - variable name
    MAC ALLOC
    if ZP_POINTER > ZP_MAX_ADDR
        echo "Too many variables was allocated"
        err
    endif
{1} = ZP_POINTER
ZP_POINTER SET ZP_POINTER + 1
    ENDM

; Creates named variable with length of two bytes
; {1} - variable name
    MAC ALLOC_WORD
    ALLOC {1}
    ALLOC _{1}_second_byte
    ENDM

    MAC STRING
    DC {1}
    DC $0
    ENDM
