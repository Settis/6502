; fills ZP and stack with 00 and resets
; After that you can clearly see what walues was changed
; Designed for runned via UART

    PROCESSOR 6502
    .org $0200

UART_RUN_COMMAND = 4
UART_DATA_REG = %1000000000100000

main:
    ; set interrupt so no one can interrupt us
    SEI
    ; report that the command was ended
    LDA #UART_RUN_COMMAND
    STA UART_DATA_REG

    ; reset stack pointer
    LDX #$FF
	TXS

    ; Fill ZP
    LDX #0
    LDA #0
    SUBROUTINE
.loop:
    STA 0,X
    INX
    BNE .loop

    ; Fill stack
    SUBROUTINE
.loop:
    STA $100,X
    INX
    BNE .loop

    JMP ($FFFC)
    RTS
