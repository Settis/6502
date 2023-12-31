    INCDIR "../std"
    INCLUDE "std.asm"

    .org $0200

; SD conntected to port B
; CS   - P4
; MOSI - P6 / to SD
; SCK  - P5
; MISO - P7 / from SD

    ALLOC RESPONSE
SEND_BYTE = RESPONSE
; They must be sequential from CRC to CMD
    ALLOC CRC
    ALLOC ARG_0
    ALLOC ARG_1
    ALLOC ARG_2
    ALLOC ARG_3
    ALLOC CMD

main:
    JSR INIT_UART_PRINT
    JSR initSD
    JSR readData
    JSR UART_PRINT_WAIT_FOR_BUFFER
    RTS

    include uart_print.asm
    INCLUDE "delay.asm"

sendCmd0Msg:
    STRING "Send CMD0"

sendCmd55Msg:
    STRING "Send CMD41 & CMD55"

sendCmd8Msg:
    STRING "Send CMD8"

sendCmdRead:
    STRING "Read data from card"

initSD:
    ; Disable all interrupts
    ; I need a timer for uart logs
    ; LDA #$7F
    ; STA VIA_FIRST_IER
    ; Setup output pins
    LDA #%01110000
    STA VIA_FIRST_DDRB
    ; Disable SD
    LDA #%00010000
    STA VIA_FIRST_RB
    ; Wait > 1ms after power up
    delay 100, 95
    
    ; Dummy clock for enable native command mode
    subroutine
    ; CS = DI = HIGH
    LDA #%01010000
    STA VIA_FIRST_RB
    LDX #80
.loop:
    LDA #%01110000
    STA VIA_FIRST_RB
    LDA #%01010000
    STA VIA_FIRST_RB
    DEX
    BNE .loop

    UART_PRINTLN_STRING sendCmd0Msg
    ; Send CMD0 =============================
    LDA #$40
    STA CMD
    LDA #0
    STA ARG_0
    STA ARG_1
    STA ARG_2
    STA ARG_3
    LDA #$95
    STA CRC

    subroutine
    LDA #$4
    PHA
.loop:
    JSR sendSDCommand
    LDA RESPONSE
    CMP #$1
    BEQ .end
    JSR UART_PRINT_NUMBER
    PLA
    SEC
    SBC #1
    PHA
    BNE .loop
.end:
    PLA

    UART_PRINTLN

    UART_PRINTLN_STRING sendCmd8Msg

    LDA #[ 8 | $40 ]
    STA CMD
    LDA #$1
    STA ARG_1
    LDA #$AA
    STA ARG_0
    LDA #$87
    STA CRC
    JSR sendSDCommandAndReadR3R7
    
    LDA CMD
    JSR UART_PRINT_NUMBER
    LDA ARG_3
    JSR UART_PRINT_NUMBER
    LDA ARG_2
    JSR UART_PRINT_NUMBER
    LDA ARG_1
    JSR UART_PRINT_NUMBER
    LDA ARG_0
    JSR UART_PRINT_NUMBER

    UART_PRINTLN

    subroutine
    UART_PRINTLN_STRING sendCmd55Msg
    ; Send CMD41 with leading CMD55
    LDA #$F0
    PHA
.loop
    LDA #[55 | $40]
    STA CMD
    LDA #0
    STA ARG_0
    STA ARG_1
    STA ARG_2
    STA ARG_3
    JSR sendSDCommand
    LDA RESPONSE
    JSR UART_PRINT_NUMBER

    LDA #[41 | $40]
    STA CMD
    LDA #$40
    STA ARG_3
    JSR sendSDCommand
    LDA RESPONSE
    CMP #$0 ; R1 Ready
    BEQ .end
    JSR UART_PRINT_NUMBER
    delay 250, 250
    PLA
    SEC
    SBC #1
    PHA
    BNE .loop
.end:
    PLA


    ; Disable SD
    LDA #%00010000
    STA VIA_FIRST_RB
    RTS


readData:
    UART_PRINTLN_STRING sendCmdRead
    LDA #[ 17 | $40 ]
    STA CMD
    LDA #$0
    STA ARG_0
    STA ARG_1
    STA ARG_2
    STA ARG_3
    STA CRC
    JSR sendSDCommandAndReadData
    RTS

; You must prepare the command, arg and crc
; Sends command to SD card and wait for expected response
sendSDCommand:
    JSR sendJustComandAndWaitForR1
    ; Disable SD
    LDA #%00010000
    STA VIA_FIRST_RB
    RTS

; You must prepare the command, arg and crc
; Sends command to SD card and wait for expected response
; R3 or R7 data will be placed in args
; Response will be in CMD
sendSDCommandAndReadR3R7:
    subroutine
    JSR sendJustComandAndWaitForR1
    LDA RESPONSE
    STA CMD
    ; Read 32 bits of data and save them into args
    LDX #$3
.loop:
    JSR readByteFromSD
    LDA RESPONSE
    STA ARG_0,X
    DEX
    BPL .loop

    ; Disable SD
    LDA #%00010000
    STA VIA_FIRST_RB
    RTS

sendSDCommandAndReadData:
    subroutine
    JSR sendJustComandAndWaitForR1
    LDA RESPONSE
    STA CMD
    JSR UART_PRINT_NUMBER
    UART_PRINTLN
    LDY #$10
.loop:
    JSR readByteFromSD
    LDA RESPONSE
    JSR UART_PRINT_NUMBER
    DEY
    BNE .loop

    ; Disable SD
    LDA #%00010000
    STA VIA_FIRST_RB
    RTS

sendJustComandAndWaitForR1:
    ; Disable SD card
    LDA #%00010000
    STA VIA_FIRST_RB
    ; Enable SD card
    LDA #0
    STA VIA_FIRST_RB
    ; Wait for not busy
    subroutine
    LDX #$F0
.loop:
    JSR readByteFromSD
    LDA RESPONSE
    CMP #$FF
    BEQ .end
    DEX
    BNE .loop
.end:

    ; Sending command, arg and CRC
    ; They are sequential in RAM
    subroutine
    LDX #5
.loop:
    LDA CRC,X
    STA SEND_BYTE
    JSR sendByteToSD
    DEX
    BPL .loop
    ; wait for response
    JSR waitForR1FromSD
    RTS

; The byte must be in SEND_BYTE
sendByteToSD:
    subroutine
    LDY #8
.loop:
    ROL SEND_BYTE
    LDA #0
    ROR
    LSR
    ; Pulse the clock
    STA VIA_FIRST_RB
    ORA #%00100000
    STA VIA_FIRST_RB
    AND #%01010000
    STA VIA_FIRST_RB
    DEY
    BNE .loop
    RTS

waitForR1FromSD:
    subroutine
    LDA #$FF
    STA RESPONSE
    LDY #$F0
.loop:
    JSR readBitFromSD
    LDA RESPONSE
    BMI .loop_tail
    RTS
.loop_tail:
    DEY
    BNE .loop
    RTS

; The result will be in RESPONSE
readByteFromSD:
    subroutine
    LDY #8
.loop:
    JSR readBitFromSD
    DEY
    BNE .loop
    RTS

; The bit will be shifted in RESPONSE
readBitFromSD:
    LDA #%01000000
    STA VIA_FIRST_RB
    LDA #%01100000
    STA VIA_FIRST_RB
    LDA VIA_FIRST_RB
    ROL
    ROL RESPONSE
    LDA #%01000000
    STA VIA_FIRST_RB
    RTS
