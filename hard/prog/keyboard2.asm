    INCDIR "std"
    INCLUDE "std.asm"

buf_ind = 5
buf_start = $10

start:
; Enable CA1 interrupt
    LDA #$82
    STA VIA_FIRST_IER

; Disable latch
    LDA #$00
    STA VIA_FIRST_ACR

; CA1 interrupts on positive edge
    LDA #$01
    STA VIA_FIRST_PCR

; Setup port directions
    LDA #$00
    STA VIA_FIRST_DDRA

    LDA VIA_FIRST_IFR
    LDA VIA_FIRST_RA

    CLI

    LDY #$05

loop:
    CPY buf_ind
    BCC end
    JMP loop

read_kb:
    LDA VIA_FIRST_IFR
    LDX buf_ind
    LDA VIA_FIRST_RA
    STA buf_start,X
    INX
    STX buf_ind
    RTI

end:

    RESET_VECTOR start, read_kb, start
