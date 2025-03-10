VARIABLE CONTEXT
VARIABLE CURRENT

FORTH CONTEXT !
FORTH CURRENT !

VARIABLE TMP

: DROP ( n -- )
    TMP !
;

: DUP ( n -- n n )
    TMP !
    TMP @
    TMP @
;

: SWAP ( a b -- b a )
    TMP !
    >R
    TMP @
    R>
;

: OVER ( a b -- a b a )
    >R
    TMP !
    TMP @
    R>
    TMP @
;

: ROT ( a b c -- b c a )
    >R
    >R
    TMP !
    R>
    R>
    TMP @
;

: NOT ( n -- n )
    DUP
    NAND
;

: OR ( n n -- n )
    NOT
    >R
    NOT
    R>
    NAND
;

: AND ( n n -- n )
    NAND
    NOT
;

: XOR ( n n -- n )
    \ (NOT X OR NOT Y) AND (X OR Y)
    OVER NOT
    OVER NOT
    OR
    >R
    OR
    R>
    AND
;

: C@ ( a -- c )
    @
    FF AND
;

: C! ( c a -- )
    SWAP
    FF AND
    OVER @ FF00 AND
    OR
    SWAP 
    !
;

: IMMEDIATE ( -- )
    CONTEXT @ @ C@
    40 OR
    CONTEXT @ @ C!
;

: 1+ ( n -- n ) 1 + ;
: 2+ ( n -- n ) 2 + ;

: [
    0 STATE !
; IMMEDIATE

: ]
    C0 STATE !
;

: +! ( n addr -- ) \ increase value at addr by n
    SWAP OVER @
    + SWAP !
;

: HERE ( -- a )
    DP @
;

: ALLOT ( n -- )
    DP +! \ Increment dictionary pointer DP by n, reserving n bytes of
          \ dictionary memory for whatever purposes intended.
;

: C, ( b -- )
    HERE C! 
    1 ALLOT
;

: MINUS ( n -- -n) \ change sign
    NOT 1+
;

: - ( n n -- n ) \ subtract
    MINUS +
;

: 1- ( n -- n ) 1 - ;

VARIABLE (ERROR)

: ?ERROR ( f n -- )
    SWAP
    ( IF ) 0BRANCH [ HERE 0 , ] 
        (ERROR) @ EXECUTE
    ( ELSE ) BRANCH [ HERE 0 , SWAP ] [ HERE OVER - SWAP ! ]
        DROP
    ( ENDIF ) [ HERE OVER - SWAP ! ]
;

: ?COMP
    STATE @
    0=
    11 ?ERROR
;

: ?EXEC ( -- )
    STATE @
    12 ?ERROR
;

: ?PAIRS ( n n -- )
    -
    13 ?ERROR
;

: COMPILE ( -- )
    ?COMP     \ Error if not compiling
    R>        \ Top of return stack is pointing to the next word following
    DUP 2+ >R \ Increment this pointer by 2 to point to the second word following
              \ COMPILE , which will be the next word to be executed. The word
              \ immediately following COMPILE should be compiled, not executed.
    @ ,       \ Do the compilation at run-time.
;

\ creating BRK for debug
0 CONSTANT BRK HERE 2 - HERE 4 - !

: -FIND
    (WORD)
    HERE
    CONTEXT @ @
    (FIND)
;

: CFA ( pfa -- cfa ) 2 - ;

: [COMPILE] ( -- )
    -FIND       \ Accept next text string and search dictionary for a match.
    0= 0 ?ERROR \ No matching entry was found. Issue an error message.
    DROP        \ Discard the length byte of the found name.
    CFA ,       \ Convert the name field address to code field address and compile it into
                \ the dictionary.
; IMMEDIATE

: IF ( f -- ) \ at run-time
     ( -- addr n ) \ at compile time
    COMPILE 0BRANCH \ Compile the code field address of the run-time routine 0BRANCH into the
                    \ dictionary when IF is executed.
    HERE            \ Push dictionary address on stack to be used by ELSE or ENDIF to calculate
                    \ branching offset.
    0 ,             \ Compile a dummy zero here, later it is to be replaced by an offset value
                    \ used by 0BRANCH to compute the next word address.
    2               \ Error checking number.
; IMMEDIATE         \ IF in a colon definition must be executed, not compiled.

: ENDIF ( addr n -- ) \ at compile time
    ?COMP          \ Issue an error message if not compiling.
    2 ?PAIRS       \ ENDIF must be paired with IF or ELSE . If n is not 2, the structure was
                   \ disturbed or improperly nested. Issue an error message.
    HERE           \ Push the current dictionary address to stack.
    OVER -         \ HERE-addr is the forward branching offset.
    SWAP !         \ Store the offset in addr , thus completing the IF-ENDIF or IF-ELSE-ENDIF
                   \ construct.
