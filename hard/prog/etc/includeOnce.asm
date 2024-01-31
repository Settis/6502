; The idea is to have a macro for include a library only once
    PROCESSOR 6502
    ORG $200

    MACRO INC_ONCE
        IFNCONST {1}
; There is no difference between those two, both not working on the second pass
;{1} = 1
{1} SET 1
            ; This is suppose to be here, but I comment it for tests
            ; INCLUDE {1}

; And this is for test only
LOOP:
    JMP LOOP

        ENDIF
    ENDM

    INC_ONCE foo
    INC_ONCE foo

    JMP bar
bar:
    JMP LOOP
