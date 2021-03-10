    PROCESSOR 6502

REG_B = $8000
REG_A = $8001
DDRB = $8002
DDRA = $8003
PCR = $800C
CA_CONTROL = %00001010

EN = %00000001
RS = %00000010

CLEAR_DISPLAY = %00000001
FUNCTION_SET  = %00101000
DISPLAY_ON    = %00001110
ENTRY_MODE_SET = %00000110

    ORG $C000

; Data in A register
; Y = 0 for command
; Y = 1 for data
toScreen:
    TAX
    AND #$F0
    CPY #$01
    BNE COMMAND_1
    CLC
    ADC #RS
COMMAND_1:
    STA REG_A
    CLC
    ADC #EN
    STA REG_A
    SEC
    SBC #EN
    STA REG_A

    TXA
    ROL
    ROL
    ROL
    ROL
    AND #$F0
    CPY #$01
    BNE COMMAND_2
    CLC
    ADC #RS
COMMAND_2:
    STA REG_A
    CLC
    ADC #EN
    STA REG_A
    SEC
    SBC #EN
    STA REG_A

    RTS

tick:
    LDA #0
    STA REG_B

    LDA #1
    STA REG_B

    LDA #0
    STA REG_B

    RTS

cmd:
    TAX
    AND #$F0
    STA REG_A
    TXA
    ROL
    ROL
    ROL
    ROL
    AND #$F0
    STA REG_A
    RTS

dataTick:
    LDA #0
    STA REG_B

    LDA #3
    STA REG_B

    LDA #0
    STA REG_B

    RTS

data:
    TAX
    AND #$F0
    ORA #$01
    STA REG_A
    TXA
    ROL
    ROL
    ROL
    ROL
    AND #$F0
    ORA #$01
    STA REG_A
    RTS

hello_srt:
    DC "WDC 6502", 0

start:
    LDA #$F1
    STA DDRA

    LDA #CA_CONTROL
    STA PCR

    LDA #%00110000
    STA REG_A
    STA REG_A
    STA REG_A

    LDA #%00100000
    STA REG_A

    LDA #%00100000
    JSR cmd

    LDA #%00001110
    JSR cmd

    LDA #%00000001
    JSR cmd

    LDA #%00000110
    JSR cmd

    LDA #"S"
    JSR data
    

    ; LDY #$00

    ; LDA #%00100010
    ; JSR toScreen

    ; LDA #%00100000
    ; JSR toScreen

    ; LDA #%00001111
    ; JSR toScreen

    ; LDA #%00000110
    ; JSR toScreen

    ; LDY #$01
    ; LDA #%01001000
    ; JSR toScreen

    ORG $FFFC
    DC.W start
