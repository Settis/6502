    processor 6502

    org $8000

    ldx #$3
loop:
    dex
    beq end
    JMP loop
end:
    lda #$aa
    

    org $FFFC
    dc.w $8000
