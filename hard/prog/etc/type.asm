RAM = 1

    IF RAM = 0
        ORG $FC00
    else
        ORG $0200
    endif

keymap:
    .byte "????????????? `?" ; 00-0F
    .byte "?????q1???zsaw2?" ; 10-1F
    .byte "?cxde43?? vftr5?" ; 20-2F
    .byte "?nbhgy6???mju78?" ; 30-3F
    .byte "?,kio09??./l;p-?" ; 40-4F
    .byte "??'?[=?????]?\??" ; 50-5F
    .byte "?????????1?47???" ; 60-6F
    .byte "0.2568???+3-*9??" ; 70-7F
    .byte "????????????? ~?" ; 80-8F
    .byte "?????Q!???ZSAW@?" ; 90-9F
    .byte "?CXDE$#?? VFTR%?" ; A0-AF
    .byte "?NBHGY^???MJU&*?" ; B0-BF
    .byte "?<KIO)(??>?L:P_?" ; C0-CF
    .byte "??'?{+?????}?|??" ; D0-DF
    .byte "?????????!?$&???" ; E0-EF
    .byte ")>@%^*???+#_*(??" ; F0-FF

    INCDIR "std"
    INCLUDE "std.asm"

buf_write_ind = $11
buf_read_ind = $12
buf_start = $80
release_button = $13
shift_pressed = $14

read_kb:
    PHA
    TXA
    PHA

    ; LDA #"F"
    ; JSR PRINT_CHAR

    LDA VIA_FIRST_IFR
    LDX buf_write_ind
    LDA VIA_FIRST_RA
    STA buf_start,X
    INX
    TXA
    AND #$0F
    STA buf_write_ind
    
    PLA
    TAX
    PLA

    RTI

    INCLUDE "display.asm"
    INCLUDE "hex_ascii.asm"

debug_start:
reset_start:
    LDX #$00
    TXS

main:
    IF RAM = 1
        LDA #<read_kb
        STA $FE
        LDA #>read_kb
        STA $FF
    ENDIF
    

    LDA #$00
    STA buf_write_ind
    STA buf_read_ind
    STA release_button
    STA shift_pressed

    ; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    ; LDA #$F3
    ; STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%11000001
    STA VIA_FIRST_PCR


    ; Enable CA1 interrupt
    LDA #$82
    STA VIA_FIRST_IER

; Disable latch
    LDA #$00
    STA VIA_FIRST_ACR

; CA1 interrupts on positive edge
    ; LDA #$01
    ; STA VIA_FIRST_PCR

; Setup port directions
    LDA #$00
    STA VIA_FIRST_DDRA

    LDA VIA_FIRST_IFR
    LDA VIA_FIRST_RA

    CLI

; Init display 2
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    WRITE_WORD VIA_FIRST_DDRB, DISPLAY_DDR
    LDA #%00100000
    STA DISPLAY_PCR_MASK
    JSR INIT_DISPLAY

    LDA #">"
    JSR PRINT_CHAR

main_loop:
; Check if something in the buffer
    LDA buf_read_ind
    CMP buf_write_ind
    BEQ proceed
    JSR process_key
proceed:
    JMP main_loop

print_hex:
    JSR HEX_TO_ASCII
    LDA ASCII_FIRST
    JSR PRINT_CHAR
    LDA ASCII_SECOND
    JSR PRINT_CHAR
    RTS

process_key:
    ; Read the char and print it
    LDX buf_read_ind
    LDA buf_start,X

    ; Check if that scan code after release
    LDX #0
    CPX release_button
    BEQ print_check_release
    DEC release_button
    CMP #$12
    BEQ shift_released_branch
    CMP #$59
    BEQ shift_released_branch
    JMP process_key_end

print_check_release:
    ; Check for release scan code
    CMP #$F0
    BNE after_release_check
    INC release_button
    JMP process_key_end

shift_released_branch:
    LDX #0
    STX shift_pressed
    JMP process_key_end

after_release_check:
    CMP #$12
    BEQ shift_pressed_branch
    CMP #$59
    BEQ shift_pressed_branch
    JMP check_key_pressed

shift_pressed_branch:
    LDX #1
    STX shift_pressed
    JMP process_key_end

check_key_pressed:
    ; Check if it was pressed some non ASCII
    CMP #$76
    BEQ esc_key_pressed
    CMP #$5A
    BEQ enter_key_pressed
    ; Special case for NUM pad, ignore it
    CMP #$E0
    BEQ process_key_end
    CMP #$75
    BEQ arrow_up_down_pressed
    CMP #$72
    BEQ arrow_up_down_pressed
    CMP #$6B
    BEQ arrow_left_pressed
    CMP #$74
    BEQ arrow_right_pressed
    CMP #$66
    BEQ backspace_pressed
    ; Print ASCII
    JMP print_key

esc_key_pressed:
    JSR CLEAR_DISPLAY
    JMP process_key_end

enter_key_pressed:
    JSR DISPLAY_CHANGE_LINE
    JMP process_key_end

arrow_up_down_pressed:
    JSR READ_FROM_DISPLAY
    EOR #%01000000
    ORA #%10000000
    JSR SEND_DISPLAY_COMMAND
    JMP process_key_end

arrow_left_pressed:
    JSR READ_FROM_DISPLAY
    SEC
    SBC #1
    ORA #%10000000
    JSR SEND_DISPLAY_COMMAND
    JMP process_key_end

arrow_right_pressed:
    JSR READ_FROM_DISPLAY
    CLC
    ADC #1
    ORA #%10000000
    JSR SEND_DISPLAY_COMMAND
    JMP process_key_end

backspace_pressed:
    JSR READ_FROM_DISPLAY
    SEC
    SBC #1
    ORA #%10000000
    PHA
    JSR SEND_DISPLAY_COMMAND
    LDA #" "
    JSR PRINT_CHAR
    PLA
    JSR SEND_DISPLAY_COMMAND
    JMP process_key_end

print_key:
    LDX #0
    CPX shift_pressed
    BEQ convert_and_print
    ORA #$80
convert_and_print:
    TAX
    LDA keymap,X
    JSR PRINT_CHAR

process_key_end:
    ; Increase pointer
    LDA buf_read_ind
    CLC
    ADC #$1
    AND #$0F
    STA buf_read_ind
    RTS

    if RAM = 0
        RESET_VECTOR reset_start, read_kb, debug_start
    endif