; IMMEDIATE

: ELSE ( addr1 n1 -- addr2 n2 ) \ at compile time
    2 ?PAIRS        \ Error checking for proper nesting.
    COMPILE BRANCH  \ Compile BRANCH at run-time when ELSE is executed.
    HERE            \ Push HERE on stack as addr2 .
    0 ,             \ Dummy zero reserving a cell for branching to ENDIF .
    SWAP            \ Move addr1 to top of stack.
    2               \ I need to put 2 here for check inside ENDIF
    [COMPILE] ENDIF \ Call ENDIF to work on the offset for forward branching. ENDIF is an
                    \ immediate word. To compile it the word [COMPILE] must be used.
    2               \ Leave n2 on stack for error checking.
; IMMEDIATE

: BEGIN ( -- addr n ) \ at compile time
    ?COMP \ Issue an error message if not compiling.
    HERE  \ Push dictionary pointer on stack to be used to compute backward branching offset.
    1     \ Error checking number.
; IMMEDIATE

: BACK ( addr -- )
    HERE - , \ Compile addr-HERE, the backward branching offset.
;

: UNTIL ( addr n -- ) \ at compile time
    1 ?PAIRS        \ If n is not 1, issue an error message.
    COMPILE 0BRANCH \ Compile 0BRANCH at run-time.
    BACK            \ Compute backward branching offset and compile the offset.
; IMMEDIATE

: AGAIN ( addr n -- ) \ at compile time
    1 ?PAIRS       \ Error checking.
    COMPILE BRANCH \ Compile BRANCH and an offset to BEGIN .
    BACK
; IMMEDIATE

: WHILE ( addr1 n1 -- addr1 n1 addr2 n2 n3 ) \ at compile time
    [COMPILE] IF \ Call IF to compile 0BRANCH and the offset.
    4            \ Leave 4 as n2 to be checked by REPEAT.
; IMMEDIATE

: REPEAT ( addr1 n1 addr2 n2 n3 -- ) \ at compile time
    4 ?PAIRS        \ Error checking for WHILE
    >R >R           \ Get addr2 and n2 out of the way.
    [COMPILE] AGAIN \ Let AGAIN do the dirty work of compiling an unconditional branch back to BEGIN .
    R> R>           \  Restore addr2 and n2 .
    [COMPILE] ENDIF \  Use ENDIF to resolve the forward branching needed by WHILE .
; IMMEDIATE

: = ( n n -- f )
    - 0=
;

: 0< ( n -- f )
    8000 AND 0= NOT
;

: < ( n n -- f )
    - 0<
;

: > ( n n -- f )
    SWAP <
;

: CR 
    A EMIT
;

: SPACE
    20 EMIT
;

: R ( -- n )
    R> R> DUP >R SWAP >R
;

: ?STACK ( -- )
    SP@ S0 >        \ SP is out of upper bound, stack underflow
    1 ?ERROR        \ Error 1.
    SP@ HERE 80 + < \ SP is out of lower bound, stack overflow
    7 ?ERROR        \ Error 7.
;

VARIABLE _R

: (DO) ( n1 n2 -- )
    R> _R !  \ return address
    SWAP
    >R >R
    _R @ >R \ put back return address
;

: DO ( n1 n2 -- ) \ at runtime
     ( -- addr n ) \ at compile time
    COMPILE (DO) \ Compile the run-time routine address of (DO) into dictionary.
    HERE         \ Address addr for backward branching from LOOP or +LOOP.
    3            \ Number for error checking.
; IMMEDIATE

: I ( -- I )
    R> _R !  \ return address
    R>
    DUP
    >R
    _R @ >R \ put back return address
;

: LEAVE ( -- )
    R> _R !  \ return address
    R> DROP
    R> DUP
    >R >R
    _R @ >R \ put back return address
;

: (+LOOP)
    R> _R !  \ return address

    R> + R>
    DUP >R
    SWAP DUP >R

    > NOT DUP
    IF
        R> DROP
        R> DROP
    ENDIF
    _R @ >R \ put back return address
;

: (LOOP)
    R> _R !  \ return address

    R> R>
    DUP >R
    SWAP 1+
    DUP >R

    > NOT DUP
    IF
        R> DROP
        R> DROP
    ENDIF
    _R @ >R \ put back return address
;

: LOOP ( addr n -- ) \ at runtime
    3 ?PAIRS \ Check the number left by DO . If it is not 3, issue an error message.
             \ The loop is not properly nested.
    COMPILE (LOOP)
    COMPILE 0BRANCH
    BACK
