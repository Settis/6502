	processor 6502

TTY	equ $7000

	org $8000
	
main	jsr sec
	jsr frst
	brk

frst	lda #"I"
	sta TTY
	rts

sec	lda #"H"
	sta TTY
	rts
	
	org $FFFC
	dc.w main
