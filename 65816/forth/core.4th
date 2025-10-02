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
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_DISP_LINE CONSTANT DISP_LINE
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_PS2_STATUS CONSTANT PS2_STATUS
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_SEC_IN_CLUS CONSTANT FAT_SEC_IN_CLUS
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_ROOT_CLUS CONSTANT FAT_ROOT_CLUS
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_SECTOR CONSTANT FAT_SECTOR
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_DATA_SEC CONSTANT FAT_DATA_SEC
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_CUR_CLUSTER CONSTANT FAT_CUR_CLUSTER
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_CUR_SEC_IN_CLUSTER CONSTANT FAT_CUR_SEC_IN_CLUSTER
HIDE
USER_VARIABLES-INITIAL_USER_VARIABLES+UV_FAT_CUR_FILE_SIZE CONSTANT FAT_CUR_FILE_SIZE
HIDE

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
    JSR PULL_DS
    SEC
    SBC (SP)
    BEQ @L_VC
    BMI @LESS_1
    BVS @L_VC
    BRA @TRUE
@LESS_1:
    BVC @L_VC
@TRUE:
    LDA #$FFFF
    BRA @END_1
@L_VC:
    LDA #0
@END_1:
    STA (SP)
END-CODE

CODE U< ( u u -- f )
    LDY #2
    LDA (SP),Y
    CMP (SP)
    BCC @LESS
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
    SWAP <
;

CODE 0< ( n -- f )
    LDA (SP)
    AND #$8000
    BEQ @SKIP
    LDA #$FFFF
@SKIP:
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

CODE << ( u u -- u )
    JSR PULL_DS
    TAY
    BEQ @END
    LDX SP
@LOOP:
    ASL 0,X
    DEY
    BNE @LOOP
@END:
END-CODE

CODE >> ( u u -- u )
    JSR PULL_DS
    TAY
    BEQ @END
    LDX SP
@LOOP:
    LSR 0,X
    DEY
    BNE @LOOP
@END:
END-CODE

: 2* ( n -- n )
    1 <<
;

CODE 2/ ( n -- n )
    CLC
    LDA (SP)
    BPL @SKIP
    SEC
@SKIP:
    ROR
    STA (SP)
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

: M* ( n n -- d ) 
    2DUP XOR >R
    ABS SWAP ABS U*
    R> D+-
;

: D+- ( d d -- d )
    0< IF
        DMINUS
    THEN
;

: MINUS ( n -- -n ) \ change sign
    NOT 1+
;

: +- ( n n -- n )
    0< IF
        MINUS
    THEN
;

: ABS ( n -- n )
    DUP +-
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
    DUP D+-
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

CODE 2SWAP ( a b c d -- c d a b )
    LDY #4
    LDA (SP),Y
    TAX
    LDA (SP)
    STA (SP),Y
    TXA
    STA (SP)
    LDY #6
    LDA (SP),Y
    TAX
    LDY #2
    LDA (SP),Y
    LDY #6
    STA (SP),Y
    TXA
    LDY #2
    STA (SP),Y
END-CODE

CODE OVER ( a b -- a b a )
    LDY #2
    LDA (SP),Y
    JSR PUSH_DS
END-CODE

CODE 2OVER ( a b c d -- a b c d a b )
    LDY #6
    LDA (SP),Y
    PHY
    JSR PUSH_DS
    PLY
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

CODE 2ROT ( d1 d2 d3 -- d2 d3 d1 )
D_1_LOW = FORTH_TMP_1
D_1_HIGH = FORTH_TMP_2

    LDA SP
    CLC
    ADC #8
    TAX
    TAY

    LDA 0,X
    STA D_1_HIGH
    INX
    INX
    LDA 0,X
    STA D_1_LOW
    INX

    TXA
    TYX
    DEX
    TAY
    
    LDA #7
    MVP 0, 0

    LDY #2
    LDA D_1_LOW
    STA (SP),Y
    LDA D_1_HIGH
    STA (SP)
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

CODE J ( -- n )
    LDA 7,S
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
    BEQ @END
    DEC A

    MVN 0, 0

