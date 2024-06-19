    INCLUDE "io_errors.asm"

; SD conntected to port B
; CS   - P7
; SCK  - CB1 / controlled by shift register
;   IO - CB2 / controlled by shift register 
; MOSI - P7 = 0 / to SD
; MISO - P6 = 0 / from SD$A0

    ; 111XXXXX - disable SD
    ; 0XXXXXXX - enable SD
    ; X01XXXXX - read from SD
    ; X10XXXXX - write to SD

    SEG.U zpVars
_response: ds 1
_sendByte: ds 1
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
    LDA #%11100000
    STA VIA_FIRST_DDRB
    ; Disable SD
    LDA #%11100000
    STA VIA_FIRST_RB
    ; Set CLOCK divider it's ~ 24
    LDA #24
    STA VIA_FIRST_T2C_L
    ; Wait > 1ms after power up
    JSR _WAIT
    FOR_Y 0, UP_TO, $10
        JSR _DUMMY_CLOCK_WITH_DISABLED_CARD
    NEXT_Y
    ; ===== CMD0 with retry =====
    ; Try to switch it into idle several times
    LDA #$f0
    PHA
    BEGIN
        JSR _CMD_GO_IDLE_STATE
        BEQ .sdIsIdle
        TAY ; We need to save A for return
        ; Decrement counter in the stack
        TSX
        DEC $101,X
    UNTIL_ZERO 
    PLA ; pull retry counter back
    TYA ; restore command exit code
    RTS
.sdIsIdle:
    PLA ; pull retry counter back
    ; ===== CMD8 with retry =====
    ; It seems that I need to retry everything
    LDA #$f0
    PHA
    BEGIN
        JSR _CMD_SEND_IF_COND
        BEQ .turnOn
        TAY
        TSX
        DEC $101,X
    UNTIL_ZERO
    PLA ; pull retry counter back
    TYA ; restore command exit code
    RTS
.turnOn:
    PLA ; pull retry counter back
    ; ===== ACMD41 with retry =====
    ; Try is several times
    LDA #$f0
    PHA
    BEGIN
        JSR _CMD_APP_SEND_OP_COND
        IF_ZERO
            TAY 
            PLA
            TYA
            RTS
        END_IF
        PHA
        JSR _WAIT
        PLA
        TAY ; We need to save A for return
        ; Decrement counter in the stack
        TSX
        DEC $101,X
    UNTIL_ZERO
    PLA ; pull retry counter back
    TYA ; restore command exit code
    RTS

; You must have prepared sdSector
; Changes X and Y
READ_SD_SECTOR:
    LDA #$F0 ; retry everything
    PHA
    BEGIN
        JSR _READ_SD_SECTOR_INSIDE_RETRY
        TAY
        IF_ZERO
            PLA ; pull retry counter
            TYA ; restore zero for return
            RTS
        END_IF
        TSX
        DEC $101,X
    UNTIL_ZERO
    PLA ; pull retry counter back
    TYA ; restore command exit code
    RTS

_READ_SD_SECTOR_INSIDE_RETRY:
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
    FOR_X 0, UP_TO, $20
        TXA
        PHA
        FOR_Y 0, UP_TO, $F0
            JSR _READ_BYTE_SD
            LDA _response
            CMP #$FE ; Data token for CMD 17/18/24
            BEQ .dataTokenReceived
        NEXT_Y
        PLA
        TAX
    NEXT_X
    JSR _DISABLE_SD_AFTER_OPERATION
    LDA #IO_SD_DATA_TOKEN_DID_NOT_RECEIVED_AFTER_READ_SECTOR
    RTS
.dataTokenReceived
    PLA ; pull the stored X
    WRITE_WORD sdPageStart, _sdHalfPageStart
    JSR _READ_A_PAGE_FROM_SD
    INC _sdHalfPageStart+1
    JSR _READ_A_PAGE_FROM_SD
    ; reading CRC
    JSR _READ_BYTE_SD
    JSR _READ_BYTE_SD

    JSR _DISABLE_SD_AFTER_OPERATION
    LDA #IO_OK
    RTS

_READ_A_PAGE_FROM_SD:
    FOR_Y 0, UP_TO, 0
        JSR _READ_BYTE_SD
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

; Changes X
_DISABLE_SD_AFTER_OPERATION:
_DUMMY_CLOCK_WITH_DISABLED_CARD:
    LDA _response
    PHA
    ; CS = DI = HIGH
    LDA #%11100000
    STA VIA_FIRST_RB
    LDA #%00000100
    STA VIA_FIRST_ACR
    LDA VIA_FIRST_SR ; trigger shifting
    JSR _WAIT_FOR_SHIFTING
    PLA
    STA _response
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
; Changes X & Y
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
    LDA _response
    PHA
    ; Read 32 bits of data
    FOR_Y 0, UP_TO, 4
        JSR _READ_BYTE_SD
    NEXT_Y
    PLA
    STA _response
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
    FOR_Y 0, UP_TO, $F0
        JSR _READ_BYTE_SD
        LDA _response
        CMP #$FF
        BEQ .notBusy
    NEXT_Y
    LDA #_SD_BUSY_BEFORE_COMMAND
    RTS
.notBusy
    JSR _DISABLE_SD_AFTER_OPERATION
    ; It's ready. Sending command, arg and crc
    ; They are sequential in RAM
    FOR_Y 5, DOWN_TO, NEG_NRs
        LDA _crc,Y
        STA _sendByte
        JSR _RW_BYTE_SD
    NEXT_Y
    ; We need to wait for R1 response
    ; It starts with 0 in 7th bit
    FOR_Y 0, UP_TO, $F0
        JSR _READ_BYTE_SD
        LDA _response
        BPL .r1Received
    NEXT_Y
    LDA #_SD_BUSY_AFTER_COMMAND
    RTS
.r1Received
    LDA #_SD_OK
    RTS

; Changes X
_READ_BYTE_SD:
    LDA #%00000100
    STA VIA_FIRST_ACR
    LDA #%00100000
    STA VIA_FIRST_RB

    LDA VIA_FIRST_SR ; read SR to trigger shift in
    JSR _WAIT_FOR_SHIFTING

    ; disabling shift register
    LDA #%00000000
    STA VIA_FIRST_ACR 

    LDA VIA_FIRST_SR ; now I can read it without triggering shifting
    STA _response
    RTS

; Sends _sendByte
; The result will be in _response
; CS is untouched
; Changes X
_RW_BYTE_SD:
    LDA #%00010100
    STA VIA_FIRST_ACR
    LDA #%01000000
    STA VIA_FIRST_RB

    LDA _sendByte
    STA VIA_FIRST_SR

_WAIT_FOR_SHIFTING:
    FOR_X 0, UP_TO, 200
    NEXT_X
    RTS
