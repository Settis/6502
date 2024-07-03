	processor 6502

	org $8000
	
msg	dc.b "Hello",$00

main	ldx #$00
loop	lda msg,x
	beq end
	sta $7000
	inx
	jmp loop

end	brk

	org $fffc
	dc.w main
