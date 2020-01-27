	include	"std.asm"
	include "hello.asm"
	
welcome_msg:
	dc.b "Welcome to 6502 emulator.",newline,$00
menu_header:
	dc.b "Choose one of the option:",newline,$00
menu_1:
	dc.b " 1 - Say Hello",newline,$00

main	lda #clrtty
	sta TTY
	ldx #<welcome_msg
	ldy #>welcome_msg
	jsr write
	ldx #<menu_header
	ldy #>menu_header
	jsr write
	ldx #<menu_1
	ldy #>menu_1
	jsr write
	
menu_select:
	lda INPUT
	cmp #"1"
	beq menu_hello
	jmp menu_select

menu_hello:
	jsr say_hello
	jmp main
	

	org mainaddr
	dc.w main
