    INCLUDE "../std/std.asm"

    SEG.U zpVars
    ORG $40

	SEG code
	JMP main

    INCLUDE "display.asm"

; from bootloader
filenamePointer = $9
half_sector_pointer = $25
OPEN_FILE_BY_NAME = $fc30
READ_NEXT_HALF_SECTOR = $fcab

    SEG code
MSG_FILE: STRING "/msg.txt"
ERR_STRING: STRING "File error"
main:
; Disable all interrupts
    LDA #$7F
    STA VIA_SECOND_IER

; Setup handshakes
    LDA #%11001100
    STA VIA_SECOND_PCR

    LDA #%00100000
    STA DISPLAY_PCR_MASK

; Init display 2
    WRITE_WORD VIA_SECOND_PCR, DISPLAY_PCR
    WRITE_WORD VIA_SECOND_RB, DISPLAY_ADDR
    WRITE_WORD VIA_SECOND_DDRB, DISPLAY_DDR
    LDA #%00100000
    STA DISPLAY_PCR_MASK
    JSR INIT_DISPLAY

	; Disable cursor
	LDA #%00001100
	JSR SEND_DISPLAY_COMMAND

    WRITE_WORD MSG_FILE, filenamePointer
    JSR OPEN_FILE_BY_NAME
    BNE fail
    JSR READ_NEXT_HALF_SECTOR
    BNE fail
    JSR PRINT_FILE_CONTENT
nothing:
    JMP nothing
fail:
    WRITE_WORD ERR_STRING, DISPLAY_STRING_ADDR
    JSR PRINT_STRING
    JMP nothing

PRINT_FILE_CONTENT:
    LDY #0
    JSR PRINT_LINE_FROM_FILE
    INY
    JSR DISPLAY_CHANGE_LINE
    JSR PRINT_LINE_FROM_FILE
    RTS

PRINT_LINE_FROM_FILE:
    SUBROUTINE
.loop:
    LDA (half_sector_pointer),Y
    CMP #$0a ; new line
    RTS_IF_EQ
    JSR PRINT_CHAR
    INY
    JMP .loop
