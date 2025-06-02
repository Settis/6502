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
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_S0 CONSTANT S0
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_LIB CONSTANT LIB
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_SD_BUF CONSTANT SD_BUF
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_KEY CONSTANT (KEY)
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_EMIT CONSTANT (EMIT)
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_STATE CONSTANT STATE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_IN CONSTANT IN
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_CURRENT CONSTANT CURRENT
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_CONTEXT CONSTANT CONTEXT
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FORTH_LINK CONSTANT FORTH-LINK
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_ERROR CONSTANT (ERROR)
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_DP CONSTANT DP
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_HLD CONSTANT HLD
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_BASE CONSTANT BASE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_WIDTH CONSTANT WIDTH
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_DPL CONSTANT DPL
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_CSP CONSTANT CSP

$20 CONSTANT BL

: -2
    $FFFE
;

: -1
    $FFFF
;

: 0
    0
;

: 1
    1
;

: 2
    2
;

: HEX
    $10 BASE ! 
;

: DECIMAL
    10 BASE ! 
;

: BIN
    2 BASE !
;

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

CODE +! ( n addr -- ) \ add number to the content by address
    LDA (SP)
    TAX
    LDY #2
    LDA (SP),Y
    CLC
    ADC 0,X
    STA 0,X
    CLC
    LDA SP
    ADC #4
    STA SP
END-CODE

CODE 0= ( N -- F )
    LDA (SP)
    BEQ @SKIP
    LDA #$FFFF
@SKIP:
    EOR #$FFFF
    STA (SP)
END-CODE

CODE = ( N N -- F )
    LDY #2
    LDA (SP),Y
    CMP (SP)
    BEQ @EQ
    LDA #0
    BRA @END
@EQ:
    LDA #$FFFF
@END:
    STA (SP),Y
    LDX SP
    INX
    INX
    STX SP
END-CODE

: <> ( N N -- F )
    = NOT
;

CODE < ( N N -- F )
    LDY #2
    LDA (SP),Y
    CMP (SP)
    BMI @LESS
    LDA #0
    BRA @END
@LESS:
    LDA #$FFFF
@END:
    STA (SP),Y
    LDX SP
    INX
    INX
    STX SP
END-CODE

: > ( N N -- F )
    \ not (less or eqal)
    2DUP < >R
    = R>
    OR NOT
;

: 0<
    0 <
;

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

CODE R> ( -- n )
    PLA
    JSR PUSH_DS
END-CODE

CODE R ( -- n )
    LDA 1,S
    JSR PUSH_DS
END-CODE

CODE >R ( n -- )
    JSR PULL_DS
    PHA
END-CODE

CODE + ( n n -- n )
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

CODE - ( n n -- n )
    LDY #2
    SEC
    LDA (SP),Y
    SBC (SP)
    STA (SP),Y
    LDX SP
    INX
    INX
    STX SP
END-CODE

CODE 1+ ( n -- n )
    LDA (SP)
    INC
    STA (SP)
END-CODE

CODE 2+ ( n -- n )
    LDA (SP)
    INC
    INC
    STA (SP)
END-CODE

CODE 1- ( n -- n )
    LDA (SP)
    DEC
    STA (SP)
END-CODE

CODE 2- ( n -- n )
    LDA (SP)
    DEC
    DEC
    STA (SP)
END-CODE

CODE 2* ( u -- u )
    LDX SP
    ASL 0,X
END-CODE

CODE 2/ ( u -- u )
    LDX SP
    LSR 0,X
END-CODE

CODE U* ( u u -- d )
GOES_LOW = FORTH_TMP_1
GOES_HIGH_L = FORTH_TMP_2
GOES_HIGH_H = FORTH_TMP_3

    LDY #2
    LDA (SP),Y
    STA GOES_LOW
    LDA (SP)
    STA GOES_HIGH_L
    LDA #0
    STA GOES_HIGH_H
    STA (SP)
    STA (SP),Y

    LDX #16
@MUL_LOOP:
    LSR GOES_LOW
    BCC @SKIP
    CLC
    LDA GOES_HIGH_L
    ADC (SP),Y
    STA (SP),Y
    LDA GOES_HIGH_H
    ADC (SP)
    STA (SP)
@SKIP:
    ASL GOES_HIGH_L
    ROL GOES_HIGH_H
    DEX
    BNE @MUL_LOOP
END-CODE

: * ( u u -- u )
    U* DROP
;

: MINUS ( n -- -n) \ change sign
    NOT 1+
;

: ABS ( n -- n )
    DUP 0< 
    IF MINUS THEN
;

