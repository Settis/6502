; draw X - two diagonales

i	equ $06

draw_x	lda #$0
	sta i
draw_main_loop:
	lda i
	cmp #$20
	beq draw_main_end
	tax
	tay
	lda #$1
	jsr draw_point
	inc i
	jmp draw_main_loop
draw_main_end:
	lda #$0
	sta i
draw_second_loop:
	lda i
	cmp #$20
	beq draw_end
	tax
	lda #$1f
	clc
	sbc i
	tay
	lda #$1
	jsr draw_point
	inc i
	jmp draw_second_loop
draw_end:
	jsr read_key
	rts