; IMMEDIATE

: +LOOP 
    3 ?PAIRS \ Check the number left by DO . If it is not 3, issue an error message.
             \ The loop is not properly nested.
    COMPILE (+LOOP)
    COMPILE 0BRANCH
    BACK 
; IMMEDIATE

: . ( n -- )
    4 0 DO
        DUP
        0F AND
        SWAP
        2/ 2/ 2/ 2/
    LOOP
    DROP
    4 0 DO
        DUP
        A < IF
            30
        ELSE
            37
        ENDIF
        + EMIT
    LOOP
    SPACE
;

: COUNT ( addr1 -- addr2 n )
    DUP 1+  \ addr2=addr1+1
    SWAP    \ Swap addr1 over addr2 and
    C@      \ fetch the byte count to the stack.
;

: -DUP DUP IF DUP ENDIF ;

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
    ENDIF
;

: ;S \ for return of the function
    R> DROP
;

: ENCLOSE ( addr c -- addr n1 n2 n3 )
    >R          \ addr on the stack
    0 OVER      \ addr n1 addr
    BEGIN
        DUP C@   \ addr n1 addr content
        R =
    WHILE
        1+ SWAP
        1+ SWAP
    REPEAT

    \ Special case for NUL
    DUP C@ 0=
    IF
        DROP
        DUP 1+
        DUP
        R> DROP
        ;S
    ENDIF

    >R DUP R>   \ addr n1 n2 addr+n1
    BEGIN
        DUP C@ DUP
        0= SWAP
        R =
        OR NOT
    WHILE \ it's not a separator and not a 0
        1+ SWAP
        1+ SWAP
    REPEAT
    >R DUP R>   \ addr n1 n2 n3 addr+n2
    BEGIN
        DUP C@
        R =
    WHILE
        1+ SWAP
        1+ SWAP
    REPEAT

    R> DROP DROP
;

: CMOVE ( from to u -- )
    0 DO
        OVER C@
        OVER C!
        1+ SWAP
        1+ SWAP
    LOOP
    DROP DROP
;

: FILL ( addr n b -- )
    SWAP >R \ store n on the return stack
    OVER C! \ store b in addr
    DUP 1+  \ addr+1, to be filled with b
    R> 1-   \ n-1, number of butes to be filled by CMOVE
    CMOVE   \ A primitive. Copy (addr) to (addr+1), (addr+1) to (addr+2),
            \ etc, until all n locations are filled with b.
;

: ERASE 0 FILL ;
20 CONSTANT BL
: BLANKS BL FILL ; 

: WORD ( c -- )
    \ BLK check is disabled
    TIB @           \ read from terminal input buffer
    IN @            \ IN contains the character offset into the current input text buffer.
    +               \ Add offset to the starting address of buffer, pointing to the next
                    \ character to be read in.
    SWAP            \ Get delimiter c over the string address.
    ENCLOSE         \ A primitive word to scan the text. From the byte address and the
                    \ delimiter c , it determines the byte offset to the first non-delimiter
                    \ character, the offset to the first delimiter after the text string,
                    \ and the offset to the next character after the delimiter. If the
                    \ string is delimited by a NUL , the last offset is equal to the previous
                    \ offset.
                    \ ( addr c --- addr n1 n2 n3 )
    HERE 22 BLANKS  \ Write 34 blanks to the top of dictionary.
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

: ." ( -- )
    22                  \ hex ASCII value of the delimiter ".
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
    ENDIF
; IMMEDIATE

: X ( -- )
    \ cut out BLK processing
    R> DROP
; IMMEDIATE
\ Change X to NUL
\ Upper bit is set
80 CONTEXT @ @ 1+ C!

VARIABLE DPL

: NUMBER ( addr -- d ) \ simplified version
    FFFF DPL !      \ Set DPL to -1
    0 0 ROT         \ Push two zero's on stack as the initial value of d .
    COUNT OVER +    \ stack: addrFrom addrTo
    SWAP DO
        2* 2* 2* 2* \ shift the current number
        I C@
        30 -
        DUP 0<      \ if it's lower than ASCII 0
        0 ?ERROR 
        DUP 9 >     \ is it from A to F?
        IF 
            7 -
            DUP A < \ it's between ASCII 9 and A
            0 ?ERROR
            DUP F > \ it's bigger than ASCII F
            0 ?ERROR
        ENDIF
        +           \ We can add it
    LOOP
    SWAP
;

: (LIT)
    R           \ Copy return pointer
    @           \ Read the literal
    R> 2+ >R    \ Update the return pinter