CODE D+ ( d d -- d )
D_LOW = FORTH_TMP_1
D_HIGH = FORTH_TMP_2
    JSR PULL_DS
    STA D_HIGH
    JSR PULL_DS
    STA D_LOW
    LDY #2
    CLC
    LDA (SP),Y
    ADC D_LOW
    STA (SP),Y
    LDA (SP)
    ADC D_HIGH
    STA (SP)
END-CODE

CODE DMINUS ( d -- -d ) \ change sign on double
    LDY #2
    LDA (SP)
    EOR #$FFFF
    STA (SP)
    LDA (SP),Y
    EOR #$FFFF
    INC
    STA (SP),Y
    BNE @SKIP
    LDA (SP)
    INC
    STA (SP)
@SKIP:
END-CODE

: D- ( d d -- d )
    DMINUS D+
;

: DABS ( d -- d )
    DUP 0< 
    IF DMINUS THEN
;

: S>D ( n -- d )
    DUP 0< 
;

CODE DROP ( n -- )
    LDX SP
    INX
    INX
    STX SP
END-CODE

CODE 2DROP ( d -- )
    CLC
    LDA SP
    ADC #4
    STA SP
END-CODE

CODE DUP ( n -- n n )
    LDA (SP)
    JSR PUSH_DS
END-CODE

CODE 2DUP ( d -- d d )
    SEC       ; decrease pointer
    LDA SP
    SBC #4
    STA SP
    LDY #2

    LDY #6
    LDA (SP),Y
    LDY #2
    STA (SP),Y

    LDY #4
    LDA (SP),Y
    STA (SP)
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

CODE NOT ( u -- u )
    LDA (SP)
    EOR #$FFFF
    STA (SP)
END-CODE

CODE OR ( u u -- u )
    JSR PULL_DS
    ORA (SP)
    STA (SP)
END-CODE

CODE AND ( u u -- u )
    JSR PULL_DS
    AND (SP)
    STA (SP)
END-CODE

CODE XOR ( u u -- u )
    JSR PULL_DS
    EOR (SP)
    STA (SP)
END-CODE

CODE (FIND) ( NAME_ADDR DICTIONARY_RECORD_ADDR -- CFA NFA_FIRST_BYTE TF / FF )
    ; variables
NFA_ADDR = FORTH_TMP_1
NAME_ADDR = FORTH_TMP_2
WORD_LENGTH = FORTH_TMP_3

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
    STA WORD_LENGTH
@checkName:
    LDY #0
    LDA (NFA_ADDR)
    BIT #$20 ; check smudge flag
    BNE @nextRecord
    AND #$1F ; extract size only
    CMP WORD_LENGTH
    BNE @nextRecord
@nextChar:
    INY
    LDA (NAME_ADDR),Y
    CMP (NFA_ADDR),Y
    BNE @nextRecord
    CPY WORD_LENGTH
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
LOOP_TAIL:
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

CODE (+LOOP)
INCREMENT_VAL = FORTH_TMP_1
    JSR PULL_DS
    STA INCREMENT_VAL
    LDA 1,S
    CLC
    ADC INCREMENT_VAL
    STA 1,S
    JMP LOOP_TAIL
END-CODE
HIDE

CODE LEAVE
    PLA
    PLA
    PLA
    STA IP
END-CODE

CODE I ( -- n )
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

: FILL ( addr n b -- )
    SWAP 
    0 MAX   \ If n<0, make it 0.
    -DUP    \ DUP n only if n>0. 
    IF \ guard for not overwrite everything
        >R \ store n on the return stack
        OVER C! \ store b in addr
        DUP 1+  \ addr+1, to be filled with b
        R> 1-   \ n-1, number of butes to be filled by CMOVE
        -DUP
        IF 
            CMOVE   \ A primitive. Copy (addr) to (addr+1), (addr+1) to (addr+2),
                    \ etc, until all n locations are filled with b.
        THEN
    THEN
;

: ERASE ( addr n -- )
    0 FILL
;

: BLANKS ( addr n -- )
    BL FILL
;

CODE LOW_LEVEL_COLD_INIT
    A8_IND8
    ; INIT UART
    JSR UART_INIT
    STZ USER_IO_BUFFER_START
    STZ USER_IO_BUFFER_END

.ifdef FORTH_TRACE
    STZ DEBUG_INIT_STATUS
