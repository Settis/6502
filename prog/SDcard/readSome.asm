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
PAGE_ADDR_POINTER = ARG_0
    ALLOC ARG_1
PAGE_ADDR_POINTER_H = ARG_1
    ALLOC ARG_2
    ALLOC ARG_3
    ALLOC CMD

SD_SECTOR_0 = ARG_0
SD_SECTOR_1 = ARG_1
SD_SECTOR_2 = ARG_2
SD_SECTOR_3 = ARG_3

SD_PAGE_ADDR = $7E00

main_SD:
    JSR INIT_UART_PRINT
    JSR initSD
    JSR readData

    ; check the magic number must be 55 aa
    UART_PRINTLN
    LDA $7FFE
    JSR UART_PRINT_NUMBER
    LDA $7FFF
    JSR UART_PRINT_NUMBER

    JSR UART_PRINT_WAIT_FOR_BUFFER
    RTS

    include uart_print.asm
    INCLUDE "delay.asm"

sendCmd0Msg:
    STRING "Send CMD0"

sendAcmd41Msg:
    STRING "Send ACMD41 & CMD55"

sendCmd8Msg:
    STRING "Send CMD8"

sendCmd58Msg:
    STRING "Send CMD58"

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
    LDX #10
.loop:
    JSR dummyClockWithDisabledCard
    DEX
    BNE .loop

    SUBROUTINE

    JSR SEND_CMD_0
    
    JSR SEND_CMD_8
    JSR SEND_CMD_58

    LDA #10
    PHA
.loop    
    JSR SEND_CMD_ACMD41

    LDA RESPONSE
    CMP #$0 ; R1 Ready
    BEQ .end
    JSR LONG_WAITING
    PLA
    SEC
    SBC #1
    PHA
    BNE .loop
.end:
    PLA

    JSR disableSDAfterOperation
    RTS

LONG_WAITING:
    SUBROUTINE
    LDX #$10
.loop:
    TXA
    PHA
    delay 200, 200
    PLA
    TAX
    DEX
    BEQ .loop
    RTS

SEND_CMD_0:
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
    RTS

SEND_CMD_8:
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
    RTS

SEND_CMD_58: ; For OCR reading
    UART_PRINTLN

    UART_PRINTLN_STRING sendCmd58Msg

    LDA #[ 58 | $40 ]
    STA CMD
    LDA #$0
    STA ARG_3
    STA ARG_2
    STA ARG_1
    STA ARG_0
    LDA #$FD
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
    RTS

SEND_CMD_ACMD41:
    subroutine
    UART_PRINTLN_STRING sendAcmd41Msg
    ; Send CMD41 with leading CMD55

    LDA #[55 | $40]
    STA CMD
    LDA #0
    STA ARG_0
    STA ARG_1
    STA ARG_2
    STA ARG_3
    LDA #$65
    STA CRC
    JSR sendSDCommand
    LDA RESPONSE
    JSR UART_PRINT_NUMBER

    LDA #[41 | $40]
    STA CMD
    LDA #$40
    STA ARG_3
    LDA #$77
    STA CRC
    JSR sendSDCommand
    LDA RESPONSE
    JSR UART_PRINT_NUMBER
    UART_PRINTLN
    RTS

disableSDAfterOperation:
dummyClockWithDisabledCard:
    SUBROUTINE
        ; CS = DI = HIGH
    LDA #%01010000
    STA VIA_FIRST_RB
    LDY #10
.loop:
    LDA #%01110000
    STA VIA_FIRST_RB
    LDA #%01010000
    STA VIA_FIRST_RB
    DEY
    BNE .loop
    RTS


; The address must be already in ARG_0 .. ARG_3
readData:
readSector:
    UART_PRINTLN
    UART_PRINTLN_STRING sendCmdRead
    LDA #[ 17 | $40 ]
    STA CMD
    ; LDA #$0
    ; STA ARG_0
    ; STA ARG_1
    ; STA ARG_2
    ; STA ARG_3
    ; STA CRC
    JSR sendSDCommandAndReadData
    RTS

; You must prepare the command, arg and crc
; Sends command to SD card and wait for expected response
sendSDCommand:
    JSR sendJustComandAndWaitForR1
    JSR disableSDAfterOperation
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

    JSR disableSDAfterOperation
    RTS

sendSDCommandAndReadData:
    subroutine
    JSR sendJustComandAndWaitForR1
    LDA RESPONSE
    STA CMD
    JSR UART_PRINT_NUMBER
    UART_PRINTLN
    JSR waitForDataToken
    LDA #<SD_PAGE_ADDR
    STA PAGE_ADDR_POINTER
    LDA #>SD_PAGE_ADDR
    STA PAGE_ADDR_POINTER_H
    JSR readAPageFromSD
    INC PAGE_ADDR_POINTER_H
    JSR readAPageFromSD
    ; reading CRC
    JSR readByteFromSD
    JSR readByteFromSD
    UART_PRINTLN

    JSR disableSDAfterOperation
    RTS

waitForDataToken:
    SUBROUTINE
    LDY #$FF
.loop:
    TYA
    PHA
    JSR readByteFromSD
    LDA RESPONSE
    CMP #$FE
    BEQ .end
    PLA
    TAY
    DEY
    BNE .loop
.end:
    PLA
    RTS

readAPageFromSD:
    SUBROUTINE
    LDY #0
.loop:
    TYA
    PHA
    JSR readByteFromSD
    LDA RESPONSE
    JSR UART_PRINT_NUMBER
    PLA
    TAY
    LDA RESPONSE
    STA (PAGE_ADDR_POINTER),Y
    INY
    BNE .loop
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