@END:
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
        CMOVE   \ A primitive. Copy (addr) to (addr+1), (addr+1) to (addr+2),
                \ etc, until all n locations are filled with b.
    ELSE
        2DROP
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

    JSR PERIPHERALS_INIT

    ; Setup keyboard buffer
    STZ PC_2_BUFFER_START
    STZ PC_2_BUFFER_END

.ifdef FORTH_TRACE
    STZ DEBUG_INIT_STATUS
.endif

    LDA #%01111111 ; disapble interrupts just in case
    STA VIA_22_SECOND + W65C22::IER

    LDA VIA_22_SECOND + W65C22::IFR
    LDA VIA_22_SECOND + W65C22::RA

    LDA #<TICKS_IN_MS-2
    STA PVIA + W65C22::T1C_L
    LDA #>TICKS_IN_MS-2
    STA PVIA + W65C22::T1C_H
    
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

: CHAR ( -- c )
  BL IN @ SWAP ENCLOSE \ get offsets for next word
  IN +!                \ move IN after the word
  DROP + C@            \ load the first character
  LITERAL  \ it should be [COMPILE] LITERAL
;
IMMEDIATE

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
    1 DISP_LINE C!
    0 DISP_LINE 1+ C!
    0 PS2_STATUS !
    \ DISK BUFFER INIT
    ABORT
;

: ABORT
    SP!
    \ SETIO \ I've soldered the pull-down resistor wrong
    DECIMAL
    CR
    ." Marcus-Forth"
    FORTH
    DEFINITIONS
    QUIT    
;

: SETIO
    $8021 C@ \ read UART status register 
    $20 AND
    IF \ UART disconnected
        LABEL_FORTH_WORD_PS2_KEY (KEY) !
        LABEL_FORTH_WORD_DISPLAY_EMIT (EMIT) !
        DISP_CLR
    ELSE \ UART connected
        LABEL_FORTH_WORD_UART_KEY (KEY) !
        LABEL_FORTH_WORD_DISPLAY_EMIT (EMIT) !
        DISP_CLR
        ." UART connected"
        LABEL_FORTH_WORD_UART_EMIT (EMIT) !
    THEN
;
HIDE

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

: RECURSE ( -- addr )
    ?COMP     \ Error if not compiling  
    LATEST
    COUNT $1F AND + 2+
    ,
;
IMMEDIATE

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

: ANY_KEY
    BEGIN
        UART_KEY?
        DUP NOT IF
            DROP
            PS2_KEY?
        THEN
    UNTIL
;

: UART_KEY
    BEGIN
        UART_KEY?
    UNTIL
;

: PS2_KEY
    BEGIN
        PS2_KEY?
    UNTIL
;

CODE UART_KEY?
    A8_IND8
    LDX USER_IO_BUFFER_START
    CPX USER_IO_BUFFER_END
    BEQ @NOTHING
    LDA USER_IO_BUFFER,X
    TAY ; CHAR in Y
    INX
    TXA
    AND #USER_IO_BUFFER_MASK
    STA USER_IO_BUFFER_START
    A16_IND16
    TYA
    JSR PUSH_DS
    LDA #$FFFF
    JSR PUSH_DS
    JMP NEXT
@NOTHING:
    A16_IND16
    LDA #0
    JSR PUSH_DS
END-CODE

: PS2_FLAG ( flag -- ) \ apply flag
    PS2_STATUS @
    DUP 1 AND IF \ releasing
        SWAP 1 OR NOT AND \ also reset releasing flag
    ELSE \ pressing
        OR
    THEN
    PS2_STATUS !
    DROP 0 \ for PS2_KEY? return status
;
HIDE

