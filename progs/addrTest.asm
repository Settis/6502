; Testing addressing by read something to A and write it to terminal
; Letters will be placed in different places and must be writed to terminal
; 
; A - ZP $22 => $0022
; B - ZP $33,X | X=2 => $0035
; C - ZP $B1,X | X=79 => $002A
; D - Abs $8702 => $8702
; E - Abs $8741,X | X=7 => $8748
; F - Abs $87A9,X | X=97 => $8840
; G - Abs $9015,Y | Y=56 => $906B
; H - Abs $9118,Y | Y=FF => $9217
; I - Ind ($44,X) | X=8 | ZP $4C => $92F0
; J - Ind ($50),Y | Y=18 | ZP $50 val $93B1 => $93C9

	processor 6502

TTY	equ $7000
	
	org $8000
; Init
	lda #"A"
	sta $0022

	lda #"B"
	sta $0035

	lda #"C"
	sta $002a

	lda #$92
	sta $004d

	lda #$f0
	sta $004c

	lda #$93
	sta $0051
	
	lda #$b1
	sta $0050

; Test
	lda $22
	sta TTY

	ldx #$2
	lda $33,x
	sta TTY

	ldx #$79
	lda $b1,x
	sta TTY

	lda $8702
	sta TTY

	ldx #$7
	lda $8741,x
	sta TTY

	ldx #$97
	lda $87a9,x
	sta TTY

	ldy #$56
	lda $9015,y
	sta TTY

	ldy #$ff
	lda $9118,y
	sta TTY

	ldx #$8
	lda ($44,x)
	sta TTY

	ldy #$18
	lda ($50),y
	sta TTY

; Other data

	org $8702
	dc "D"
	
	org $8748
	dc "E"

	org $8840
	dc "F"

	org $906b
	dc "G"

	org $9217
	dc "H"

	org $92f0
	dc "I"

	org $93c9
	dc "J"
	
	org $FFFC
	dc.w $8000
