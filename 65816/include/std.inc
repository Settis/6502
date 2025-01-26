.P816 

.macro ENABNE_NATIVE_MODE
    CLC
    XCE
.endmacro

.macro DISABLE_NATIVE_MODE
    SEC
    XCE
.endmacro

.macro A8
    SEP #$20
    .A8
.endmacro

.macro A16
    REP #$20
    .A16
.endmacro

.macro IND8
    SEP #$10
    .I8
.endmacro

.macro IND16
    REP #$10
    .I8
.endmacro

.macro A8_IND8
    SEP #$30
    .A8
    .I8
.endmacro

.macro A16_IND16
    REP #$30
    .A16
    .I16
.endmacro

VIA_22_FIRST  = %1000000000010000
VIA_22_SECOND = %1000000001000000
UART_51       = %1000000000100000

.scope W65C22
    RB = $0
    RA = $1
    DDRB = $2
    DDRA = $3
    T1C_L = $4
    T1C_H = $5
    T1L_L = $6
    T1L_H = $7
    T2C_L = $8
    T2C_H = $9
    SR = $A
    ACR = $B
    PCR = $C
    .scope PCR
        CB2_inputNegativeActiveEdge = %00000000
        CB2_independentInterruptInputNegativeEdge = %00100000
        CB2_inputPositiveActiveEdge = %01000000
        CB2_independentInterruptInputPositiveEdge = %01100000
        CB2_handshakeOutput = %10000000
        CB2_pulseOutput = %10100000
        CB2_lowOutput = %11000000
        CB2_highOutput = %11100000
        CB1_interruptNegativeActiveEdge = %00000000
        CB1_interruptPositiveActiveEdge = %00010000
        CA2_inputNegativeActiveEdge = %00000000
        CA2_independentInterruptInputNegativeEdge = %00000010
        CA2_inputPositiveActiveEdge = %00000100
        CA2_independentInterruptInputPositiveEdge = %00000110
        CA2_handshakeOutput = %00001000
        CA2_pulseOutput = %00001010
        CA2_lowOutput = %00001100
        CA2_highOutput = %00001110
        CA1_interruptNegativeActiveEdge = %00000000
        CA1_interruptPositiveActiveEdge = %00000001
    .endscope
    IFR = $D
    IER = $E
    OIRA = $F
.endscope

.scope W65C51
    dataReg = 0
    statusReg = 1
    .scope statusReg
        interrupt = $80
        dataSetReady = $40
        dataCarrierDetect = $20
        transmitterDataRegisterEmpty = $10
        receiverDataRegisterFull = $08
        overrun = $04
        framingError = $02
        parityError = $01
    .endscope
    commandReg = 2
    .scope commandReg
        receiverOddParityChecked = $00
        receiverEvenParityChecked = $40
        receiverParityCheckDisabled = $C0
        parityModEnabled = $20
        parityModDisabled = $00
        receiverNormalMod = $00
        receiverEchoMod = $10
        transmitInterruptDisabledForEcho = $00
        transmitInterruptEnabled = $04
        transmitInterruptDisabled = $08
        transmitInterruptDisabledBreakOnTXD = $0C
        receiverInterruptRequestEnabled = $00
        receiverInterruptRequestDisabled = $02
        dataTerminalReady = $01
        dataTerminalNotReady = $00
    .endscope
    controlReg = 3
    .scope controlReg
        ; 1 stop bit & parity, 8 bits word length, internal baud rate, 9600
        default = %10011110
    .endscope
.endscope

; remaping characters to the same thing
; because of bug or something
.charmap  $20, $20
.charmap  $21, $21
.charmap  $22, $22
.charmap  $23, $23
.charmap  $24, $24
.charmap  $25, $25
.charmap  $26, $26
.charmap  $27, $27
.charmap  $28, $28
.charmap  $29, $29
.charmap  $2a, $2a
.charmap  $2b, $2b
.charmap  $2c, $2c
.charmap  $2d, $2d
.charmap  $2e, $2e
.charmap  $2f, $2f
.charmap  $30, $30
.charmap  $31, $31
.charmap  $32, $32
.charmap  $33, $33
.charmap  $34, $34
.charmap  $35, $35
.charmap  $36, $36
.charmap  $37, $37
.charmap  $38, $38
.charmap  $39, $39
.charmap  $3a, $3a
.charmap  $3b, $3b
.charmap  $3c, $3c
.charmap  $3d, $3d
.charmap  $3e, $3e
.charmap  $3f, $3f
.charmap  $40, $40
.charmap  $41, $41
.charmap  $42, $42
.charmap  $43, $43
.charmap  $44, $44
.charmap  $45, $45
.charmap  $46, $46
.charmap  $47, $47
.charmap  $48, $48
.charmap  $49, $49
.charmap  $4a, $4a
.charmap  $4b, $4b
.charmap  $4c, $4c
.charmap  $4d, $4d
.charmap  $4e, $4e
.charmap  $4f, $4f
.charmap  $50, $50
.charmap  $51, $51
.charmap  $52, $52
.charmap  $53, $53
.charmap  $54, $54
.charmap  $55, $55
.charmap  $56, $56
.charmap  $57, $57
.charmap  $58, $58
.charmap  $59, $59
.charmap  $5a, $5a
.charmap  $5b, $5b
.charmap  $5c, $5c
.charmap  $5d, $5d
.charmap  $5e, $5e
.charmap  $5f, $5f
.charmap  $60, $60
.charmap  $61, $61
.charmap  $62, $62
.charmap  $63, $63
.charmap  $64, $64
.charmap  $65, $65
.charmap  $66, $66
.charmap  $67, $67
.charmap  $68, $68
.charmap  $69, $69
.charmap  $6a, $6a
.charmap  $6b, $6b
.charmap  $6c, $6c
.charmap  $6d, $6d
.charmap  $6e, $6e
.charmap  $6f, $6f
.charmap  $70, $70
.charmap  $71, $71
.charmap  $72, $72
.charmap  $73, $73
.charmap  $74, $74
.charmap  $75, $75
.charmap  $76, $76
.charmap  $77, $77
.charmap  $78, $78
.charmap  $79, $79
.charmap  $7a, $7a
.charmap  $7b, $7b
.charmap  $7c, $7c
.charmap  $7d, $7d
.charmap  $7e, $7e
