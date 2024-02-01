    INCLUDE "io_errors.asm"

; SD conntected to port B
; CS   - P4
; MOSI - P6 / to SD
; SCK  - P5
; MISO - P7 / from SD

    SEG.U zpVars
_response: ds 1
_sendByte = _response
; They must be sequential from CRC to CMD
_crc: ds 1
_arg: ds 4
_sd_sector = _arg
_cmd: ds 1
_retry: ds 1

    SEG.U upperRam
_sdPageStart: ds 512

    SEG code
; Changes X and Y
INIT_SD:
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
    JSR _WAIT
    FOR_X 0, UP_TO, 10
        JSR _DUMMY_CLOCK_WITH_DISABLED_CARD
    NEXT_X
    ; Try to switch it into idle several times
    LDA #10
    STA _retry
.retryGoIdleState:
        JSR _CMD_GO_IDLE_STATE
        BEQ .sdIsIdle
    DEC _retry
    BNE .retryGoIdleState
    RTS
.sdIsIdle:
    JSR _CMD_SEND_IF_COND
    RTS_IF_NE
    ; Try is several times
    LDA #10
    STA _retry
.retryAppSendOpCond:
        JSR _CMD_APP_SEND_OP_COND
        RTS_IF_EQ
    DEC _retry
    BNE .retryAppSendOpCond
    RTS

; Changes X and Y
_WAIT:
    FOR_X 0, UP_TO, 95
        FOR_Y 0, UP_TO, 100
            ; nothing
        NEXT_Y
    NEXT_X
    RTS

; Changes Y
_DISABLE_SD_AFTER_OPERATION:
_DUMMY_CLOCK_WITH_DISABLED_CARD:
    ; CS = DI = HIGH
    LDA #%0101000
    STA VIA_FIRST_RB
    FOR_Y 0, UP_TO, 8
        LDA #%01110000
        STA VIA_FIRST_RB
        LDA #%01010000
        STA VIA_FIRST_RB
    NEXT_Y
    RTS

; CMD 0
; Changes X & Y
_CMD_GO_IDLE_STATE:
    LDA #[ 0 | $40 ]
    STA _cmd
    LDA #0
    STA _arg
    STA _arg+1
    STA _arg+2
    STA _arg+3
    LDA #$95
    STA _crc
    JSR _SEND_SD_COMMAND_AND_WAIT_R1
    PHA
    JSR _DISABLE_SD_AFTER_OPERATION
    PLA
    IF_NEQ
        IF_NEG
            LDA #IO_SD_BUSY_AFTER_GO_IDLE_STATE
        ELSE_
            LDA #IO_SD_BUSY_BEFORE_GO_IDLE_STATE
        END_IF
        RTS
    END_IF
    LDA _response
    CMP #1 ; R1 idle
    IF_EQ
        LDA #_SD_OK
    ELSE_
        LDA #IO_SD_NOT_IDLE_AFTER_GO_IDLE_STATE
    END_IF
    RTS

; CMD 8
_CMD_SEND_IF_COND:
    LDA #[ 8 | $40 ]
    STA _cmd
    LDA #$AA
    STA _arg
    LDA #1
    STA _arg+1
    LDA #$87
    STA _crc
    JSR _SEND_SD_COMMAND_AND_WAIT_R1
    PHA
    ; Read 32 bits of data
    FOR_X 0, UP_TO, 4
        JSR _READ_BYTE_FROM_SD
    NEXT_X
    JSR _DISABLE_SD_AFTER_OPERATION
    PLA
    IF_NEQ
        IF_NEG
            LDA #IO_SD_BUSY_AFTER_SEND_IF_COND
        ELSE_
            LDA #IO_SD_BUSY_BEFORE_SEND_IF_COND
        END_IF
        RTS
    END_IF
    LDA _response
    CMP #1 ; R1 idle
    IF_EQ
        LDA #_SD_OK
    ELSE_
        LDA #IO_SD_NOT_IDLE_AFTER_SEND_IF_COND
    END_IF
    RTS

