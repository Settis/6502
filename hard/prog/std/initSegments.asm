    SEG.U zpVars
    ORG $0

    IFNCONST CODE_START
CODE_START = $200
    ENDIF

    SEG code
    ORG CODE_START

    IFNCONST UPPER_RAM_START
UPPER_RAM_START = $7FFF
    ENDIF

    SEG.U upperRam
    ORG UPPER_RAM_START
