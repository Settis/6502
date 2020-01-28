	include "images.asm"

data_l	equ $20
data_h 	equ $21
page	equ $22
page_size equ $23
; 24 - 26 reserved for page_size
pixel_l equ $27
pixel_h equ $28
current_page_size equ $29
current_image equ $2a
image_pointer equ $2b
image_addr equ $2c
image_addr_h equ $2d

draw_gallery:
	lda #$0
	sta current_image
	sta image_pointer
	lda #<images
	sta image_addr
	lda #>images
	sta image_addr_h
prepare_image:
	sta clrscr
	ldy image_pointer
	lda (image_addr),y
	sta data_l
	iny
	lda (image_addr),y
	sta data_h
	iny
	sty image_pointer
	jsr draw_image
	
	jsr read_key
	inc current_image
	ldx current_image
	cpx #images_count
	beq end_gallery
	cmp #"q"
	beq end_gallery
	jmp prepare_image
	
end_gallery:
	rts

draw_image:
	ldy #$0
	ldx #$0
	stx page
	lda (data_l),y
	sta page_size,x
	inx
	iny
	lda (data_l),y
	sta page_size,x
	inx
	iny
	lda (data_l),y
	sta page_size,x
	inx
	iny
	lda (data_l),y
	sta page_size,x
	lda #monitor
	sta pixel_h
	clc
	lda data_l
	adc #$4
	sta data_l
	lda data_h
	adc #$0
	sta data_h
draw_image_page:
	ldx page
	lda page_size,x
	sta current_page_size
	beq end_draw_image_page
	ldy #$0
	ldx #$0
draw_image_pixel:
	lda (data_l),y
	sta pixel_l
	lda #$1
	sta (pixel_l,x)
	iny
	cpy current_page_size
	bne draw_image_pixel
end_draw_image_page:	
	inc page
	clc
	lda data_l
	adc current_page_size
	sta data_l
	lda data_h
	adc #$0
	sta data_h
	inc pixel_h
	ldx page
	cpx #$4
	bne draw_image_page

	rts
