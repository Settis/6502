    INCDIR "std"
    INCLUDE "in_ram.asm"
    
    RTI

    INCLUDE "display.asm"


wdc_srt:
    DC "WDC 6502", 0

debug_start:
reset_start:
start:
    LDX #$FF
    TXS

; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$F3
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%11001100
    STA VIA_FIRST_PCR

    LDA #%00100000
    STA DISPLAY_PCR_MASK

; Init display 2
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    JSR INIT_DISPLAY

    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    WRITE_WORD wdc_srt, DISPLAY_STRING_ADDR
    JSR PRINT_STRING   

    JSR CLEAR_DISPLAY
    
    LDA #"!"
    JSR PRINT_CHAR

    LDA #"3"
    JSR PRINT_CHAR

 if STEPS = 1
    DC $FF
 else
loop:
    JMP loop
    endif
    