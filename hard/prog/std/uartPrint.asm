; Start work with:
;     JSR INIT_UART_PRINT
; End work with:
;     JSR UART_PRINT_WAIT_FOR_BUFFER
; Place buffer after the main code:
;     INCLUDE uart_buffer.asm

; Example:
/*

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

*/

; You can change buffer size and place if needed
OUTPUT_BUFFER_AND_MASK set $FF

INTERRUPT_INDIRECT = $FE ; $ $FF
BUFFER_TIMER_FLAG = $01

    SEG.U zpVars 
BUFFER_READ_IND: DS 1
BUFFER_WRITE_IND: DS 1
BUFFER_FLAG: DS 1
STRING_POINTER: DS 2

    SEG.U upperRam

OUTPUT_BUFFER: DS OUTPUT_BUFFER_AND_MASK + 1

    SEG code

INIT_UART_PRINT:
    LDA #0
    STA BUFFER_READ_IND
    STA BUFFER_WRITE_IND
    STA BUFFER_FLAG
    WRITE_WORD UART_PRINT_INTERRUPT, INTERRUPT_INDIRECT
    ; Enable VIA T2 interrupt
    LDA #$A0
    STA VIA_FIRST_IER
    LDA #$0
    STA VIA_FIRST_ACR

    RTS

    MAC UART_PRINTLN_STRING
        UART_PRINT_STRING {1}
        UART_PRINTLN
    ENDM

    MAC UART_PRINT_STRING
        WRITE_WORD {1}, STRING_POINTER
        JSR UART_PRINT_STRING_SUB
    ENDM

    MAC UART_PRINTLN
        LDA #$A ; new line ASCII
        JSR write_to_uart
    ENDM

UART_PRINT_STRING_SUB:
    TYA
    PHA
    subroutine
    LDY #0
.loop:
    LDA (STRING_POINTER),Y
    BEQ .end
    JSR write_to_uart
    INY
    JMP .loop
.end:
    PLA
    TAY
    RTS

UART_PRINT_NUMBER:
    subroutine
    STA STRING_POINTER
    LSR
    LSR
    LSR
    LSR
    JSR uart_print_half_humber
    LDA STRING_POINTER
    AND #$F
    JSR uart_print_half_humber
    RTS

uart_print_half_humber:
    subroutine
    CMP #$A
    BCC .digit
    ADC #[$41-11] ; 'A' ASCII character - 11, because carry is set
    JMP .end
.digit:
    ADC #$30 ; '0' ASCII character
.end:
    JSR write_to_uart
    RTS

UART_PRINT_INTERRUPT:
    subroutine
    PHA
    TXA
    PHA

    LDX BUFFER_READ_IND
    CPX BUFFER_WRITE_IND
    BEQ .buffer_end
    LDA OUTPUT_BUFFER,X
    STA UART_DATA_REG
    INX
    TXA
    AND #OUTPUT_BUFFER_AND_MASK
    STA BUFFER_READ_IND
    
    JSR set_timer
    JMP .interrupt_end
.buffer_end:
    LDA VIA_FIRST_T2C_L
    LDA #0
    STA BUFFER_FLAG
.interrupt_end
    PLA
    TAX
    PLA
    RTI

UART_PRINT_WAIT_FOR_BUFFER:
    LDA BUFFER_FLAG
    BNE UART_PRINT_WAIT_FOR_BUFFER
    RTS

; try to write A to UART
; it UART is busy then save it into buffer
write_to_uart:
    PHA
    ; Check if timer in action
    SEI
    LDA BUFFER_FLAG
    BNE write_to_buffer
    ; if not, write to uart and set the timer
    CLI
    PLA
    STA UART_DATA_REG
    LDA #BUFFER_TIMER_FLAG
    STA BUFFER_FLAG
    JSR set_timer
    RTS
    
    ; if yes, write to buffer if can
    ; if can't go to endlress loop
write_to_buffer:
    subroutine
    LDX BUFFER_WRITE_IND
    PLA
    STA OUTPUT_BUFFER,X
    INX
    TXA
    AND #OUTPUT_BUFFER_AND_MASK
.wait_loop:
    CMP BUFFER_READ_IND
    BEQ .clear_interrupt_and_wait
    STA BUFFER_WRITE_IND
    CLI
    RTS
.clear_interrupt_and_wait:
    CLI
    JMP .wait_loop

set_timer:
    ; 6M / 9600 * 11 = $1ADB
    LDA #$DB
    STA VIA_FIRST_T2C_L
    LDA #$1A
    STA VIA_FIRST_T2C_H
    RTS
