    INCDIR "std"
    ; for in memory
    INCLUDE "in_ram.asm"

    ; for in ROM
    ;org $FF00
    ;INCLUDE "std.asm"

    INCLUDE "delay.asm"

    ; for in ROM

debug_start:
reset_start:
start:

    LDA #$FF
    STA VIA_FIRST_DDRB
    LDA #$FF
    STA VIA_FIRST_RB
loop:
; setup delay
    ; LDA #$FF
    ; STA DELAY_X
    ; LDA #$FF
    ; STA DELAY_Y
    ; JSR delayxy
    ; LDA #$FF
    ; STA DELAY_X
    ; LDA #$FF
    ; STA DELAY_Y
    ; JSR delayxy
    INC VIA_FIRST_RB
    JMP loop
 
    DC $FF

    ; For in ROM
    ;RESET_VECTOR reset_start, start, debug_start
