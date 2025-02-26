CODE DOSEMICOL ( -- ) \ ;S
    PLA
    STA IP
END-CODE
HIDE

CODE LIT ( -- n ) \ reads next two bytes and put them to stack
    LDA (IP)
    JSR PUSH_SP
    LDA IP
    INC A
    INC A
    STA IP
END-CODE
HIDE

CODE EXECUTE ( cfa -- )
    JSR PULL_SP
    TAX
    INC A
    INC A
    STA W
    JMP (0,X)
END-CODE

CODE ! ( n addr -- )
    LDA (SP)
    TAX
    LDY #2
    LDA (SP),Y
    STA 0,X
    CLC
    LDA SP
    ADC #4
    STA SP
END-CODE

CODE @ ( addr -- n )
    LDA (SP)
    TAX
    LDA 0,X
    STA (SP)
END-CODE

CODE C! ( b addr -- )
    LDA (SP)
    TAX
    LDY #2
    A8
    LDA (SP),Y
    STA 0,X
    A16
    CLC
    LDA SP
    ADC #4
    STA SP
END-CODE

CODE C@ ( addr -- b )
    LDA (SP)
    TAX
    LDA #0
    A8
    LDA 0,X
    A16
    STA (SP)
END-CODE

CODE 0= ( N -- F )
    LDA (SP)
    BEQ @SKIP
    LDA #$FFFF
@SKIP:
    EOR #$FFFF
    STA (SP)
END-CODE

CODE BRANCH ( -- )
    LDA (IP)
    STA IP
END-CODE
HIDE

CODE 0BRANCH ( F -- )
    JSR PULL_SP
    TAX ; for Z flag
    BNE @SKIP
    JMP FORTH_WORD_BRANCH_CODE
@SKIP:
    LDA IP
    INC A
    INC A
    STA IP
END-CODE
HIDE

CODE R>
    PLA
    JSR PUSH_SP
END-CODE

CODE R
    LDA 1,S
    JSR PUSH_SP
END-CODE

CODE >R
    JSR PULL_SP
    PHA
END-CODE

CODE +
    LDY #2
    CLC
    LDA (SP),Y
    ADC (SP)
    STA (SP),Y
    LDX SP
    INX
    INX
    STX SP
END-CODE

CODE 2*
    LDX SP
    ASL 0,X
END-CODE

CODE DROP ( n -- )
    LDX SP
    INX
    INX
    STX SP
END-CODE

CODE DUP ( n -- n n )
    LDA (SP)
    JSR PUSH_SP
END-CODE

CODE SWAP ( a b -- b a )
    LDY #2
    LDA (SP),Y
    TAX
    LDA (SP)
    STA (SP),Y
    TXA
    STA (SP)
END-CODE

CODE OVER ( a b -- a b a )
    LDY #2
    LDA (SP),Y
    JSR PUSH_SP
END-CODE

CODE ROT ( a b c -- b c a )
    LDY #4
    LDA (SP),Y ; + 4
    TAX        ; a -> X
    DEY
    DEY
    LDA (SP),Y ; + 2
    INY
    INY
    STA (SP),Y ; + 4 write b
    DEY
    DEY
    LDA (SP)
    STA (SP),Y ; + 2 write c
    TXA
    STA (SP)   ; write a
END-CODE

CODE NOT
    LDA (SP)
    EOR #$FFFF
    STA (SP)
END-CODE

CODE OR
    JSR PULL_SP
    ORA (SP)
    STA (SP)
END-CODE

CODE AND
    JSR PULL_SP
    AND (SP)
    STA (SP)
END-CODE

CODE XOR
    JSR PULL_SP
    EOR (SP)
    STA (SP)
END-CODE

CODE (FIND) ( NAME_ADDR DICTIONARY_RECORD_ADDR -- CFA NFA_FIRST_BYTE TF / FF )
    JSR PULL_SP
    STA NFA_ADDR
    JSR PULL_SP
    STA NAME_ADDR
    A8_IND8
    ; Check name max length
    LDA (NAME_ADDR)
    CMP #32
    BCC @normalSize
    LDA #31 ; the maximum size
@normalSize:
    STA TMP_WORD_LENGTH
@checkName:
    LDY #0
    LDA (NFA_ADDR)
    BIT #$20 ; check smudge flag
    BNE @nextRecord
    AND #$1F ; extract size only
    CMP TMP_WORD_LENGTH
    BNE @nextRecord
@nextChar:
    INY
    LDA (NAME_ADDR),Y
    CMP (NFA_ADDR),Y
    BNE @nextRecord
    CPY TMP_WORD_LENGTH
    BNE @nextChar
    ; found !
    LDA (NFA_ADDR)
    INY ; LFA
    INY
    INY ; + 2 CFA
    TAX
    A16_IND16
    TYA
    CLC
    ADC NFA_ADDR
    PHX
    JSR PUSH_SP
    PLX
    TXA
    JSR PUSH_SP
    LDA #$FFFF
    JSR PUSH_SP
    JMP NEXT

@nextRecord:
    .a8
    .i8
    LDA (NFA_ADDR)
    AND #$1F
    TAY
    INY ; LFA
    A16_IND16
    LDA (NFA_ADDR),Y
    BNE @nextExists
    LDA #0
    JSR PUSH_SP
    JMP NEXT
@nextExists:
    STA NFA_ADDR
    A8_IND8
    .a16 ; it's not correct here, but I did it for FORTH compiler 
    .i16
    JMP @checkName ; this JMP is the last thing, and JMP NEXT will not be added
END-CODE
HIDE

CODE (DO)
    LDA (IP) ; Read address for LEAVE
    PHA
    LDA IP
    INC A
    INC A
    STA IP

    LDY #2 ; Read boundary
    LDA (SP),Y
    PHA

    LDA (SP) ; Read index
    PHA

    CLC     ; Update stack pointer
    LDA SP
    ADC #4
    STA SP
END-CODE
HIDE

CODE (LOOP)
    LDA 1,S
    INC
    STA 1,S
    ; Here +LOOP can jump
    CMP 3,S
    BCC @PROCEED
    PLA
    PLA
    PLA
    LDA IP
    INC A
    INC A
    STA IP
    JMP NEXT
@PROCEED:
    LDA (IP)
    STA IP
    JMP NEXT
END-CODE
HIDE

CODE LEAVE
    PLA
    PLA
    PLA
    STA IP
END-CODE

CODE I
    LDA 1,S
    JSR PUSH_SP
END-CODE
