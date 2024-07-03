    PROCESSOR 6502
    ORG $0200
    INCDIR "../std"
    INCLUDE "std.asm"
    INCLUDE "delay.asm"

INTERRUPT_INDIRECT = $FE ; $ $FF
BUFFER_TIMER_FLAG = $01
OUTPUT_BUFFER_AND_MASK = $0F
OUTPUT_BUFFER = $7F00
    ALLOC BUFFER_READ_IND
    ALLOC BUFFER_WRITE_IND
    ALLOC BUFFER_FLAG

string:
    DC "Foo bar baz 1234567890."
    DC $0

    mac uart_log
    JSR LOG_STRING
    dc .end - .start
.start
    dc {1}
.end
    endm

main:
    LDA #0
    STA BUFFER_READ_IND
    STA BUFFER_WRITE_IND
    STA BUFFER_FLAG
    WRITE_WORD interrupt, INTERRUPT_INDIRECT
    ; Enable VIA T2 interrupt
    LDA #$A0
    STA VIA_FIRST_IER
    LDA #$0
    STA VIA_FIRST_ACR

    uart_log "Foo bar"

    JSR wait_for_buffer
    RTS

LOG_STRING:

    ; Old implementation
    LDY #0
read_string:
    LDA string,Y
    BEQ read_string_end
    JSR write_to_uart
    INY
    JMP read_string
read_string_end:

    RTS

interrupt:
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

wait_for_buffer:
    LDA BUFFER_FLAG
    BNE wait_for_buffer
    RTS

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
