; Writes two bytes into memory
; {1} - data
; {2} - addr
    MAC WRITE_WORD
        LDA #<{1}
        STA {2}
        LDA #>{1}
        STA {2}+1
    ENDM

; Copy two bytes from one memory location to another
; {1} - src location
; {2} - dst location
    MACRO COPY_2
        LDA {1}
        STA {2}
        LDA {1}+1
        STA {2}+1
    ENDM

; Copy four bytes from one memory location to another
; {1} - src location
; {2} - dst location
    MACRO COPY_4
        LDA {1}
        STA {2}
        LDA {1}+1
        STA {2}+1
        LDA {1}+2
        STA {2}+2
        LDA {1}+3
        STA {2}+3
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
