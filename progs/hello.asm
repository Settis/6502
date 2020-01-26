	processor 6502

TTY	equ $7000

	org $8000
msg	dc.b "Hello Kozjavr!",$00
	
main	ldx #$0
loop	lda msg,x
	beq end
	sta TTY
	inx
	jmp loop
end	brk
	
	org $FFFC
	dc.w main
