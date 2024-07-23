    INCLUDE "../std/std.asm"

	SEG code
	JMP main

    INCLUDE "display.asm"

	SEG.U zpVars
FRAME_CHAR_START: ds 2
POSITION: ds 1
REPEATS: ds 1

	SEG code
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

	LDA #3
	STA REPEATS


MAIN_LOOP:
	; Clear display
	LDA #%00000001
	JSR SEND_DISPLAY_COMMAND
	JSR delay_1_52

	; Shift whole display 5 chars left
	FOR_X 0, UP_TO, 5
		LDA #%00011000
		JSR SEND_DISPLAY_COMMAND
	NEXT_X
	; write locomotive
	; Set cursor to 1 line 0 char
	LDA #%11000000
	JSR SEND_DISPLAY_COMMAND
	FOR_Y 0, UP_TO, 6
		TYA
		JSR PRINT_CHAR
	NEXT_Y

	LDA #16+5
	STA POSITION

THE_SAME_POS:
	WRITE_WORD CHARACTERS, FRAME_CHAR_START
	
	; Printing frame
	FOR_X 0, UP_TO, 6

		CASE X_REG
			CASE_OF #$0
				; write steam
				; Set cursor to 0 line 3 char
				LDA #%10000011
				JSR SEND_DISPLAY_COMMAND
				LDA #$6
				JSR PRINT_CHAR
				LDA #$7
				JSR PRINT_CHAR
				LDA #" "
				JSR PRINT_CHAR
			END_OF
			CASE_OF #$4
				; write steam
				; Set cursor to 0 line 3 char
				LDA #%10000011
				JSR SEND_DISPLAY_COMMAND
				LDA #" "
				JSR PRINT_CHAR
				LDA #$6
				JSR PRINT_CHAR
				LDA #$7
				JSR PRINT_CHAR
			END_OF
		END_CASE

		FOR_Y 0, UP_TO, 8*8
			TYA
			ORA #%01000000
			JSR SEND_DISPLAY_COMMAND
			LDA (FRAME_CHAR_START),Y
			JSR PRINT_CHAR
		NEXT_Y

		FOR_Y 0, UP_TO, 6
			JSR delay_10
		NEXT_Y

		CLC
		LDA FRAME_CHAR_START
		ADC #8*8
		STA FRAME_CHAR_START
		LDA FRAME_CHAR_START+1
		ADC #0
		STA FRAME_CHAR_START+1
	
	NEXT_X

	; Move whole display to right
	LDA #%00011100
	JSR SEND_DISPLAY_COMMAND

	DEC POSITION
	BNE THE_SAME_POS

	DEC REPEATS
	BEQ END_HERE
	JMP MAIN_LOOP
END_HERE:
	
    RTS
    
CHARACTERS:
; Frame #0
; Char 0
    DC %00000
	DC %00000
	DC %10000
	DC %11111
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 1
	DC %00000
	DC %00000
	DC %00010
	DC %11111
	DC %11111
	DC %11110
	DC %10100
	DC %01000
; Char 2
	DC %11111
	DC %01001
	DC %01001
	DC %01001
	DC %01111
	DC %11111
	DC %01010
	DC %00100
; Char 3
	DC %00000
	DC %00100
	DC %01110
	DC %11111
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 4
	DC %11110
	DC %01100
	DC %01100
	DC %11110
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 5
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
; Char 6
	DC %01010
	DC %10101
	DC %01001
	DC %10110
	DC %00100
	DC %11010
	DC %00001
	DC %00000
; Char 7
	DC %00000
	DC %10000
	DC %00000
	DC %01000
	DC %10000
	DC %01000
	DC %10100
	DC %01100
; Frame #1
; Char 0
	DC %00000
	DC %00000
	DC %01000
	DC %01111
	DC %01111
	DC %01111
	DC %00101
	DC %00010
; Char 1
	DC %00000
	DC %00000
	DC %00001
	DC %11111
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 2
	DC %01111
	DC %00100
	DC %00100
	DC %00100
	DC %10111
	DC %11111
	DC %00101
	DC %00010
; Char 3
	DC %00000
	DC %00010
	DC %00111
	DC %11111
	DC %11111
	DC %11111
	DC %00101
	DC %00010
; Char 4
	DC %01111
	DC %00110
	DC %00110
	DC %11111
	DC %11111
	DC %11111
	DC %00101
	DC %00010
; Char 5
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
; Char 6
	DC %01011
	DC %00110
	DC %00011
	DC %01010
	DC %00101
	DC %00010
	DC %00001
	DC %00000
