RAM = 0

    IF RAM = 0
        ORG $FC00
    else
        ORG $0200
    endif

    INCDIR "std"
    INCLUDE "std.asm"

command = $10
argument = $11
hour = $12
minutes = $13
seconds = $14
digitsTmp = $15

main:
    ; RTS init 
    ; Setup output pins
    LDA #%11010000
    STA VIA_FIRST_DDRB
    ; Disable RTS
    LDA #$0
    STA VIA_FIRST_RB

    ; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER
; Setup handshakes
    LDA #%11001100
    STA VIA_FIRST_PCR

; Disable latch
    LDA #$00
    STA VIA_FIRST_ACR

; Init display 2
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RA, DISPLAY_ADDR
    WRITE_WORD VIA_FIRST_DDRA, DISPLAY_DDR
    LDA #%00100010
    STA DISPLAY_PCR_MASK
    JSR INIT_DISPLAY

loop:
    JSR printTime
    JMP loop

    if RAM = 0
    JMP loop
    endif
    if RAM = 1
    RTS
    endif

    INCLUDE "display.asm"

printTime:
    JSR CLEAR_DISPLAY
    
    LDA #">"
    JSR PRINT_CHAR

    LDA #" "
    JSR PRINT_CHAR

    JSR readTime

    LDA hour
    JSR writeDigits
    LDA #":"
    JSR PRINT_CHAR
    LDA minutes
    JSR writeDigits
    LDA #":"
    JSR PRINT_CHAR
    LDA seconds
    JSR writeDigits

    JSR wait_500
    RTS

writeDigits:
    STA digitsTmp
    LSR
    LSR
    LSR
    LSR
    CLC
    ADC #"0"
    JSR PRINT_CHAR
    LDA digitsTmp
    AND #$0F
    CLC
    ADC #"0"
    JSR PRINT_CHAR
    RTS

wait_500:
    JSR wait_100
    JSR wait_100
    RTS

wait_100:
    JSR wait_50
    JSR wait_50
    RTS

wait_50:
    JSR delay_10
    JSR delay_10
    JSR delay_10
    JSR delay_10
    JSR delay_10
    RTS

readTime:
    ; Hour
    LDA #$85
    STA command
    JSR read
    LDA argument
    STA hour

    ; Minutes
    LDA #$83
    STA command
    JSR read
    LDA argument
    STA minutes

    ; Seconds
    LDA #$81
    STA command
    JSR read
    LDA argument
    STA seconds
    RTS

read:
    JSR sendCommand
    subroutine
    ; Switch to reading
    LDA #%01010000
    STA VIA_FIRST_DDRB

    LDY #$8
.argumentLoop:
    LDA VIA_FIRST_RB
    ROL 
    ROR argument
    ; Clock ON
    LDA #%01010000
    STA VIA_FIRST_RB
    ; Clock OFF
    AND #%00010000
    STA VIA_FIRST_RB
    DEY
    BNE .argumentLoop

    ; Shut off RTS
    LDA #%11010000
    STA VIA_FIRST_DDRB
    LDA #$0
    STA VIA_FIRST_RB
    RTS

write:
    JSR sendCommand
    LDA argument
    STA command
    JSR sendCommand
    ; Shut off RTS
    LDA #$0
    STA VIA_FIRST_RB
    RTS

sendCommand:
    subroutine
    ; Enable CS
    LDA #%00010000
    STA VIA_FIRST_RB

    LDY #$8
.commandLoop:
    ROR command
    LDA #%00100000
    ROR
    STA VIA_FIRST_RB
    ; Clock ON
    ORA #%01000000
    STA VIA_FIRST_RB
    ; Clock OFF
    AND #%10010000
    STA VIA_FIRST_RB
    DEY
    BNE .commandLoop
    RTS

    if RAM = 0
        RESET_VECTOR main, main, main
    endif