: PS2_KEY?
    \ release key = 1
    \ shift flag = 2
    \ alt flag = 4
    \ ctrl flag = 8
    \ caps look flag = $10
    PS2_SCAN? IF
        DUP $E0 = IF
            DROP 0 \ ignore this
        ELSE
            DUP $F0 = IF
                PS2_STATUS @ 1 OR PS2_STATUS !
                DROP 0
            ELSE
                \ handle shift, etc
                DUP $12 = OVER $59 = OR IF \ check rigth or left shift
                    2 PS2_FLAG
                ELSE
                    DUP $11 = IF \ check alt
                        4 PS2_FLAG
                    ELSE
                        DUP $14 = IF \ check ctrl
                            8 PS2_FLAG
                        ELSE
                            PS2_STATUS @ 1 AND IF
                                PS2_STATUS @ 1 XOR PS2_STATUS !
                                DROP 0
                            ELSE
                                DUP $58 = IF \ Caps lock
                                    PS2_STATUS @ $10 XOR PS2_STATUS !
                                    DROP 0
                                ELSE
                                    PS2_STATUS @ 2 AND IF
                                        $80 OR
                                    THEN
                                    LABEL_KEYMAP + C@ \ get an ASCII from the table
                                    DUP 0= PS2_STATUS @ $10 AND 0= XOR IF \ if it's printable and CAPS-LOCK is enabled
                                        DUP $61 $7B WITHIN IF \ if it's lower case character
                                            $20 XOR
                                        THEN
                                    THEN
                                    -DUP
                                THEN
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN
    ELSE
        0
    THEN
;

CODE PS2_SCAN?
    A8_IND8
    LDX PC_2_BUFFER_START
    CPX PC_2_BUFFER_END
    BEQ @NOTHING_PS2
    LDA PC_2_BUFFER,X
    TAY ; CHAR in Y
    INX
    TXA
    AND #PC_2_BUFFER_MASK
    STA PC_2_BUFFER_START
    A16_IND16
    TYA
    JSR PUSH_DS
    LDA #$FFFF
    JSR PUSH_DS
    JMP NEXT
@NOTHING_PS2:
    A16_IND16
    LDA #0
    JSR PUSH_DS
END-CODE

: EMIT_BOTH
    DUP UART_EMIT DISPLAY_EMIT
;

: DISPLAY_EMIT
    \ 8 - backspace
    DUP 8 = IF
        DROP
        DISP_LINE 1+ DUP C@ 1- 0 MAX >R 
        R SWAP C!
        DISP_LINE C@ R> 2DUP
        DISP_CUR
        BL DISP_PRINT
        DISP_CUR
    ELSE
        \ A - new line
        DUP $A = IF
            DROP
            DISP_LINE C@
            1+ 1 AND
            DUP 0 DISP_CUR
            20 0 DO
                BL DISP_PRINT
            LOOP
            DUP 0 DISP_CUR
            DISP_LINE C!
            0 DISP_LINE 1+ C!
        ELSE
            DISP_PRINT
            DISP_LINE 1+ DUP C@ 1+ SWAP C!
        THEN
    THEN
;

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

CODE DISP_READ ( -- b )
    A8_IND8
DISP_READ_AGAIN:
    JSR READ_FROM_DISPLAY
    BMI DISP_READ_AGAIN
    A16_IND16
    JSR PUSH_DS
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

: DISP_GET_CUR ( -- n n ) \ line, column
    DISP_READ $40 /MOD
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

: M/ ( d n -- rem quot )
    OVER >R >R DABS R ABS U/ R> R XOR +- SWAP R> +- SWAP
;

: /MOD ( n n -- rem quot )
    >R S>D R> M/
;

: / ( n n -- quot )
    /MOD SWAP DROP
;

: */ ( n n n -- n )
    */MOD SWAP DROP
;

: */MOD ( n n n -- n n )
    >R M* R> M/
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

: U. ( u -- )
    0 D.
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

: :NONAME ( -- addr ) 
    ?EXEC
    HERE
    !CSP
    LABEL_DOCOL , ]
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

: 2@ ( addr -- d )
    DUP 2+ @ 
    SWAP @
;

: 2! ( d addr -- )
    >R R !
    R> 2+ !
;

CODE D2* ( d -- d )
    LDX SP
    INX
    INX
    ASL 0,X
    DEX
    DEX
    ROL 0,X
END-CODE

CODE D2/ ( d -- d )
    LDX SP
    CLC
    LDA (SP)
    BPL @SKIP
    SEC
@SKIP:
    ROR 0,X
    INX
    INX
    ROR 0,X
END-CODE

: DU< ( d d -- f )
    ROT 2DUP = IF
        2DROP U<
    ELSE
        SWAP U< 
        >R 2DROP R>
    THEN
;

: D< ( d d  -- f )
    ROT 2DUP = IF
        2DROP <
    ELSE
        SWAP < 
        >R 2DROP R>
    THEN
