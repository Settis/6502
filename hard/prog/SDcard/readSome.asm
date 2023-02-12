    INCDIR "../std"
    INCLUDE "std.asm"

    .org $0200

; SD conntected to port B
; CS   - P4
; MOSI - P6 / to SD
; SCK  - P5
; MISO - P7 / from SD

RESPONSE = $2
SEND_BYTE = $2
; They must be sequential from CRC to CMD
CRC = $3
ARG_0 = $4
ARG_1 = $5
ARG_2 = $6
ARG_3 = $7
CMD = $8

main:
    JSR initSD
    RTS

    INCLUDE "delay.asm"

initSD:
    ; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER
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

    ; Send CMD0
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
    LDA #$F0
    PHA
.loop:
    JSR sendSDCommand
    LDA RESPONSE
    CMP #$1
    BEQ .end
    PLA
    SEC
    SBC #1
    PHA
    BNE .loop
.end:
    PLA

    subroutine
    ; Send CMD41 with leading CMD55
    LDA #$F0
    PHA
.loop
    LDA #[55 | $40]
    STA CMD
    LDA #0
    STA ARG_3
    JSR sendSDCommand

    LDA #[41 | $40]
    STA CMD
    LDA #$40
    STA ARG_3
    JSR sendSDCommand
    LDA RESPONSE
    CMP #$0 ; R1 Ready
    BEQ .end
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

; You must prepare the command, arg and crc
; Sends command to SD card and wait for expected response
sendSDCommand:
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
    subroutine
    LDX #$F0
.loop:
    JSR readByteFromSD
    LDA RESPONSE
    BPL .end
    DEX
    BNE .loop
.end:
    ; Disable SD
    LDA #%00010000
    STA VIA_FIRST_RB
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

; The result will be in RESPONSE
readByteFromSD:
    subroutine
    LDY #8
.loop:
    LDA #%01000000
    STA VIA_FIRST_RB
    LDA #%01100000
    STA VIA_FIRST_RB
    LDA VIA_FIRST_RB
    ROL
    ROL RESPONSE
    LDA #%01000000
    STA VIA_FIRST_RB
    DEY
    BNE .loop
    RTS
