; http://8bitworkshop.com/
; runs on Atari platform
; The program has look subroutine and it try to iterate over bytes after "look" calls
    
    processor 6502
        
    org $f000

Start:
    LDX #$FF
    TXS
    LDA #$FF
    LDA #$55
    ; Loop over the next data prefixed with length
    JSR loop
    ; length
    .byte 3
    ; 3 bytes
    .byte $AF
    .byte $B2
    .byte $D1
    ; those instructions must be done after "loop" call
    LDA #$11
    LDA #$55
        
loop:
    ; read the last program pointer and store it into $80..$81
	TSX
    LDA $101,X
    STA $80
    LDA $102,X
    STA $81
    ; read data length and store it into $82
    LDY #1
    LDA ($80),Y
    STA $82
    ; update program pointer to jump over the data
    SEC 
    ADC $80
    STA $101,X
    LDA $81
    ADC #0
    STA $102,X
    ; iterate over the data
    ; the loop ignores the last data element it's a BUG
innerLoop:
	CPY $82
    BEQ end
    INY
    LDA ($80),Y
    JMP innerLoop
end
    RTS
        

	org $fffc
        .word Start	; reset vector
        .word Start	; BRK vector