;

: D0< ( d -- f )
    >R DROP R> 0<
;

: D0= ( d -- f )
    0= SWAP 0= AND
;

: D= ( d d -- f )
    ROT = >R
    = R> AND
;

: DMAX ( d d -- d )
    2OVER 2OVER D<
    IF 
        2SWAP
    THEN
    2DROP
;

: DMIN ( d d -- d )
    2OVER 2OVER D< NOT
    IF 
        2SWAP
    THEN
    2DROP
;

: 2VARIABLE ( -- )
    VARIABLE 0 ,
; 

: 2CONSTANT ( d -- )
    CREATE
    LABEL_DO2CON HERE 2- ! \ Update CFA for CONSTANT runtime
    SWAP , ,
;

: DUMP_HL ( addr -- addr )
    >R R 8 + DUP R>
    DO
        I C@ 0 3 D.R
    LOOP
;

: DUMP ( addr n -- )
    BASE @ >R
    HEX
    CR
    0 DO
        DUP DUP 0 4 D.R 
        
        SPACE DUMP_HL
        SPACE DUMP_HL
        SPACE SPACE DROP 

        >R R 16 + DUP R> 
        DO
            I C@ 
            DUP $20 < OVER $7E > OR
            IF
                DROP $2E
            THEN
            EMIT
        LOOP

        CR
    16 +LOOP
    DROP
    R> BASE !
;

: UPTIME ( -- ) \ prints current uptime
    UPTIMEMS 1000 M/MOD \ stack: rem(ms) d_quot 
    60 M/MOD \ stack: rem(ms) rem(s) d_quot
    2DUP D0= IF
        2DROP
    ELSE
        60 M/MOD \ stack: rem(ms) rem(s) rem(m) d_quot
        2DUP D0= IF
            2DROP
        ELSE
            24 M/MOD \ stack: rem(ms) rem(s) rem(m) rem(h) d(days)
            2DUP D0= IF
                2DROP
            ELSE
                D. $64 EMIT
            THEN
            . $68 EMIT
        THEN
        . $6D EMIT
    THEN
    . $73 EMIT
    DROP
;

: S? ( -- )
    SP@ S0 @ < IF
        S0 @ SP@ - 2 DO
            SPACE S0 @ I - @ .
        2 +LOOP
    THEN
;

CODE WRITE_TO_SD ( addr n -- )
    JSR PULL_DS
    TAY
    JSR PULL_DS
    TAX
    A8
    LDA #%01010100 ; shift out with timer control
    STA PVIA + W65C22::ACR
    LDA #%10010000
    STA PVIA + W65C22::RB
@loop:
    LDA 0,X
    STA PVIA + W65C22::SR
    JSR WAIT_FOR_SD_SHIFT
    INX
    DEY
    BNE @loop
    A16
END-CODE
HIDE

CODE READ_FROM_SD ( addr n -- )
    JSR PULL_DS
    TAY
    JSR PULL_DS
    TAX
    A8
    LDA #%01000100 ; shift in with timer control
    STA PVIA + W65C22::ACR
    LDA #%10000000
    STA PVIA + W65C22::RB
    LDA PVIA + W65C22::SR ; for init clock in
    DEY
    BEQ @end
@loop:
    JSR WAIT_FOR_SD_SHIFT
    LDA PVIA + W65C22::SR
    STA 0,X
    INX
    DEY
    BNE @loop
@end:
    JSR WAIT_FOR_SD_SHIFT
    LDA #%01000000 ; off shifting
    STA PVIA + W65C22::ACR
    LDA PVIA + W65C22::SR
    STA 0,X
    A16
END-CODE
HIDE

: RETRY ( addr u -- funcResult )
    0 ROT ROT
    0 DO
        >R DROP R 
        EXECUTE
        DUP IF 
            R> 
            LEAVE
        THEN
        R>
    LOOP
    DROP
;
HIDE

: READ_SD_R1 ( -- b true / false )
    PAD 1-
    DUP 1 READ_FROM_SD
    DUP C@ $FF = IF
        DROP 0
    ELSE
        C@ -1
    THEN
;
HIDE

: WAIT_FOR_SD_R1 ( -- b true / false )
    LABEL_FORTH_WORD_READ_SD_R1 $f0 RETRY