;

: DLITERAL
    ." DLITERAL is not impemented" CR
    (ERROR) @ EXECUTE
; IMMEDIATE

: LITERAL 
    STATE @
    IF
        COMPILE (LIT) ,
    ENDIF
; IMMEDIATE

: LATEST ( -- addr )
    CURRENT @ @
;

: -FIND ( -- pfa b tf , or ff )
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
    ENDIF
;

: INTERPRET ( -- )
    BEGIN                   \ Start the interpretation loop
        -FIND               \ Move the next word from input stream to HERE and search the
                            \ CONTEXT and then the CURRENT vocabularies for amatching entry.
                            \ If found, the dictionary entry's parameter field address, its
                            \ length byte, and a boolean true flag are left on stack.
                            \ Otherwise, only a false flag is left.
        IF                  \ A matching entry is found. Do the following:
            STATE @ <       \ If the length byte < state , the word is to be compiled.
            IF CFA ,        \ Compile the code field address of this word to the dictionary
            ELSE            \ Length byte > state, this is an immediate word,
                CFA         \ then put the code field address on the data stack and
                EXECUTE     \ call the address interpreter to execute this word.
            ENDIF
            ?STACK          \ Check the data stack. If overflow or underflow, print error
                            \ message and jump to QUIT .
        ELSE                \ No matching entry. Try to convert the text to a number.
            HERE            \ Start of the text string on top of the dictionary.
            NUMBER          \ Convert the string at HERE to a signed double number, using
                            \ current base. If a decimal point is encountered in the text, its
                            \ position is stored in DPL. If numeric conversion is not
                            \ possible, an error message will be given and QUIT
            DPL @ 1+        \ Is there a decimal point? If there is, DPL + 1 should be greater
                            \ than zero, i. e., true.
            IF              \ Decimal point was detected
                [COMPILE]   \ Compile the next immediate word.
                DLITERAL    \ If compiling, compile the double number on stack into a literal,
                            \ which will be pushed on stack during execution. If executing, the
                            \ number remains on stack.
            ELSE            \ No decimal point, the number should be a single 16 bit number.
                DROP        \ Discard the high order part of the double number.
                [COMPILE]
                LITERAL     \ If compiling, compile the number on stack as a literal.
                            \ The number is left on stack if executing.
            ENDIF
            ?STACK          \ Check the data stack overflow or underflow.
        ENDIF               \ End of the IF clause after -FIND .
    AGAIN                   \ Repeat interpretation of the next text string in the input
                            \ stream.
;

: EXPECT ( addr n -- )
    OVER +                  \ addr+n, the end of text.
    OVER                    \ Start of text.
    DO                      \ Repeat the following for n times
        KEY                 \ Get one character from terminal
        DUP                 \ Make a copy of the character.
        8 = 
        IF                  \ Check is input is a backspace
            OVER            \ Copy addr
            I =             \ See if the current character is the first character of text
            DUP             \ Copy it, to be used as a flag.
            R> 2 - +        \ Get the loop index. Decrement it by 1 if it is the starting character, or
                            \ decrement it by 2 if it is in the middle of the text.
            >R              \ Put the corrected loop index back on return stack. If the backspace is
            +               \ the first character, ring the bell. Otherwise, output backspace and
                            \ decrement character count.
        ELSE                \ Not a backspace
            DUP A =         \ Is it a carriage-return?
            IF
                LEAVE       \ Prepare to exit the loop. CR is end of text line.
                DROP BL     \ Drop CR from the stack and replace with a blank.
                \ 0           \ Put a null on stack.
            ELSE            \ Input is a regular ASCII character.
                DUP         \ Make a copy.
                I C!        \ Store the ASCII character into the input buffer area.
                0 I 1+ !    \ Guard the text with an ASCII NUL.
            ENDIF
        ENDIF
        \ EMIT 
        DROP  \ Well, I should send echo back, but it works bad when I connect it to my laptop
    LOOP DROP
;

: QUERY ( -- )
    0 TIB @ !
    TIB @       \ TIB contains the starting address of the input terminal buffer.
    50 EXPECT   \ Get 80 characters.
    0 IN !      \ Set the input character counter IN to 0. Text parsing shall begin at TIB.
;

