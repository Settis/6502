; lib for work with terminal
; write writes string X and Y contains L and H addres
; read_key reads key into A register. Loops until reads something.
; read_line reads line ended with newline. Send it to TTY async.

TTY	equ $7000
INPUT	equ $7001
newline equ $A
backspace equ $8
clrtty	equ $80
read_line_addr equ $10

buffer_empty_bit:
	dc $80
char_mask:
	dc $7f

write	stx $00
	sty $01
	ldy #$00
wloop	lda ($00),y
	beq wend
	sta TTY
	iny
	jmp wloop
wend	rts

read_key:
	lda INPUT
	beq read_key
	rts

read_line:
	ldx #$00
read_loop:
	jsr read_key
	sta TTY
	cmp #backspace
	bne check_nl
	dex
	jmp read_loop
check_nl:
	cmp #newline
	bne save_char
	lda #$00
	sta read_line_addr,x
	rts
save_char:
	sta read_line_addr,x
	inx
	jmp read_loop
