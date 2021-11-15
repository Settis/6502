    processor 6502

    ORG $0300
    STA $89

 lda #2
    sta %10010
; ; <-- comment disabled . This IS assembled 


foo: equ $123

    echo foo

.foo: STA $5609