: QUIT ( -- )
    \ 0 BLK ! BLK contains the current disk block number under interpretation.
            \ 0 in BLK indicates the text should come from the terminal.
    [COMPILE]       \ Compile the next IMMEDIATE word which normally is executed even in
                    \ compilation state.
    [               \ Set STATE to 0, thus enter the interpretive state.
    BEGIN           \ Starting point of the 'Forth loop'.
        RP!         \ A primitive. Set return stack pointer to its origin R0 .
        CR
        QUERY       \ Input 80 characters of text from the terminal. The text is
                    \ positioned at the address contained in TIB with IN set to 0.
        INTERPRET   \ Call the text interpreter to process the input text.
        STATE @ 0=  \ Examine STATE .
        IF          \ STATE is 0, in the interpretive state
            ." ok." \ Type ok on terminal to indicate the line of text was successfully
                    \ interpreted.
        ENDIF
    AGAIN           \ Loop back. Close the Forth loop .
;

: ABORT ( -- )
    SP! \ A primitive. Set the stack pointer SP to its origin S0 .
    \ DECIMAL Store 10 in BASE , establishing decimal number conversions.
    CR
    ." my-Forth" \ Print sign-on message on terminal.
    \ FORTH Select FORTH trunk vocabulary.
    \ DEFINITIONS Set CURRENT to CONTEXT so that new definitions will be linked to
                \ the FORTH vocabulary.
    QUIT        \ Jump to the Forth loop where the text interpreter resides.
;

VARIABLE WARNING
0 WARNING !

: ERR ( n -- )
    WARNING @ 0<    \ See if WARNING is -1,
    IF ABORT        \ if so, abort and restart.
    ENDIF
    HERE COUNT TYPE \ Print name of the offending word on top of the dictionary.
    ." ? MSG#" .
    SP!             \ Clean the data stack.
    IN @
    \ BLK @ \ Fetch IN and BLK on stack for the operator to look at if he
            \ wishes.
    QUIT    \ Restart the Forth loop.
;

\ put ERR link to (ERROR)
CONTEXT @ @ DUP C@ 7F AND 3 + + (ERROR) !

: COLD ( -- )
    TIB!
    ABORT
;

VARIABLE CSP

: !CSP ( -- )
    SP@ CSP !
;

: ?CSP ( -- )
    SP@         \ Current stack pointer
    CSP @       \ Saved stack pointer
    -           \ If not equal,
    14 ?ERROR   \ issue errro message 14.
;

VARIABLE WIDTH
1F WIDTH !

: MIN ( n n -- n )
    OVER OVER >
    IF
        SWAP
    ENDIF
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
    DUP A0 TOGGLE       \ byte of the name field. Make a 'smudged' head so that dictionary
                        \ search will not find this name .
    HERE 1- 80 TOGGLE   \ Toggle the eighth bit in the last character of the name as a
                        \ delimiter to the name field.
    LATEST ,            \ Compile the name field address of the last word in the link field,
                        \ extending the linking chain.
    CURRENT @ !         \ Update contents of LATEST in the current vocabulary.
    HERE 2+ ,           \ Compile the parameter field address into code field, for the
                        \ convenience of a new code definition. For other types of
                        \ definitions, proper code routine address will be compiled here.
;

: SMUDGE ( -- )
    CURRENT @ @ 20 TOGGLE
;

: ; ( -- )
    [ SMUDGE ]  \ The word should be disabled here manually. Because bootstrap Ford not doing this on its own.
    ?CSP        \ Check the stack pointer with that saved in CSP . If they differ,
                \ issue an error message.
    COMPILE ;S  \ Compile the code field address of the word ;S into the dictionary,
                \ at run-time. ;S will return execution to the calling definition.
    SMUDGE      \ Toggle the smudge bit back to zero. Restore the length byte in
                \ the name field, thus completing the compilation of a new word.
    [COMPILE] [ \ Set STATE to zero and return to the executing state.
; IMMEDIATE

\ SMUDGE the ;
CURRENT @ @

\ !CSP
: : ( -- )
    ?EXEC               \ Issue an error message if not executing.
    !CSP                \ Save the stack pointer in CSP to be checked by ';' or ;CODE .
    CURRENT @ CONTEXT ! \ Make CONTEXT vocabulary the same as the CURRENT vocabulary.
    CREATE              \ Now create the header and establish linkage with the current
                        \ vocabulary.
    (DOCOL) HERE 2 - !  \ Set docol executor
    ]                   \ Change STATE to non-zero. Enter compiling state and compile the
                        \ words following till ';' or ;CODE .
;

20 TOGGLE

: CONSTANT ( n -- )
    CREATE
    (DOCONST) HERE 2 - ! \ Update CFA for CONSTANT runtime
    ,
    SMUDGE
;

: VARIABLE ( -- )
    CREATE
    (DOVAR) HERE 2 - ! \ Update CFA for VARIABLE runtime
    0 ,
    SMUDGE
;

: RUN 
    0 TIB !
    BENCHMARK IN !
    INTERPRET
    COLD
;

COLD
