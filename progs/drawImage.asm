	include "microchipdata.asm"

data_l	equ $20
data_h 	equ $21
page	equ $22
page_size equ $23
; 24 - 26 reserved for page_size
pixel_l equ $27
pixel_h equ $28
current_page_size equ $29

draw_image:
	lda #<microchip_data
	sta data_l
	lda #>microchip_data
	sta data_h
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

	jsr read_key
	rts
