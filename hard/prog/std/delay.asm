DELAY_X = $07
DELAY_Y = $08

TMP_STORE_A = $40

delayxy:
    STA TMP_STORE_A

    LDA DELAY_X
delayxy_loop_y:
    STA DELAY_X
delayxy_loop_x:
    DEC DELAY_X
    BNE delayxy_loop_x
    CLC
    DEC DELAY_Y
    BNE delayxy_loop_y
    CLC

    LDA TMP_STORE_A
    RTS

delay_loop:
; Save state to stack
    PHA
    TXA
    PHA
    TYA
    PHA

    LDY DELAY_Y
delay_y_loop:
    LDX DELAY_X
delay_x_loop:
    DEX
    BNE delay_x_loop
    DEY
    BNE delay_y_loop

; Pull state from stack
    PLA
    TAY
    PLA
    TAX
    PLA

    RTS


delay:
  ; save state. we'll be using the A register, so save it off to RAM
  ; and restore it before leaving. use another address if needed
  STA $40
  ; zero the A register ready for our use
  LDA #$00
  ; store that zero off to RAM too. registers only hold 8-bits so
  ; we'll store the high byte of our number off to RAM
  STA $41  ; high byte
delayloop:
  ADC #01
  ; usually adding 1 into A won't set the Zero bit. when the reigster
  ; overflows and the value of A becomes #$00, the Zero flag will be
  ; set. BNE jumps when the Z bit is not set
  BNE delayloop
  ; so we only land here after we've counted past #$FF
  ; clear carry flag so we don't add it next ADC
  CLC
  INC $41
  ; same strategy is used here, we jump unless the INC overflowed
  ; back to zero
  BNE delayloop
  ; clear carry flag so we don't add it next ADC
  CLC
  ; exit
  ; restore state of the A register
  LDA $40
  RTS
  