; Char 7
	DC %00000
	DC %10000
	DC %01000
	DC %11000
	DC %01100
	DC %10010
	DC %01100
	DC %10100
; Frame #2
; Char 0
	DC %00000
	DC %00000
	DC %00100
	DC %00111
	DC %00111
	DC %00111
	DC %00010
	DC %00001
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %00101
	DC %00010
; Char 2
	DC %00111
	DC %00010
	DC %00010
	DC %10010
	DC %11011
	DC %01111
	DC %00010
	DC %00001
; Char 3
	DC %10000
	DC %10001
	DC %10011
	DC %11111
	DC %11111
	DC %11111
	DC %00010
	DC %00001
; Char 4
	DC %00111
	DC %00011
	DC %00011
	DC %11111
	DC %11111
	DC %11111
	DC %00010
	DC %00001
; Char 5
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %10000
	DC %10000
	DC %00000
	DC %00000
; Char 6
	DC %00001
	DC %00011
	DC %00000
	DC %00010
	DC %00001
	DC %00001
	DC %00000
	DC %00000
; Char 7
	DC %01000
	DC %10100
	DC %10010
	DC %01100
	DC %10000
	DC %01010
	DC %10110
	DC %01101
; Frame #3
; Char 0
	DC %00000
	DC %00000
	DC %00010
	DC %00011
	DC %00011
	DC %00011
	DC %00001
	DC %00000
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %10010
	DC %00001
; Char 2
	DC %00011
	DC %00001
	DC %10001
	DC %11001
	DC %11101
	DC %10111
	DC %00001
	DC %00000
; Char 3
	DC %11000
	DC %01000
	DC %01001
	DC %01111
	DC %11111
	DC %11111
	DC %10001
	DC %00000
; Char 4
	DC %00011
	DC %00001
	DC %10001
	DC %11111
	DC %11111
	DC %11111
	DC %10001
	DC %00000
; Char 5
	DC %10000
	DC %00000
	DC %00000
	DC %10000
	DC %11000
	DC %11000
	DC %10000
	DC %00000
; Char 6
	DC %00001
	DC %00000
	DC %00001
	DC %00001
	DC %00000
	DC %00001
	DC %00000
	DC %00000
; Char 7
	DC %01000
	DC %11100
	DC %11010
	DC %01100
	DC %10011
	DC %01100
	DC %00011
	DC %00001
; Frame #4
; Char 0
	DC %00000
	DC %00000
	DC %00001
	DC %00001
	DC %00001
	DC %00001
	DC %00000
	DC %00000
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %01001
	DC %10000
; Char 2
	DC %00001
	DC %00000
	DC %01000
	DC %11100
	DC %11110
	DC %11011
	DC %10000
	DC %00000
; Char 3
	DC %11100
	DC %00100
	DC %00100
	DC %00111
	DC %11111
	DC %11111
	DC %01000
	DC %10000
; Char 4
	DC %00001
	DC %10000
	DC %11000
	DC %11111
	DC %11111
	DC %11111
	DC %01000
	DC %10000
; Char 5
	DC %11000
	DC %10000
	DC %10000
	DC %11000
	DC %11100
	DC %11100
	DC %01000
	DC %10000
; Char 6
	DC %10100
	DC %01011
	DC %10101
	DC %01110
	DC %11101
	DC %10110
	DC %00101
	DC %00010
; Char 7
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %10000
	DC %10000
	DC %10000
; Frame #5
; Char 0
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %10100
	DC %01000
; Char 2
	DC %00000
	DC %00000
	DC %00100
	DC %11110
	DC %11111
	DC %11101
	DC %01000
	DC %10000
; Char 3
	DC %11110
	DC %10010
	DC %10010
	DC %10011
	DC %11111
	DC %11111
	DC %10100
	DC %01000
; Char 4
	DC %00000
	DC %01000
	DC %11100
	DC %11111
	DC %11111
	DC %11111
	DC %10100
	DC %01000
; Char 5
	DC %11100
	DC %11000
	DC %11000
	DC %11100
	DC %11110
	DC %11110
	DC %10100
	DC %01000
; Char 6
	DC %10100
	DC %11101
	DC %01011
	DC %11101
	DC %10001
	DC %01010
	DC %00001
	DC %00000
; Char 7
	DC %00000
	DC %10000
	DC %00000
	DC %10000
	DC %00000
	DC %10000
	DC %11000
	DC %01000
