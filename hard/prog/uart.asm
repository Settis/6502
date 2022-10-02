    INCDIR "std"
    INCLUDE "std.asm"
    INCLUDE "in_ram.asm"

    ; Software UART echo

IRQ_HANDLER:
    LDA UART_STATUS_REG
    LDA UART_DATA_REG
    STA UART_DATA_REG
    RTI

debug_start:
reset_start:
    ; Set control register
    LDA #%10011110
    STA UART_CONTROL_REG

    ; Set command register
    ; LDA #%11010001 ; ECHO
    LDA #%11101001
    STA UART_COMMAND_REG

    CLI

loop:
    jmp loop

