    SEG.U zpVars
_ZP_VARS_END = .

    SEG code
_CODE_END = .

    SEG.U upperRam
_UPPER_RAM_END = .

    ECHO "Zero page usage: ", _ZP_VARS_END

    IF _ZP_VARS_END > $FF
        ECHO "Overuse of Zero page."
        ERR
    ENDIF

    ECHO "Free RAM: ", UPPER_RAM_START - _CODE_END

    IF _CODE_END > UPPER_RAM_START
        ECHO "Code is overlaps with upper ram reserved"
        ERR
    ENDIF

    ECHO "Free reserved upper RAM: ", $8000 - _UPPER_RAM_END

    IF _UPPER_RAM_END > $8000
        ECHO "Reserved upper RAM goes over hardware RAM"
        ERR
    ENDIF

