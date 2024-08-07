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
_OUTPUT_BUFFER_AND_MASK set $FF

_INTERRUPT_INDIRECT = $FE ; $ $FF
_BUFFER_TIMER_FLAG = $01

    SEG.U zpVars 
_BUFFER_READ_IND: DS 1
_BUFFER_WRITE_IND: DS 1
_BUFFER_FLAG: DS 1
uartStringPointer: DS 2

    SEG.U upperRam

_OUTPUT_BUFFER: DS _OUTPUT_BUFFER_AND_MASK + 1

    SEG code

INIT_UART_PRINT:
    LDA #0
    STA _BUFFER_READ_IND
    STA _BUFFER_WRITE_IND
    STA _BUFFER_FLAG
    WRITE_WORD _UART_PRINT_INTERRUPT, _INTERRUPT_INDIRECT
    ; Enable VIA T1 interrupt
    LDA #%11000000
    STA VIA_FIRST_IER
    LDA #$0
    STA VIA_FIRST_ACR

    RTS

    MAC UART_PRINTLN_STRING
        UART_PRINT_STRING {1}
        UART_PRINTLN
    ENDM

    MAC UART_PRINT_STRING
        WRITE_WORD {1}, uartStringPointer
        JSR UART_PRINT_STRING_FROM_POINTER
    ENDM

    MAC UART_PRINTLN
        TXA
        PHA
        LDA #$A ; new line ASCII
        JSR _write_to_uart
        PLA
        TAX
    ENDM

    MAC UART_PRINT_CHAR
        TXA
        PHA
        LDA #{1}
        JSR _write_to_uart
        PLA
        TAX
    ENDM

UART_PRINT_STRING_FROM_POINTER:
    TYA
    PHA
    TXA
    PHA
    subroutine
    LDY #0
.loop:
    LDA (uartStringPointer),Y
    BEQ .end
    JSR _write_to_uart
    INY
    JMP .loop
.end:
    PLA
    TAX
    PLA
    TAY
    RTS

UART_PRINT_NUMBER:
    subroutine
    STA uartStringPointer
    TXA
    PHA
    LDA uartStringPointer
    LSR
    LSR
    LSR
    LSR
    JSR _uart_print_half_humber
    LDA uartStringPointer
    AND #$F
    JSR _uart_print_half_humber
    PLA
    TAX
    RTS

_uart_print_half_humber:
    subroutine
    CMP #$A
    BCC .digit
    ADC #[$41-11] ; 'A' ASCII character - 11, because carry is set
    JMP .end
.digit:
    ADC #$30 ; '0' ASCII character
.end:
    JSR _write_to_uart
    RTS

    ; I expecting that A is pushed already
    MAC check_uart_print_interrupt
        LDA #%01000000
        AND VIA_FIRST_IFR
        BEQ .end
        JMP _UART_PRINT_INTERRUPT_V2
.end:
    ENDM

_UART_PRINT_INTERRUPT_V2:
    subroutine
    TXA
    PHA

    LDX _BUFFER_READ_IND
    CPX _BUFFER_WRITE_IND
    BEQ .buffer_end
    LDA _OUTPUT_BUFFER,X
    STA UART_DATA_REG
    INX
    TXA
    AND #_OUTPUT_BUFFER_AND_MASK
    STA _BUFFER_READ_IND
    
    JSR _set_timer
    JMP .interrupt_end
.buffer_end:
    LDA VIA_FIRST_T1C_L
    LDA #0
    STA _BUFFER_FLAG
.interrupt_end
    PLA
    TAX
    PLA ; restoring A pushed initially
    RTI

_UART_PRINT_INTERRUPT:
    subroutine
    PHA
    TXA
    PHA

    LDX _BUFFER_READ_IND
    CPX _BUFFER_WRITE_IND
    BEQ .buffer_end
    LDA _OUTPUT_BUFFER,X
    STA UART_DATA_REG
    INX
    TXA
    AND #_OUTPUT_BUFFER_AND_MASK
    STA _BUFFER_READ_IND
    
    JSR _set_timer
    JMP .interrupt_end
.buffer_end:
    LDA VIA_FIRST_T1C_L
    LDA #0
    STA _BUFFER_FLAG
.interrupt_end
    PLA
    TAX
    PLA
    RTI

UART_PRINT_WAIT_FOR_BUFFER:
    LDA _BUFFER_FLAG
    BNE UART_PRINT_WAIT_FOR_BUFFER
    RTS

; try to write A to UART
; it UART is busy then save it into buffer
_write_to_uart:
    PHA
    ; Check if timer in action
    SEI
    LDA _BUFFER_FLAG
    BNE _write_to_buffer
    ; if not, write to uart and set the timer
    CLI
    PLA
    STA UART_DATA_REG
    LDA #_BUFFER_TIMER_FLAG
    STA _BUFFER_FLAG
    JSR _set_timer
    RTS
    
    ; if yes, write to buffer if can
    ; if can't go to endlress loop
_write_to_buffer:
    subroutine
    LDX _BUFFER_WRITE_IND
    PLA
    STA _OUTPUT_BUFFER,X
    INX
    TXA
    AND #_OUTPUT_BUFFER_AND_MASK
.wait_loop:
    CMP _BUFFER_READ_IND
    BEQ .clear_interrupt_and_wait
    STA _BUFFER_WRITE_IND
    CLI
    RTS
.clear_interrupt_and_wait:
    CLI
    JMP .wait_loop

_set_timer:
    ; 6M / 9600 * 11 = $1ADB
    LDA #$DB
    STA VIA_FIRST_T1C_L
    LDA #$1A
    STA VIA_FIRST_T1C_H
    RTS