; CMD 41
_CMD_APP_SEND_OP_COND:
    ; Send CMD41 with leading CMD55
    LDA #[ 55 | $40 ]
    STA _cmd
    LDA #0
    STA _arg
    STA _arg+1
    STA _arg+2
    STA _arg+3
    LDA #$65
    STA _crc
    JSR _SEND_SD_COMMAND_AND_WAIT_R1
    PHA
    JSR _DISABLE_SD_AFTER_OPERATION
    PLA
    IF_NEQ
        IF_NEG
            LDA #IO_SD_BUSY_AFTER_APP_CMD
        ELSE_
            LDA #IO_SD_BUSY_BEFORE_APP_CMD
        END_IF
        RTS
    END_IF
    
    LDA #[ 41 | $40 ]
    STA _cmd
    LDA #$40
    STA _arg+3
    LDA #$77
    STA _crc
    JSR _SEND_SD_COMMAND_AND_WAIT_R1
    PHA
    JSR _DISABLE_SD_AFTER_OPERATION
    PLA
    IF_NEQ
        IF_NEG
            LDA #IO_SD_BUSY_AFTER_APP_SEND_OP_COND
        ELSE_
            LDA #IO_SD_BUSY_BEFORE_APP_SEND_OP_COND
        END_IF
        RTS
    END_IF
    LDA _response
    IF_NEQ
        LDA #IO_SD_ERROR_AFTER_APP_SEND_OP_COND
    END_IF
    RTS

_SD_OK = 0
_SD_BUSY_BEFORE_COMMAND = 1
; For negative flag
_SD_BUSY_AFTER_COMMAND = $FF
; Changes X and Y
_SEND_SD_COMMAND_AND_WAIT_R1:
    SUBROUTINE
    ; Enable SD card
    LDA #0
    STA VIA_FIRST_RB
    FOR_X 0, UP_TO, $F0
        JSR _READ_BYTE_FROM_SD
        LDA _response
        CMP #$FF
        BEQ .notBusy
    NEXT_X
    LDA #_SD_BUSY_BEFORE_COMMAND
    RTS
.notBusy
    ; It's ready. Sending command, arg and crc
    ; They are sequential in RAM
    FOR_X 5, DOWN_TO, NEG_NRs
        LDA _crc,X
        STA _sendByte
        JSR _SEND_BYTE_TO_SD
    NEXT_X
    ; We need to wait for R1 response
    ; It starts with 0 in 7th bit
    LDA #$FF
    STA _response
    FOR_X 0, UP_TO, $F0
        JSR _READ_BIT_FROM_SD
        LDA _response
        BMI .r1Received
    NEXT_X
    LDA #_SD_BUSY_AFTER_COMMAND
    RTS
.r1Received
    LDA #_SD_OK
    RTS

; The result will be in _response
; Changes Y
_READ_BYTE_FROM_SD:
    FOR_Y 0, UP_TO, 8
        JSR _READ_BIT_FROM_SD
    NEXT_Y
    RTS

; The bit will be shifted in _response
_READ_BIT_FROM_SD:
    LDA #%01000000
    STA VIA_FIRST_RB
    LDA #%01100000
    STA VIA_FIRST_RB
    LDA VIA_FIRST_RB
    ROL
    ROL _response
    LDA #%01000000
    STA VIA_FIRST_RB
    RTS

; Changes Y
_SEND_BYTE_TO_SD:
    FOR_Y 0, UP_TO, 8
        ROL _sendByte
        LDA #0
        ROR
        LSR
        ; Pulse the clock
        STA VIA_FIRST_RB
        ORA #%00100000
        STA VIA_FIRST_RB
        AND #%01010000
        STA VIA_FIRST_RB
    NEXT_Y
    RTS
