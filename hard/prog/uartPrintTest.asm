    incdir std
    include std.asm
    org $200
    include uart_print.asm

someString:
    STRING "Hello from 6502!"
another:
    STRING "Foobar: "

main: 
    JSR INIT_UART_PRINT
    UART_PRINTLN_STRING someString
    UART_PRINT_STRING another
    LDA #$B6
    JSR UART_PRINT_NUMBER
    JSR UART_PRINT_WAIT_FOR_BUFFER
    RTS