.endif

    LDA #(W65C22::PCR::CB2_lowOutput | W65C22::PCR::CA2_lowOutput)
    STA DISPLAY_PCR
    JSR DISPLAY_INIT

    LDA #%11000000
    STA TIMER_MS_VIA + W65C22::IER

    LDA #%01000000
    STA TIMER_MS_VIA + W65C22::ACR

    LDA #<TICKS_IN_MS-2
    STA TIMER_MS_VIA + W65C22::T1C_L
    LDA #>TICKS_IN_MS-2
    STA TIMER_MS_VIA + W65C22::T1C_H
    
    A16_IND16
    ; INIT USER VARIABLES
    LDX #INITIAL_USER_VARIABLES
    LDY #USER_VARIABLES
    LDA #END_INITIAL_USER_VARIABLES-INITIAL_USER_VARIABLES-1
    MVN 0, 0

    STZ TIMER_MS
    STZ TIMER_MS+2

    CLI
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
HIDE

: ." ( -- )
    $22                  \ hex ASCII value of the delimiter ".
    STATE @             \ Compiling or executing?
    IF                  \ Compiling state
        COMPILE (.")    \ Compile the code field address of (") so it will type out text at runtime.
        WORD            \ Fetch the text string delimited by " , and store it on top of dictionary,
                        \ in-line with the compiled addresses.
        HERE C@         \ Fetch the length of string
        1+ ALLOT        \ Move the dictionary pointer parsing the text string. Ready to compile the
                        \ next word in the same definition.
    ELSE                \ Executing state
        WORD            \ Get the text to HERE , on top of dictionary.
        HERE            \ Start of text string, ready to be typed out.
        COUNT TYPE
    THEN
;
IMMEDIATE

: S" \ Usage: CREATE ERROR-MSG S" Testing error"
  $22
  WORD
  HERE C@
  1+ ALLOT
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
    DECIMAL
    CR
    ." Marcus-Forth"
    FORTH
    DEFINITIONS
    QUIT    
;

: FORTH
    FORTH-LINK
    CONTEXT !
;

: DEFINITIONS ( -- )
    CONTEXT @
    CURRENT !
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
            ."  ok"
        THEN
    AGAIN
;

: EMIT-SRC
    CR
    ." SRC: "
    LIB @
    BEGIN
        DUP C@
        DUP $5C <>
    WHILE
        EMIT
        1+
    REPEAT
    2DROP
    CR
;

: ERROR ( n -- )
    \ EMIT-SRC
    HERE COUNT TYPE \ Print name of the offending word on top of the dictionary.
    ." ? ERROR: "
    COUNT TYPE
    SP!             \ Clean the data stack.
    QUIT
;

: ?ERROR ( f n -- )
    SWAP
    IF 
        (ERROR) @ EXECUTE
    ELSE
        DROP
    THEN
;

: ?STACK ( -- )
    SP@ S0 @ >        \ SP is out of upper bound, stack underflow
    LABEL_MSG_STACK_UNDERFLOW ?ERROR        \ Error 1.
    SP@ HERE 80 + < \ SP is out of lower bound, stack overflow
    LABEL_MSG_STACK_OVERFLOW ?ERROR        \ Error 7.
;

: ?COMP
    STATE @
    0=
    LABEL_MSG_NOT_COMPILING ?ERROR
;

: ?EXEC ( -- )
    STATE @
    LABEL_MSG_NOT_EXEC ?ERROR
;

: ?PAIRS ( n n -- )
    -
    LABEL_MSG_NOT_PAIRS ?ERROR
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

CODE SP@
    LDA SP
    JSR PUSH_DS
END-CODE

: QUERY 
    LIB @      \ Read from key to line input buffer
    190 EXPECT \ Read 190 symbols
    LIB @ IN ! \ Init IN pointer
;
HIDE

: EXPECT ( addr n -- )
    2DUP + LINE_INPUT_GUARD \ guard at the end
    OVER +  \ addr+n, the end of text
    OVER    \ Start of text buffer
    DO      \ start address on the stack
        KEY   \ Get character from user input
        DUP 8 =  \ Check if it was the backspace
        IF
            OVER I <> \ is it the middle?
            DUP     \ for second check
            R> \ get iterator
            + 1-
            >R \ update iterator
            NOT + \ if it the start character will be decreased 
                  \ from backspabe to bell
        ELSE
            DUP $A = \ is it a line feed?
            IF
                DROP BL \ change it for space
                EMIT
                I LINE_INPUT_GUARD \ put the guard
                LEAVE
            ELSE
                DUP  \ save one for emit
                I C! \ put it to the buffer
            THEN
        THEN
        EMIT  \ Echo the key
    LOOP
    DROP \ drop buffer start
;
HIDE

: LINE_INPUT_GUARD ( addr -- )
    \ put at the address: space, backslash, space, zero
    BL OVER C!
    1+
    $5C OVER C! \ Backslash
    1+ 
    BL OVER C!
    1+ 
    0 SWAP C! 
