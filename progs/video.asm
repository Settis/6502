; lib for work with videoadapter
; to_video_addr converts x and y to addres x - low and y - hight
; draw_point puts point in x,y coord depends on A value

clrscr	equ $7c00
monitor equ $78
tmp_x	equ $10
tmp_y	equ $11
tmp_l	equ $12
tmp_h	equ $13
tmp_val	equ $14

to_video_addr:
	stx tmp_x
	sty tmp_y
	txa
	clc
	ror 
	ror 
	ror
	ror
	and #$e0
	clc
	adc tmp_y
	tax
	lda tmp_x
	lsr
	lsr
	lsr
	clc
	adc #monitor
	tay
	rts

draw_point:
	sta tmp_val
	jsr to_video_addr
	stx tmp_l
	sty tmp_h
	lda tmp_val
	ldx #$0
	sta (tmp_l,x)
	rts
