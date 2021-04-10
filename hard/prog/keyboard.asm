    INCDIR "std"
    INCLUDE "std.asm"

ACIA_ADDRESS = %1000000000100000
DATA_REGISTER = ACIA_ADDRESS
STATUS_REGISTER = ACIA_ADDRESS + 1
PROG_RESET = ACIA_ADDRESS + 1
COMMAND_REGISTER = ACIA_ADDRESS + 2
CONTROL_REGISTER = ACIA_ADDRESS + 3

start:

; Parity check disabled
; Parity mode enabled
; No echo
; Transmitter interrupt disabled
; Receiver interrupt enabled
; Data terminal ready
    LDA #%11101101
    STA COMMAND_REGISTER

; Stop bit for 8bit data and parity
; WL = 8
; External clock
; 16x baud
    LDA #%10011111
    STA CONTROL_REGISTER

    LDA COMMAND_REGISTER
    STA $10
    LDA CONTROL_REGISTER
    STA $11

; Setup timer
    LDA #$0
    STA VIA_FIRST_IFR
    LDA #$0
    STA VIA_FIRST_ACR
    LDA #%11000000
    STA VIA_FIRST_IER
    LDA #$FF
    STA VIA_FIRST_T1C_L
    LDA #$05
    STA VIA_FIRST_T1C_H

; wait for data
    CLI
loop:
    JMP loop

nmi:
    LDA #$FF
    STA $03
    
handle:
; Read signal to 02
    LDA STATUS_REGISTER
    STA $01
    LDA DATA_REGISTER
    STA $02
    JMP end

end:
    LDA #$0

    RESET_VECTOR start, handle, nmi