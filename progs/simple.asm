	processor 6502

	org $8000

	lda #"S"
	sta $7000
	tax

	org $FFFC
	dc.w $8000
