CODE DOSEMICOL ( -- ) \ ;S
    PLA
    STA IP
END-CODE
HIDE

CODE LIT ( -- n ) \ reads next two bytes and put them to stack
    LDA (IP)
    JSR PUSH_DS
    LDA IP
    INC A
    INC A
    STA IP
END-CODE
HIDE

USER_VARIABLES-INITIAL_USER_VARIABLES+UV_R0 CONSTANT R0
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_D0 CONSTANT D0
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_S0 CONSTANT S0
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_LIB CONSTANT LIB
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_KEY CONSTANT (KEY)
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_EMIT CONSTANT (EMIT)
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_STATE CONSTANT STATE

CODE EXECUTE ( cfa -- )
    JSR PULL_DS
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
    JSR PULL_DS
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
    JSR PUSH_DS
END-CODE

CODE R
    LDA 1,S
    JSR PUSH_DS
END-CODE

CODE >R
    JSR PULL_DS
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

CODE 1+
    LDA (SP)
    INC
    STA (SP)
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
    JSR PUSH_DS
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
    JSR PUSH_DS
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
    JSR PULL_DS
    ORA (SP)
    STA (SP)
END-CODE

CODE AND
    JSR PULL_DS
    AND (SP)
    STA (SP)
END-CODE

CODE XOR
    JSR PULL_DS
    EOR (SP)
    STA (SP)
END-CODE

CODE (FIND) ( NAME_ADDR DICTIONARY_RECORD_ADDR -- CFA NFA_FIRST_BYTE TF / FF )
    JSR PULL_DS
    STA NFA_ADDR
    JSR PULL_DS
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
    JSR PUSH_DS
    PLX
    TXA
    JSR PUSH_DS
    LDA #$FFFF
    JSR PUSH_DS
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
    JSR PUSH_DS
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
    JSR PUSH_DS
END-CODE

CODE CMOVE ( from to u -- )
    LDY #4
    LDA (SP),Y
    TAX
    
    DEY
    DEY
    LDA (SP),Y
    TAY

    LDA (SP)
    DEC A

    MVN 0, 0

    CLC
    LDA SP
    ADC #6
    STA SP
END-CODE

CODE LOW_LEVEL_COLD_INIT
    A8_IND8
    ; INIT UART
    JSR UART_INIT
    STZ USER_IO_BUFFER_START
    STZ USER_IO_BUFFER_END
    
    A16_IND16
    ; INIT USER VARIABLES
    LDX #INITIAL_USER_VARIABLES
    LDY #USER_VARIABLES
    LDA #END_INITIAL_USER_VARIABLES-INITIAL_USER_VARIABLES-1
    MVN 0, 0
END-CODE
HIDE

: (.") ( -- )
    R       \ Copy EP from the return stack, which points to the beginning of the in-
            \ line text string.
    COUNT   \ Get the length byte of the string, preparing for TYPE.
    DUP 1+  \ Length+1
    R> + >R \ Increment EP on the return stack by length+l, thus skip the text string
            \ and point to the next word after ", which is the next word to be
            \ executed.
    TYPE    \ Now type out the text string.
;

: COUNT ( addr1 -- addr2 n )
    DUP 1+  \ addr2=addr1+1
    SWAP    \ Swap addr1 over addr2 and
    C@      \ fetch the byte count to the stack.
;

CODE -DUP ( n - n ? )
    LDA (SP)
    BEQ @SKIP
    JSR PUSH_DS
@SKIP:
END-CODE

: TYPE ( addr n - )
    -DUP            \ Copy n if it is not zero.
    IF              \ n is non-zero, do the following.
        OVER +      \ addr+n, the end of the text
        SWAP        \ addr, start of text
        DO          \ Loop to type n characters
            I C@    \ Fetch one character from text
            EMIT    \ Type it out
        LOOP
    ELSE            \ n=0, no output necessary.
        DROP        \ Discard addr
    THEN
;

: COLD
    LOW_LEVEL_COLD_INIT
    \ DISK BUFFER INIT
    ABORT
;

: ABORT
    SP!
    CR
    ." Marcus-Forth"
    \ FORTH
    \ DEFINITIONS
    QUIT    
;

: QUIT
    \ [COMPILE] \ I don't need it here
    [ \ for set STATE to 0
    BEGIN
        RP!
        CR
        QUERY
        INTERPRET
        STATE @ 0=
        IF
            ." ok"
        THEN
    AGAIN
;

: [
    0 STATE !
;
IMMEDIATE

: ]
    $C0 STATE !
;

CODE RP!
    LDX USER_VARIABLES-INITIAL_USER_VARIABLES+UV_R0
    TXS
END-CODE
HIDE

CODE SP!
    LDA USER_VARIABLES-INITIAL_USER_VARIABLES+UV_S0
    STA SP
END-CODE
HIDE

: QUERY 
    BEGIN
        KEY
        EMIT
    AGAIN
;
HIDE

: INTERPRET
;
HIDE

: CR
    $A EMIT
;

: SPACE
    $20 EMIT
;

: KEY
    (KEY) @ EXECUTE
;

: EMIT
    (EMIT) @ EXECUTE
;

CODE UART_KEY
    A8_IND8
@WAIT_LOOP:
    LDX USER_IO_BUFFER_START
    CPX USER_IO_BUFFER_END
    BEQ @WAIT_LOOP
    LDA USER_IO_BUFFER,X
    TAY ; CHAR in Y
    INX
    TXA
    AND #USER_IO_BUFFER_MASK
    STA USER_IO_BUFFER_START
    A16_IND16
    TYA
    JSR PUSH_DS
END-CODE

CODE UART_EMIT
    JSR PULL_DS
    A8_IND8
    JSR UART_WRITE
    A16_IND16
END-CODE
