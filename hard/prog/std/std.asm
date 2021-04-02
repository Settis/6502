    INCDIR "std"
    INCLUDE "via_macro.asm"

    DEFINE_VIA FIRST, %1000000000010000

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

    ORG $0C00
