    PROCESSOR 6502
    INCDIR "std"
    INCLUDE "in_ram.asm"

buf_ind = 5
buf_start = $10

read_kb:
    LDA VIA_FIRST_IFR
    LDX buf_ind
    LDA VIA_FIRST_RA
    STA buf_start,X
    INX
    STX buf_ind
    RTI

debug_start:
reset_start:
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

; Clean zero page
    LDA #$00
    LDX #$0
clean_loop:
    STA $0,X
    INX
    BNE clean_loop

    CLI

loop:
    JMP loop