;
HIDE

CODE DISABLE_SD ( -- )
    A8
    ; Disable SD
    ; LDA #%11100000
    ; STA VIA_22_FIRST + W65C22::RB
    LDA #%00010000
    STA PVIA + W65C22::RB
    LDA #%01000100 ; shift in with timer control
    STA PVIA + W65C22::ACR
    LDA PVIA + W65C22::SR
    JSR WAIT_FOR_SD_SHIFT
    STZ PVIA + W65C22::RB
    A16
END-CODE
HIDE

: SEND_SD_CMD_AND_CHECK_RESULT ( b addr -- f ) 
    6 WRITE_TO_SD WAIT_FOR_SD_R1 IF
        =
    ELSE
        0
    THEN
;
HIDE

: CHECK_BUSY ( -- f )
    PAD 1-
    DUP 1 READ_FROM_SD 
    C@ $FF =
;
HIDE

: WAIT_NOT_BUSY ( -- f )
    LABEL_FORTH_WORD_CHECK_BUSY $50 RETRY
;
HIDE

: SEND_SD_CMD_0 ( -- f )
    WAIT_NOT_BUSY IF
        1 LABEL_SD_CMD_0 SEND_SD_CMD_AND_CHECK_RESULT
    ELSE
        0
    THEN
    DISABLE_SD
;
HIDE

: SEND_SD_CMD_8 ( -- f )
    WAIT_NOT_BUSY IF
        1 LABEL_SD_CMD_8 SEND_SD_CMD_AND_CHECK_RESULT
        DUP IF
            PAD 4 READ_FROM_SD
        THEN
    ELSE
        0
    THEN
    DISABLE_SD
;
HIDE

: SEND_SD_CMD_41 ( -- f )
    WAIT_NOT_BUSY IF
        1 LABEL_SD_CMD_55 SEND_SD_CMD_AND_CHECK_RESULT IF 
            0 LABEL_SD_CMD_41 SEND_SD_CMD_AND_CHECK_RESULT
        ELSE
            0
        THEN
    ELSE
        0
    THEN
    DISABLE_SD
;
HIDE

: WRITE_2_BE ( d addr -- ) \ writing double as BIG-endian
    SWAP OVER WRITE_BE
    2+ WRITE_BE
;
HIDE

: WRITE_BE ( n addr -- ) \ writing BIG-endian
    OVER 8 >> OVER C!
    1+ C!
;
HIDE

: READ_2_LE ( addr -- d ) \ reading double from Little-endian
    DUP @
    SWAP 2+ @
;
HIDE

: READ_SD_BLOCK ( -- f ) \ command is in PAD followed by address
    WAIT_NOT_BUSY IF
        0 PAD SEND_SD_CMD_AND_CHECK_RESULT IF 
            WAIT_FOR_SD_R1 IF
                $FE = IF
                    PAD 6 + @ 512 READ_FROM_SD
                    PAD 2- 2 READ_FROM_SD
                    -1
                ELSE
                    0
                THEN
            ELSE
                0
            THEN
        ELSE
            0
        THEN
    ELSE
        0
    THEN
    DISABLE_SD
;
HIDE

: BLOCK ( d -- addr ) \ takes the number of block. Returns address of memory mapped block
    2DUP SD_BUF @ 4 - 2! \ writes the number
    $51 PAD C! PAD 1+ WRITE_2_BE 1 PAD 5 + C!
    SD_BUF @ PAD 6 + !

    LABEL_FORTH_WORD_READ_SD_BLOCK 50 RETRY LABEL_SD_ERROR_CMD_READ ?SD_ERROR

    SD_BUF @
;
HIDE

: ?SD_ERROR ( f n -- )
    SWAP NOT IF
        ." SD ERROR:"
        .
        SP! QUIT
    ELSE
        DROP
    THEN
;
HIDE

: TURN_ON_SD ( -- )
    25 $8018 C! \ timer for SD shift register

    11 0 DO
        DISABLE_SD
    LOOP

    LABEL_FORTH_WORD_SEND_SD_CMD_0 50 RETRY LABEL_SD_ERROR_CMD0 ?SD_ERROR
    LABEL_FORTH_WORD_SEND_SD_CMD_8 50 RETRY LABEL_SD_ERROR_CMD8 ?SD_ERROR
    LABEL_FORTH_WORD_SEND_SD_CMD_41 50 RETRY LABEL_SD_ERROR_CMD41 ?SD_ERROR

    0 $8018 C! \ timer for SD shift register
