    PROCESSOR 6502
CODE_START = $300
    INCLUDE "../std/std.asm"

    SEG code
main:
    LDA #$FF
    STA VIA_FIRST_DDRA

loop:
    LDA #0
    STA VIA_FIRST_RA
    JSR wait
    LDA #$FF
    STA VIA_FIRST_RA
    JSR wait
    JMP loop

wait:
    FOR_X 0, UP_TO, $FF
        FOR_Y 0, UP_TO, $FF
            NOP
            NOP
            NOP
            NOP
            NOP
        NEXT_Y
    NEXT_X
    RTS
