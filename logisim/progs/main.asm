	include	"std.asm"
	include "hello.asm"
	include "drawX.asm"
	include "drawImage.asm"
	
welcome_msg:
	dc.b "Welcome to 6502 emulator.",newline,$00
menu_header:
	dc.b "Choose one of the option:",newline,$00
menu_1	dc.b " 1 - Say Hello",newline,$00
menu_2  dc.b " 2 - Draw X",newline,$00
menu_3  dc.b " 3 - Draw gallery",newline,$00

main	lda #clrtty
	sta TTY
	sta clrscr
	ldx #<welcome_msg
	ldy #>welcome_msg
	jsr write
	ldx #<menu_header
	ldy #>menu_header
	jsr write
	ldx #<menu_1
	ldy #>menu_1
	jsr write
	ldx #<menu_2
	ldy #>menu_2
	jsr write
	ldx #<menu_3
	ldy #>menu_3
	jsr write
	
menu_select:
	lda INPUT
	cmp #"1"
	beq menu_hello
	cmp #"2"
	beq menu_draw
	cmp #"3"
	beq menu_image
	jmp menu_select

menu_hello:
	jsr say_hello
	jmp main

menu_draw:
	jsr draw_x
	jmp main

menu_image:
	jsr draw_gallery
	jmp main

	org mainaddr
	dc.w main
