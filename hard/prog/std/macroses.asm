; Writes two bytes into memory
; {1} - data
; {2} - addr
    MAC WRITE_WORD
    LDA #<{1}
    STA {2}
    LDA #>{1}
    STA {2}+1
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

    MAC STRING
    DC {1}
    DC $0
    ENDM
