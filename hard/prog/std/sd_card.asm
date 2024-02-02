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
sdSector = _arg
_sdHalfPageStart = _arg ; 2 bytes
_cmd: ds 1

    SEG.U upperRam
sdPageStart: ds 512

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
    PHA
.retryGoIdleState:
        JSR _CMD_GO_IDLE_STATE
        BEQ .sdIsIdle
        TAY ; We need to save A for return
    ; Decrement counter in the stack
    TSX
    DEC $101,X
    BNE .retryGoIdleState
    PLA ; pull retry counter back
    TYA ; restore command exit code
    RTS
.sdIsIdle:
    PLA ; pull retry counter back
    JSR _CMD_SEND_IF_COND
    RTS_IF_NE
    ; Try is several times
    LDA #10
    PHA
.retryAppSendOpCond:
        JSR _CMD_APP_SEND_OP_COND
        TAY ; We need to save A for return
        IF_ZERO
            PLA
            TYA
            RTS
        END_IF
    ; Decrement counter in the stack
    TSX
    DEC $101,X
    BNE .retryAppSendOpCond
    PLA ; pull retry counter back
    TYA ; restore command exit code
    RTS

; You must have prepared sdSector
; Changes X and Y
READ_SD_SECTOR:
    LDA #[ 17 | $40 ]
    STA _cmd
    ; _arg is prepared
    ; _crc is not checked, so I don't care
    JSR _SEND_SD_COMMAND_AND_WAIT_R1
    IF_NEQ
        PHA
        JSR _DISABLE_SD_AFTER_OPERATION
        PLA
        IF_NEG
            LDA #IO_SD_BUSY_AFTER_READ_SECTOR
        ELSE_
            LDA #IO_SD_BUSY_BEFORE_READ_SECTOR
        END_IF
        RTS
    END_IF
    LDA _response
    IF_NEQ
        JSR _DISABLE_SD_AFTER_OPERATION
        LDA #IO_SD_ERROR_AFTER_READ_SECTOR
        RTS
    END_IF
    ; Wait for data token
    SUBROUTINE
    FOR_Y 0, UP_TO, $F0
        JSR _READ_BYTE_FROM_SD
        LDA _response
        CMP #$FE ; Data token for CMD 17/18/24
        BEQ .dataTokenReceived
    NEXT_Y
    JSR _DISABLE_SD_AFTER_OPERATION
    LDA #IO_SD_DATA_TOKEN_DID_NOT_RECEIVED_AFTER_READ_SECTOR
    RTS
.dataTokenReceived
    WRITE_WORD sdPageStart, _sdHalfPageStart
    JSR _READ_A_PAGE_FROM_SD
    INC _sdHalfPageStart+1
    JSR _READ_A_PAGE_FROM_SD
    ; reading CRC
    JSR _READ_BYTE_FROM_SD
    JSR _READ_BYTE_FROM_SD

    JSR _DISABLE_SD_AFTER_OPERATION
    LDA #IO_OK
    RTS

_READ_A_PAGE_FROM_SD:
    FOR_Y 0, UP_TO, 0
        JSR _READ_BYTE_FROM_SD
        LDA _response
        STA (_sdHalfPageStart),Y
    NEXT_Y
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

    UART_PRINT_STRING SD_CMD_MSG
    LDA _cmd
    JSR UART_PRINT_NUMBER
    LDA _response
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    RTS

SD_CMD_MSG: STRING "SD CMD: "

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
    FOR_Y 0, UP_TO, 4
        JSR _READ_BYTE_FROM_SD
    NEXT_Y
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
    FOR_Y 0, UP_TO, $F0
        JSR _READ_BYTE_FROM_SD
        LDA _response
        CMP #$FF
        BEQ .notBusy
    NEXT_Y
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
; Changes X
_READ_BYTE_FROM_SD:
    FOR_X 0, UP_TO, 8
        JSR _READ_BIT_FROM_SD
    NEXT_X
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