;
HIDE

: DU* ( d u -- d )
    \ dL dH u
    SWAP OVER
    \ dL u dH u
    U* DROP
    \ dL u dH*L
    >R U* R> +
;

: INIT_SD ( -- )
    TURN_ON_SD

    0 0 BLOCK \ Read zero sector
    \ check boot sector signature
    DUP $1FE + @ $AA55 = LABEL_SD_ERROR_WRONG_BOOT_SECTOR_SIGNATURE ?SD_ERROR
    $1BE + \ Partition offset
    \ check partition type
    DUP 4 + C@ $C = LABEL_SD_ERROR_WRONG_PARTITION_TYPE ?SD_ERROR
    \ read partition start
    8 + READ_2_LE

    2DUP BLOCK \ Read partition first sector
    \ check bytes per logical sector
    DUP $B + @ $200 = LABEL_SD_ERROR_WRONG_FAT_BYTES_PER_LOGICAL_SECTOR ?SD_ERROR
    \ check number of FATs
    DUP $10 + C@ 2 = LABEL_SD_ERROR_WRONG_FATS_NUMBER ?SD_ERROR
    \ check media descriptor
    DUP $15 + C@ $F8 = LABEL_SD_ERROR_WRONG_FAT_MEDIA_DESCRIPTOR ?SD_ERROR
    \ read sectors per cluster
    DUP $D + C@ DUP 0= NOT LABEL_SD_ERROR_FAT_ZERO_SECTORS_PER_CLUSTER ?SD_ERROR
        FAT_SEC_IN_CLUS !
    \ read root directory cluster
    DUP $2C + READ_2_LE FAT_ROOT_CLUS 2!
    \ Calc FAT #1 region sector
    \ Stack: doublePartitionStart, blockAddr
    DUP >R $E + @ 0 D+ FAT_SECTOR 2! R>
    \ Calc DATA region sector
    $24 + READ_2_LE D2* FAT_SECTOR 2@ D+ FAT_SEC_IN_CLUS @ 2* 0 D-
        FAT_DATA_SEC 2!
;

: OPEN/ ( -- addr )
    FAT_ROOT_CLUS 2@ FAT_CUR_CLUSTER 2!
    0 FAT_CUR_SEC_IN_CLUSTER !
    GET_SECTOR
;
HIDE

: NEXT_SECTOR ( -- addr true / false )
    FAT_CUR_SEC_IN_CLUSTER @ 1+ DUP FAT_SEC_IN_CLUS @ < IF
        FAT_CUR_SEC_IN_CLUSTER !
        GET_SECTOR -1
    ELSE
        DROP
        FAT_CUR_CLUSTER 2@ 128 M/MOD \ rem dQuot
        FAT_SECTOR 2@ D+ BLOCK
        + READ_2_LE \ next cluster
        2DUP $FFF DUP ROT AND = \ check high bytes
        SWAP $FFF8 DUP ROT AND = \ check low bytes
        AND IF
            \ end of a chain
            2DROP 0
        ELSE
            FAT_CUR_CLUSTER 2!
            0 FAT_CUR_SEC_IN_CLUSTER !
            GET_SECTOR -1
        THEN
    THEN
;
HIDE

: GET_SECTOR ( -- addr )
    FAT_CUR_CLUSTER 2@ FAT_SEC_IN_CLUS @ DU*
    FAT_DATA_SEC 2@ D+
    FAT_CUR_SEC_IN_CLUSTER @ 0 D+
    BLOCK
;
HIDE

: UPPER ( addr u -- ) \ convert string to upper case
    OVER + SWAP DO
        I C@ 
        DUP $61 $7B WITHIN IF
            $20 XOR I C!
        ELSE
            DROP
        THEN
    LOOP
;

: WITHIN ( n l h -- f ) \ l <= n < h
    OVER - >R - R> U<
;

