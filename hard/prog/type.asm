    ORG $0200

keymap:
    .byte "????????????? `?" ; 00-0F
    .byte "?????q1???zsaw2?" ; 10-1F
    .byte "?cxde43?? vftr5?" ; 20-2F
    .byte "?nbhgy6???mju78?" ; 30-3F
    .byte "?,kio09??./l;p-?" ; 40-4F
    .byte "??'?[=?????]?\??" ; 50-5F
    .byte "?????????1?47???" ; 60-6F
    .byte "0.2568???+3-*9??" ; 70-7F
    .byte "????????????????" ; 80-8F
    .byte "????????????????" ; 90-9F
    .byte "????????????????" ; A0-AF
    .byte "????????????????" ; B0-BF
    .byte "????????????????" ; C0-CF
    .byte "????????????????" ; D0-DF
    .byte "????????????????" ; E0-EF
    .byte "????????????????" ; F0-FF

    INCDIR "std"
    INCLUDE "in_ram.asm"
    
buf_write_ind = 11
buf_read_ind = 12
buf_start = $80

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

debug_start:
reset_start:
    LDX #$00
    TXS

    LDA #$00
    STA buf_write_ind
    STA buf_read_ind

    ; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    LDA #$F3
    STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%10100001
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
    WRITE_WORD VIA_FIRST_DDRB, DISPLAY_DDR
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    JSR INIT_DISPLAY

    LDA #"_"
    JSR PRINT_CHAR
    LDA #">"
    JSR PRINT_CHAR

main_loop:
; Check if something in the buffer
    LDA buf_read_ind
    CMP buf_write_ind
    ;BEQ proceed
    ;JSR process_key
proceed:
    JMP main_loop

resease_button = 13
shift_pressed = 14
process_key:
    ; Read the char and print it
    LDX buf_read_ind
    LDA buf_start,X
    STA buf_start+$10,X
    TAX
    LDA keymap,X
    LDX buf_read_ind
    STA buf_start+$20,X
    JSR PRINT_CHAR

    ; Increase pointer
    LDA buf_read_ind
    ADC #$1
    AND #$0F
    STA buf_read_ind
    RTS
