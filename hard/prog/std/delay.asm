    ALLOC DELAY_X
    ALLOC DELAY_Y

; Delay 
; {1} - X
; {2} - Y
    MAC delay
    PHA
    LDA #{2}
    STA DELAY_Y
    LDA #{1}
    STA DELAY_X
    JSR delay_loop
    PLA
    ENDM

delay_loop:
; Save state to stack
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

    RTS
  