: INDEX ( addr c -- n ) \ returns pos or -1
    >R COUNT R> SWAP -1 SWAP 0 DO
        \ addr c ind
        DROP
        OVER I + C@ OVER = IF
            I
            LEAVE
        THEN
        -1
    LOOP
    >R 2DROP R>
;

: TO_83 ( addr addr -- ) \ addr from and addr to
    DUP 11 BLANKS \ fill with spaces
    \ find point
    OVER $2E INDEX 
    \ sAddr addr pointInd
    ROT COUNT 2SWAP
    \ addrFrom fromLength addrTo pointInd

    \ copy ext
    DUP -1 = IF
        DROP SWAP
    ELSE
        2OVER 2OVER
        1+ >R 8 + \ addrFrom fromLength addrTo+8 | R: pointInd
        ROT R + SWAP ROT \ addrFrom+pointInd+1 addrTo+8 fromLength | R: pointInd
        R> - 3 MIN
        \ addrFrom+pointInd+1 addrTo+8 min(3, fromLength-pointInd-1)
        CMOVE

        ROT DROP \ it was 1- ROT DROP "test.txt"
    THEN
    \ addrFrom addrTo nameLength
    ROT DUP 2OVER
    \ addrTo nameLength addrFrom addrFrom addrTo nameLength
    8 MIN CMOVE
    DROP

    \ addrTo nameLength
    \ check if name > 8
    8 > IF
        DUP 6 + $7E OVER C!
        $31 SWAP 1+ C!
    THEN
    
    \ addrTo
    \ convert to upper after
    11 UPPER
;
HIDE

: CMP_ARRAY ( addr addr n -- f )
    -1 SWAP
    0 DO
        DROP
        OVER I + C@
        OVER I + C@ = NOT IF
            0 LEAVE
        THEN
        -1
    LOOP
    >R 2DROP R>
;

: OPEN ( <name> -- addr page_size )
    BL WORD 
    PAD 10 + HERE OVER TO_83

    0 0 \ stub
    OPEN/

    \ fineNameAddr 0 0 blockAddr
    BEGIN
        >R 2DROP 1 R> \ file is found
        DUP $200 + SWAP DO
            DROP

            I C@ 0= IF
                3
                LEAVE
            THEN

            DUP I 11 CMP_ARRAY IF
                DROP
                I $1A + @
                I $14 + @
                FAT_CUR_CLUSTER 2!
                0 FAT_CUR_SEC_IN_CLUSTER !
                I $1C + READ_2_LE FAT_CUR_FILE_SIZE 2!
                2
                LEAVE
            ELSE
                1
            THEN
        $20 +LOOP
        \ on stack:
            \ 1 proceed
            \ 2 found
            \ 3 end of folder
        DUP DUP 1 = IF
            NEXT_SECTOR NOT
        THEN
    UNTIL

    2 = NOT LABEL_MSG_FILE_NOT_FOUND ?ERROR

    GET_SECTOR
    GET_PAGE_SIZE
;

: NEXT_PAGE ( -- addr page_size )
    $200 0 FAT_CUR_FILE_SIZE 2@ D< IF
        FAT_CUR_FILE_SIZE 2@ $200 0 D- FAT_CUR_FILE_SIZE 2!
        NEXT_SECTOR DROP \ it should be the next sector
        GET_PAGE_SIZE
    ELSE
        0 0
    THEN
;

: GET_PAGE_SIZE ( -- page_size )
    FAT_CUR_FILE_SIZE 2@ $200 0 DMIN DROP
;
HIDE

: RUN ( <NAME> -- ) 
    CR
    OPEN
    LIB @
    BEGIN
        READ_EXEC
        NEXT_PAGE
        DUP
    WHILE
        ROT
    REPEAT
    2DROP \ after NEXT_PAGE
    \ exec the last line
    LINE_INPUT_GUARD
    LIB @ IN !
    INTERPRET
    QUIT
;

: READ_EXEC ( addr size buff -- buff ) 
    ROT ROT \ buff addr size
    OVER + SWAP DO
        I C@ \ buf char
        DUP $A = IF
            DROP
            LINE_INPUT_GUARD
            LIB @ IN !
            INTERPRET
            LIB @
        ELSE
            OVER C! 1+
        THEN
    LOOP
;
HIDE
