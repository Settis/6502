hello_ask:
	dc.b "Type your name: ",$00
hello_1	dc.b "Hello ",$00
hello_2 dc.b ", nice to meet you!",$00

say_hello:
	ldx #<hello_ask
	ldy #>hello_ask
	jsr write
	jsr read_line
	ldx #<hello_1
	ldy #>hello_2
	jsr write
	ldx #<read_line_addr
	ldy #>read_line_addr
	jsr write
	ldx #<hello_2
	ldy #>hello_2
	jsr write
	jsr read_key
	rts
	