;
HIDE

: \  special case for going to the next line
    R> DROP
;
IMMEDIATE

: INTERPRET
    BEGIN  \ interpret loop
        -FIND  \ read the word and try to find it
        IF     \ word is found
            STATE @ <  \ If the length byte < state , the word is to be compiled.
            IF
                ,
            ELSE
                EXECUTE
            THEN
        ELSE  \ No matching entry. Try to convert the text to a number.
            BL HERE DUP C@ + 1+ ! \ NUMBER convert string till the space, I have to put the space after the string
            HERE
            NUMBER
            DPL @ 1+  \ Is there a decimal point? If there is, DPL + 1 should be greater
                      \ than zero, i. e., true.
            IF
                DLITERAL
            ELSE
                DROP
                LITERAL
            THEN
        THEN
        ?STACK  \ Check the data stach overflow or underflow
    AGAIN  \ unconditional repeat, exit by backslash
;
HIDE

: COMPILE ( -- )
    ?COMP     \ Error if not compiling
    R>        \ Top of return stack is pointing to the next word following
    DUP 2+ >R \ Increment this pointer by 2 to point to the second word following
              \ COMPILE , which will be the next word to be executed. The word
              \ immediately following COMPILE should be compiled, not executed.
    @ ,       \ Do the compilation at run-time.
;

: LITERAL 
    STATE @
    IF
        COMPILE LIT ,
    THEN
;
IMMEDIATE

: DLITERAL 
    STATE @
    IF  
        SWAP
        LITERAL
        LITERAL
    THEN
;
IMMEDIATE

: LATEST ( -- addr )
    CURRENT @ @
;

: IMMEDIATE 
    LATEST C@ 
    $40 OR
    LATEST C!
;

: -FIND ( -- cfa b tf , or ff )
    BL WORD     \ Move text string delimited by blanks from input string to the top of
                \ dictionary HERE .
    HERE        \ The address of text to be matched.
    CONTEXT @ @ \ Fetch the name field address of the last word defined in the CONTEXT
                \ vocabulary and begin the dictionary search.
    (FIND)      \ A primitive. Search the dictionary starting at the address on stack for
                \ a name matching the text at the address second on stack. Return the
                \ parameter field address of the matching name, its length byte, and a
                \ boolean true flag on stack for a match. If no match is possible, only a
                \ boolean false flag is left on stack.
    DUP 0=      \ Look at the flag on stack
    IF          \ No match in CONTEXT vocabulary
        DROP    \ Discard the false flag
        HERE    \ Get the address of text again
        LATEST  \ The name field address of the last word defined in the CURRENT vocabulary
        (FIND)  \ Search again through the CURRENT vocabulary.
    THEN
;
HIDE

: '
    -FIND
    NOT LABEL_MSG_COMPILE_NOT_FOUND ?ERROR
    DROP
    LITERAL
;
IMMEDIATE

CODE ENCLOSE ( addr c --- addr n1 n2 n3 )
    ; variables
ENCLOSE_ADDR = FORTH_TMP_1

    JSR PULL_DS
    TAX   ; X - delimenter
    LDA (SP)
    STA ENCLOSE_ADDR
    TXA
    LDY #$FFFF

    A8
@FIRST_DELIM:
    INY
    CMP (ENCLOSE_ADDR),Y
    BEQ @FIRST_DELIM
    
    PHA
    PHY
    A16
    TYA
    JSR PUSH_DS
    PLY

    A8
    PLA
@WORD:
    INY
    CMP (ENCLOSE_ADDR),Y
    BNE @WORD

    PHA
    PHY
    A16
    TYA
    JSR PUSH_DS
    PLY

    A8
    PLA
@SECOND_DELIM:
    INY
    CMP (ENCLOSE_ADDR),Y
    BEQ @SECOND_DELIM

    A16
    TYA
    JSR PUSH_DS
END-CODE
HIDE

: WORD ( c -- )
    IN @            \ IN contains the text buffer pointer
    SWAP            \ Get delimiter c over the string address.
    ENCLOSE         \ A primitive word to scan the text. From the byte address and the
                    \ delimiter c , it determines the byte offset to the first non-delimiter
                    \ character, the offset to the first delimiter after the text string,
                    \ and the offset to the next character after the delimiter.
                    \ ( addr c --- addr n1 n2 n3 )
    IN +!           \ Increment IN by the character count, pointing to the next text string to
                    \ be parsed.
    OVER - >R       \ Save n2-n1 on return stack.
    R HERE C!       \ Store character count as the length byte at HERE .
    +               \ Buffer address + nl, starting point of the text string in the text
                    \ buffer.
    HERE 1+         \ Address after the length byte on dictionary.
    R>              \ Get the character count back from the return stack.
    CMOVE           \ Move the string from input buffer to top of dictionary.
;

: (
    IN @
    $29      \ ASCII ')'
    ENCLOSE  \ return IN 0 PAR_offset after_par
    IN +!
    2DROP    \ drop other offsets
    DROP     \ drop address
;
IMMEDIATE

: HERE ( -- addr )
    DP @   \ Fetch the address of the next available memory location above the dictionary.
;

: ALLOT ( n -- )
    DP +!  \ Increment dictionary pointer
;

: , ( n -- ) 
    HERE ! \ store n into the dictionary
    2 ALLOT
;

: C, ( b -- )
    HERE C!
    1 ALLOT
;

: CR
    $A EMIT
;

: SPACE
    BL EMIT
;

: SPACES ( n -- )
    0 MAX   \ If n<0, make it 0.
    -DUP    \ DUP n only if n>0.
    IF
        0 DO
            SPACE
        LOOP
    THEN
;

: KEY
    (KEY) @ EXECUTE
;

: EMIT
    (EMIT) @ EXECUTE
;

CODE UART_KEY
    A8_IND8
    LDX USER_IO_BUFFER_START
@WAIT_LOOP:
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

CODE DISP_PRINT
    JSR PULL_DS
    A8_IND8
    JSR DISPLAY_PRINT_CHAR
    A16_IND16
END-CODE

CODE DISP_CMD
    JSR PULL_DS
    A8_IND8
    JSR DISPLAY_SEND_COMMAND
    A16_IND16
END-CODE

: DISP_CLR
    1 DISP_CMD
;

: DISP_CTL ( f f f --  ) \ display, cursor, blink
    1 AND \ mask blink
    SWAP 2 AND OR \ mask cursor and merge with blink
    SWAP 4 AND OR \ mask display and merge
    8 OR \ display control bit
    DISP_CMD
;

: DISP_CUR ( n n -- ) \ line, column
    SWAP 
    $40 *
    OR
    $80 OR
    DISP_CMD
;

: DISP_SET_CHAR ( addr n -- ) \ 8 bytes after addr
    8 0 DO
        DUP 8 * I + $40 OR DISP_CMD
        OVER I + C@
        DISP_PRINT
    LOOP
;

: PAD ( -- n )
    HERE 68 +
;

: <# ( -- )
    PAD HLD !
;

: HOLD ( c -- )
    -1 HLD +!   \ Decrement HLD
    HLD @ C!    \ Store character c into PAD
;

: # ( d1 -- d2 )
    BASE @          \ Get the current base.
    M/MOD           \ Divide d1 by base. Double integer quotient is on top of data
                    \ stack and the remainder below it.
    ROT             \ Get the remainder over to top.
    9 OVER <        \ If remainder is greater than 9,
    IF 7 + THEN     \ make it an alphabet.
    $30 +           \ Add 30H to form the ASCII representation of a digit. 0 to 9 and A
                    \ to F (or above).
    HOLD            \ Put the digit in PAD in a reversed order. HLD is decremented
                    \ before the digit is moved.
;

: M/MOD ( d n -- r d ) \ return modulo and double quotient
    >R 0 R U/
    R> SWAP >R U/
    R>
;

CODE U/ ( ud u1 -- u2 u3 ) \ return reminder and quotient

MOVED_DIVIDENT = FORTH_TMP_1
ORIG_DIVIDENT_HIGH = FORTH_TMP_2
ORIG_DIVIDENT_LOW = FORTH_TMP_3
QUOTIENT = FORTH_TMP_4
    STZ QUOTIENT
    STZ MOVED_DIVIDENT

    JSR PULL_DS ; put divisor on stack
    PHA

    JSR PULL_DS
    STA ORIG_DIVIDENT_HIGH
    JSR PULL_DS
    STA ORIG_DIVIDENT_LOW

    LDY #32
@LOOP:
    ASL ORIG_DIVIDENT_LOW
    ROL ORIG_DIVIDENT_HIGH
    ROL MOVED_DIVIDENT

    SEC
    LDA MOVED_DIVIDENT
    SBC 1,S
    BCC @DONT_UPDATE
    STA MOVED_DIVIDENT
@DONT_UPDATE:
    ROL QUOTIENT

    DEY
    BNE @LOOP

    PLA ; pull the divisor

    LDA MOVED_DIVIDENT
    JSR PUSH_DS
    LDA QUOTIENT
    JSR PUSH_DS
END-CODE

: #S ( d1 -- d2 )
    BEGIN
        #           \ Convert one digit.
        2DUP OR 0=  \ d2=0?
    UNTIL           \ Exit if d2=0, conversion done.  Otherwise repeat.
;

: SIGN ( n d -– d )
    ROT 0<       \ Is n negative?
    IF
        $2D HOLD \ Add - sign to text string.
    THEN
;

: #> ( d -- addr count )
    DROP DROP    \ Discard d.
    HLD @        \ Fetch the address of the last character in the text string.
    PAD OVER -   \ Calculate the character count of the text string.
;

: D.R ( d n -- )
    >R              \ Store n on return stack.
    SWAP OVER       \ Save the high order part of d under d, to be used by SIGN to add a -
                    \ sign to a negative number.
    DABS            \ Convert d to its absolute value.
    <# #S SIGN #>   \ Convert the absolute value to ASCII text with proper sign.
    R>              \ Retrieve n from the return stack.
    OVER - SPACES   \ Fill the output field with preceding blanks.
    TYPE            \ Type out the number.
;

: D. ( d -- )
    0 \ 0 field width.
    D.R
;

: .R ( n1 n2 -- )
    >R      \ Save n2 on return stack.
    S>D     \ Extend the single integer to a double integer
            \ with the same sign.
    R> D.R  \ Formatted output.
;

: . ( n -- )
    S>D \ Sign-extend the single integer.
    D.  \ Free format output.
;

CODE DIGIT ( c n1 -- n2 tf or ff )
DIGIT_BASE = FORTH_TMP_1
    JSR PULL_DS
    STA DIGIT_BASE
    JSR PULL_DS
    SEC
    SBC #$30 ; - '0' ASCII
    BMI @FAIL ; it should be positive
    CMP #10 ; is it a 0-9?
    BCC @CHECK_BASE
    AND #$FFDF ; to upper case
    ; SEC ; is here after the BCC check
    SBC #7
    CMP #10 ; it should >= 10
    BCC @FAIL
@CHECK_BASE:
    CMP DIGIT_BASE
    BCS @FAIL
    JSR PUSH_DS
    LDA #$FFFF
    JSR PUSH_DS
    JMP NEXT
@FAIL:
    LDA #$0
    JSR PUSH_DS
END-CODE

: (NUMBER) ( d1 addr1 -- d2 addr2 )
    BEGIN
        1+ DUP >R       \ Save addr1+1, address of the first digit, on return stack.
        C@              \ Get a digit
        BASE @          \ Get the current base
        DIGIT           \ A primitive. ( c n1 -- n2 tf or ff ) Convert the character c
                        \ according to base n1 to a binary number n2 with a true flag on top
                        \ of stack. If the digit is an invalid character, only a false flag
                        \ is left on stack.
    WHILE               \ Successful conversion, accumulate into d1.
        SWAP            \ Get the high order part of d1 to the top.
        BASE @ U*       \ Multiply by base value
        DROP            \ Drop the high order part of the product
        ROT             \ Move the low order part of d1 to top of stack
        BASE @ U*       \ Multiply by base value
        D+              \ Accumulate result into d1
        DPL @ 1+        \ See if DPL is other than -1
        IF              \ DPL is not -1, a decimal point was encountered
            1 DPL +!    \ Increment DPL, one more digit to right of decimal point
        THEN
        R>              \ Pop addr1+1 back to convert the next digit.
    REPEAT              \ If an invalid digit was found, exit the loop here. Otherwise
                        \ repeat the conversion until the string is exhausted.
    R>                  \ Pop return stack which contains the address of the first non-
                        \ convertable digit, addr2.
;
HIDE

: NUMBER ( addr -- d )
    BASE @ >R                           \ BASE is recognized from the number. Preserve the current BASE
    0 0 ROT                             \ Push two zero's on stack as the initial value of d .
    DUP 1+ C@                           \ Get the first digit
    DUP $24 = \ Is it a $ sign?
    IF
        HEX DROP 1+
    ELSE
        $25 = \ Is it a % sign?
        IF 
            BIN 1+
        ELSE
            DECIMAL
        THEN
    THEN
    DUP 1+ C@                           \ Get the first digit
    $2D =                               \ Is it a - sign?
    DUP >R                              \ Save the flag on return stack.
    -                                   \ If the first digit is -, the flag is FFFF, and addr-1 points to the
                                        \ second digit. If the first digit is not -, the flag is 0. addr+0
                                        \ remains the same, pointing to the first digit.
    -1                                  \ The initial value of DPL
    BEGIN                               \ Start the conversion process
        DPL !                           \ Store the decimal point counter
        (NUMBER)                        \ Convert one digit after another until an invalid char occurs.
                                        \ Result is accumulated into d .
        DUP C@                          \ Fetch the invalid digit
        BL -                            \ Is it a blank?
    WHILE                               \ Not a blank, see if it is a decimal point
        DUP C@                          \ Get the digit again
        $2E -                           \ Is it a decimal point?
        LABEL_MSG_WRONG_NUMBER ?ERROR   \ Not a decimal point. It is an illegal character for a number.
                                        \ Issue an error message and quit.
        0                               \ A decimal point was found. Set DPL to 0 the next time.
    REPEAT                              \ Exit here if a blank was detected. Otherwise repeat the
                                        \ conversion process.
    DROP                                \ Discard addr on stack
    R>                                  \ Pop the flag of - sign back
    IF DMINUS THEN                      \ Negate d if the first digit is a - sign.
                                        \ All done. A double integer is on stack.
    R> BASE !                           \ return BASE back
;

: !CSP ( -- )
    SP@ CSP !
;

: ?CSP ( -- )
    SP@         \ Current stack pointer
    CSP @       \ Saved stack pointer
    -           \ If not equal,
    LABEL_MSG_WRONG_STACK_POINT ?ERROR   \ issue errro message 14.
;

: MIN ( n n -- n )
    2DUP >
    IF
        SWAP
    THEN
    DROP
;

: MAX ( n n -- n )
    2DUP <
    IF
        SWAP
    THEN
    DROP
;

: TOGGLE ( addr c -- )
    OVER C@ \ extract the byte
    XOR 
    SWAP C!
;

: CREATE ( -- )
    BL WORD             \ Bring the next string delimited by blanks to the top of
                        \ dictionary.
    HERE                \ Save dictionary pointer as name field address to be linked.
    DUP C@              \ Get the length byte of the string
    WIDTH @             \ WIDTH has the maximum number of characters allowed in the name field.
    MIN                 \ Use the smaller of the two, and
                        \ FIX: I should update name length here
    1+ ALLOT            \ allocate space for name field, and advance DP to link field.
    DUP $80 TOGGLE      \ byte of the name field. Make a 'smudged' head so that dictionary
                          \ search will not find this name .
        \ it will be smudged by : word
    LATEST ,            \ Compile the name field address of the last word in the link field,
                        \ extending the linking chain.
    CURRENT @ !         \ Update contents of LATEST in the current vocabulary.
    LABEL_DOVAR ,       \ put variable CFA here, for easy variable definitions    
;

: SMUDGE ( -- )
    LATEST $20 TOGGLE
;

: ; ( -- )
    ?CSP        \ Check the stack pointer with that saved in CSP . If they differ,
                \ issue an error message.
    COMPILE DOSEMICOL  \ Compile the code field address of the word ;S into the dictionary,
                \ at run-time. ;S will return execution to the calling definition.
    SMUDGE      \ Toggle the smudge bit back to zero. Restore the length byte in
                \ the name field, thus completing the compilation of a new word.
    [ \ Set STATE to zero and return to the executing state.
;
IMMEDIATE

: : ( -- )
    ?EXEC               \ Issue an error message if not executing.
    !CSP                \ Save the stack pointer in CSP to be checked by ';' or ;CODE .
    CURRENT @ CONTEXT ! \ Make CONTEXT vocabulary the same as the CURRENT vocabulary.
    CREATE              \ Now create the header and establish linkage with the current
                        \ vocabulary.
    SMUDGE  \ by default CREATE definition is searchable
    LABEL_DOCOL HERE 2- !  \ Set docol executor
    ]                   \ Change STATE to non-zero. Enter compiling state and compile the
                        \ words following till ';' or ;CODE .
;

: CONSTANT ( n -- )
    CREATE
    LABEL_DOCON HERE 2- ! \ Update CFA for CONSTANT runtime
    ,
;

: VARIABLE ( -- )
    CREATE
    \ CFA 
    \ LABEL_DOVAR HERE 2- ! \ Update CFA for VARIABLE runtime
    0 ,
;

: [COMPILE] ( -- )
    -FIND       \ Accept next text string and search dictionary for a match.
    NOT LABEL_MSG_COMPILE_NOT_FOUND ?ERROR \ No matching entry was found. Issue an error message.
    DROP        \ Discard the length byte of the found name.
    ,       \ compile it into the dictionary.
; 
IMMEDIATE

: IF ( f -- ) \ at run-time
    \ ( -- addr n ) \ at compile time
    COMPILE 0BRANCH \ Compile the code field address of the run-time routine 0BRANCH into the
                    \ dictionary when IF is executed.
    HERE            \ Push dictionary address on stack to be used by ELSE or ENDIF to calculate
                    \ branching offset.
    0 ,             \ Compile a dummy zero here, later it is to be replaced by an offset value
                    \ used by 0BRANCH to compute the next word address.
    2               \ Error checking number.
            \ IF in a colon definition must be executed, not compiled.
;
IMMEDIATE

: THEN ( addr n -- ) \ at compile time
    ?COMP          \ Issue an error message if not compiling.
    2 ?PAIRS       \ ENDIF must be paired with IF or ELSE . If n is not 2, the structure was
                   \ disturbed or improperly nested. Issue an error message.
    HERE           \ Push the current dictionary address to stack.
    SWAP !         \ Store the offset in addr , thus completing the IF-ENDIF or IF-ELSE-ENDIF
                   \ construct.
; 
IMMEDIATE

: ELSE ( addr1 n1 -- addr2 n2 ) \ at compile time
    2 ?PAIRS        \ Error checking for proper nesting.
    COMPILE BRANCH  \ Compile BRANCH at run-time when ELSE is executed.
    HERE            \ Push HERE on stack as addr2 .
    0 ,             \ Dummy zero reserving a cell for branching to ENDIF .
    SWAP            \ Move addr1 to top of stack.
    2               \ I need to put 2 here for check inside ENDIF
    [COMPILE] THEN \ Call ENDIF to work on the offset for forward branching. ENDIF is an
                    \ immediate word. To compile it the word [COMPILE] must be used.
    2               \ Leave n2 on stack for error checking.
; 
IMMEDIATE

: BEGIN ( -- addr n ) \ at compile time
    ?COMP \ Issue an error message if not compiling.
    HERE  \ Push dictionary pointer on stack to be used to compute backward branching offset.
    1     \ Error checking number.
; 
IMMEDIATE

: UNTIL ( addr n -- ) \ at compile time
    1 ?PAIRS        \ If n is not 1, issue an error message.
    COMPILE 0BRANCH \ Compile 0BRANCH at run-time.
    ,               \ Compute backward branching offset and compile the offset.
; 
IMMEDIATE

: AGAIN ( addr n -- ) \ at compile time
    1 ?PAIRS       \ Error checking.
    COMPILE BRANCH \ Compile BRANCH and an offset to BEGIN .
    ,
; 
IMMEDIATE

: WHILE ( addr1 n1 -- addr1 n1 addr2 n2 n3 ) \ at compile time
    [COMPILE] IF \ Call IF to compile 0BRANCH and the offset.
    4            \ Leave 4 as n2 to be checked by REPEAT.
; 
IMMEDIATE

: REPEAT ( addr1 n1 addr2 n2 n3 -- ) \ at compile time
    4 ?PAIRS        \ Error checking for WHILE
    >R >R           \ Get addr2 and n2 out of the way.
    [COMPILE] AGAIN \ Let AGAIN do the dirty work of compiling an unconditional branch back to BEGIN .
    R> R>           \  Restore addr2 and n2 .
    [COMPILE] THEN \  Use ENDIF to resolve the forward branching needed by WHILE .
; 
IMMEDIATE

: DO ( n1 n2 -- ) \ at runtime
    \ ( -- addr n ) \ at compile time
    COMPILE (DO) \ Compile the run-time routine address of (DO) into dictionary.
    HERE         \ Address addr for backward branching from LOOP or +LOOP.
    0 ,          \ placeholder for loop end
    3            \ Number for error checking.
; 
IMMEDIATE

: LOOP ( addr n -- ) \ at runtime
    3 ?PAIRS \ Check the number left by DO . If it is not 3, issue an error message.
             \ The loop is not properly nested.
    COMPILE (LOOP)
    DUP      \ I need to put two links
    2+ , \ put the backward branching
    HERE SWAP ! \ patching leave address
; 
IMMEDIATE

: +LOOP 
    3 ?PAIRS \ Check the number left by DO . If it is not 3, issue an error message.
             \ The loop is not properly nested.
    COMPILE (+LOOP)
    DUP      \ I need to put two links
    2+ , \ put the backward branching
    HERE SWAP ! \ patching leave address
; 
IMMEDIATE

CODE UPTIMEMS ( -- d ) \ put ms since start
    SEI
    LDA TIMER_MS
    JSR PUSH_DS
    LDA TIMER_MS+2
    JSR PUSH_DS
    CLI
END-CODE

: ? ( addr -- )
    @ . \ Fetch the number and type it out.
;
