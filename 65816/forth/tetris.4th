: EXIT
    4 EMIT
;


VARIABLE SEED

: RND_INIT ( -- )
    BEGIN
        UPTIMEMS +
        DUP SEED !
    UNTIL
;

: RND ( -- n )
    SEED @
    DUP 7 >> XOR
    DUP 9 << XOR
    DUP 13 >> XOR
    DUP SEED !
;

: RND_I  ( n -- n )
    RND SWAP /MOD DROP ABS
;

( elemSize number -- ) \ compiling
( n -- addr ) \ executing
: ARRAY <BUILDS OVER , * ALLOT
    DOES> DUP @ ROT * + 2+ ;

( size x y --  ) \ compiling 
( x y -- addr ) \ executing
: 2DARRAY 
    <BUILDS ROT DUP , * OVER , * ALLOT \ save: size maxX
    DOES> \ stack: x y addr
        >R R 2+ @ \ stack: x y maxX | r: addr
        * + \ stack: cellOffset | r: addr
        R @ * R> + 4 +
;

CREATE SCREEN_1_LINE 
CHAR T C, CHAR E C, CHAR T C, CHAR R C, CHAR I C, CHAR S C,
BL C, BL C, BL C, BL C, 
$FF C, 0 C, 1 C, 2 C, 3 C, $FF C,

CREATE SCREEN_2_LINE 
CHAR S C, CHAR c C, CHAR o C, CHAR r C, CHAR e C, CHAR : C,
CHAR X DUP DUP DUP C, C, C, C,
$FF C, 4 C, 5 C, 6 C, 7 C, $FF C,

1 8 8 2DARRAY BITMAP
0 0 BITMAP 8 8 * ERASE

: INIT_SCREEN
    DISP_CLR
    -1 0 0 DISP_CTL
    16 0 DO
        SCREEN_1_LINE I + C@ DISP_PRINT
    LOOP
    1 0 DISP_CUR
    16 0 DO
        SCREEN_2_LINE I + C@ DISP_PRINT
    LOOP
;

VARIABLE END

: WAIT ( n -- )
    0 UPTIMEMS D+
    BEGIN
        2DUP
        UPTIMEMS
        D<
    UNTIL
    2DROP
;

\ X,Y coord of block center + relative X,Y for other bricks
2 4 * 2* CONSTANT BLOCK_STRUCT_SIZE
: _X ;
: _Y 2+ ;

4 4 ARRAY FLYING_BLOCK
\ for plan the turns and moves
4 4 ARRAY MOVED_BLOCK

4 5 * CONSTANT FIELD_WIDTH
2 8 * CONSTANT FIELD_HEIGHT
FIELD_HEIGHT FIELD_WIDTH * 2* CONSTANT FIELD_SIZE

\ For static blocks on flor
2 FIELD_WIDTH FIELD_HEIGHT 2DARRAY FIELD_WITH_STATIC
0 0 FIELD_WITH_STATIC FIELD_SIZE ERASE
\ For compose static blocks and flying block
2 FIELD_WIDTH FIELD_HEIGHT 2DARRAY FIELD_BUFFER

VARIABLE SCORE

: UPDATE_SCORE ( n -- ) \ amount to add to score
    SCORE +!
    1 6 DISP_CUR
    SCORE @
        0 4 D.R
;

: END_GAME ( -- )
    0 7 DISP_CUR ." END"
    0 10 DISP_CUR $23 EMIT
    0 15 DISP_CUR $23 EMIT
    1 10 DISP_CUR $23 EMIT
    1 15 DISP_CUR $23 EMIT
;

7 CONSTANT BLOCKS_COUNT
CREATE BLOCKS_SHAPES \ relative X,Y for bricks
\ J
-1 , -1 , -1 , 0 , 1 , 0 ,
\ I
-1 , 0 , 1 , 0 , 2 , 0 ,
\ o
1 , 0 , 1 , 1 , 0 , 1 ,
\ L
-1 , 0 , 1 , 0 , 1 , -1 ,
\ z
-1 , -1 , 0 , -1 , 1 , 0 ,
\ T
-1 , 0 , 0 , -1 , 1 , 0 ,
\ s
-1 , 0 , 0 , -1 , 1 , -1 ,

: COPY_SHAPE ( n -- ) 
    \ find block_shape offset
    12 *
    \ bricks addr
    BLOCKS_SHAPES + 
    \ flying block bricks addr
    1 FLYING_BLOCK
    12 CMOVE
;

: PUT_FLYING_BLOCK 
    10 0 FLYING_BLOCK _X !
    1 0 FLYING_BLOCK _Y !
    \ set block number
    BLOCKS_COUNT RND_I
    COPY_SHAPE
;

VARIABLE NEXT_MOVE_DOWN 0 ,
: SCHEDULE_MOVE_DOWN
    1.000 UPTIMEMS D+
    NEXT_MOVE_DOWN 2!
;

: GET_FLYING_BLOCK_XY ( n -- x y )
    DUP 0= IF
        DROP
        0 FLYING_BLOCK _X @
        0 FLYING_BLOCK _Y @
    ELSE
        DUP FLYING_BLOCK _X @
        0 FLYING_BLOCK _X @ +
        SWAP FLYING_BLOCK _Y @
        0 FLYING_BLOCK _Y @ +
    THEN
;

: PREPARE_BUFFER 
    0 0 FIELD_WITH_STATIC 
        0 0 FIELD_BUFFER 
        FIELD_SIZE 
        CMOVE

    4 0 DO
        -1
            I GET_FLYING_BLOCK_XY
            FIELD_BUFFER !
    LOOP
;

: FORM_BITMAP_BYTE ( addr - b )
    0 \ accumulator
    5 0 DO
        1 <<
        OVER I 2* + @
        ABS +
    LOOP
    SWAP DROP
;

: CHARACTER_BITMAP ( addrFrom addrTo -- )
    8 0 DO
        OVER I 40 * +
        FORM_BITMAP_BYTE
        OVER I + C!
    LOOP
    2DROP
;

: UPDATE_BITMAP
    2 0 DO \ lines
        4 0 DO \ iterate for characters row
            I 5 * 8 J * FIELD_BUFFER
            0 I J 4 * + BITMAP
            CHARACTER_BITMAP
        LOOP
    LOOP
;

: UPDATE_FIELD
    8 0 DO
        0 I BITMAP I DISP_SET_CHAR
    LOOP
;

: REDRAW_FIELD
    PREPARE_BUFFER
    UPDATE_BITMAP
    UPDATE_FIELD
;

: UPDATE_POS ( x y r -- )
    IF
        4 1 DO
            I FLYING_BLOCK _X @ \ Y[n+1] = X[n]
            I MOVED_BLOCK _Y !

            I FLYING_BLOCK _Y @ \ X[n+1] = -Y[n]
            -1 *
            I MOVED_BLOCK _X !
        LOOP
    ELSE
        1 FLYING_BLOCK 1 MOVED_BLOCK BLOCK_STRUCT_SIZE 4 - CMOVE
    THEN
    0 FLYING_BLOCK _Y @ + 0 MOVED_BLOCK _Y !
    0 FLYING_BLOCK _X @ + 0 MOVED_BLOCK _X !
;

0 CONSTANT OK
1 CONSTANT OUT
2 CONSTANT STOP

: CHECK_POS ( x y -- status )
    OVER 0< IF
        OUT
    ELSE
        OK
    THEN
    >R
    
    OVER FIELD_WIDTH < IF
        OK
    ELSE
        OUT
    THEN
    R> MAX >R

    DUP 0< IF
        OUT
    ELSE
        OK
    THEN
    R> MAX >R

    DUP FIELD_HEIGHT < IF
        OK
    ELSE
        STOP
    THEN
    R> MAX

    \ checked X Y boundaries
    DUP 0= IF
        >R
        FIELD_WITH_STATIC @ IF 
            STOP
        ELSE
            OK
        THEN
        R> MAX
    ELSE
        \ delete x y
        >R 2DROP R>
    THEN
;

: GET_MOVED_BLOCK_XY ( n -- x y )
    DUP 0= IF
        DROP
        0 MOVED_BLOCK _X @
        0 MOVED_BLOCK _Y @
    ELSE
        DUP MOVED_BLOCK _X @
        0 MOVED_BLOCK _X @ +
        SWAP MOVED_BLOCK _Y @
        0 MOVED_BLOCK _Y @ +
    THEN
;

: UPDATE_POS_CHECK ( x y r -- status ) 
    UPDATE_POS

    4 0 DO
        I GET_MOVED_BLOCK_XY
            CHECK_POS
    LOOP

    MAX MAX MAX
;

\ first byte - size, then byte per line number
VARIABLE COMPLETED_LINES_SIZE
1 6 ARRAY COMPLETED_LINES

: SET_COMPLETED_LINES ( -- )
    0 COMPLETED_LINES_SIZE !
    FIELD_HEIGHT 0 DO
        -1
        FIELD_WIDTH 0 DO
            I J FIELD_WITH_STATIC @ 0= IF
                DROP 0
                LEAVE
            THEN
        LOOP
        IF  
            I COMPLETED_LINES_SIZE @
                COMPLETED_LINES C!
            1 COMPLETED_LINES_SIZE +!
        THEN
    LOOP
;

: CLEAN_LINES ( -- )
    COMPLETED_LINES_SIZE @ 0 DO
        I COMPLETED_LINES C@
        0 SWAP FIELD_WITH_STATIC FIELD_WIDTH 2* ERASE
    LOOP
;

: MOVE_LINE ( to from -- )
    0 SWAP FIELD_WITH_STATIC
        SWAP 0 SWAP FIELD_WITH_STATIC
        FIELD_WIDTH 2* CMOVE
;

: COMPRESS_LINES ( -- )
    COMPLETED_LINES_SIZE @ 0 DO
        I COMPLETED_LINES C@ \ line to fill
        BEGIN
            DUP \ to preserve fill line
            DUP 1- \ calc from
            MOVE_LINE
            DUP 0= NOT
        WHILE
            1-
        REPEAT
        DROP
    LOOP

    0 0 FIELD_WITH_STATIC FIELD_WIDTH 2* COMPLETED_LINES_SIZE @ * ERASE
;

: REMOVE_COMPLETED_LINES ( -- )
    SET_COMPLETED_LINES
    COMPLETED_LINES_SIZE @ 0= NOT IF
        CLEAN_LINES
        REDRAW_FIELD
        500 WAIT
        COMPRESS_LINES
        REDRAW_FIELD
        COMPLETED_LINES_SIZE @ 2*
            FIELD_WIDTH *
            UPDATE_SCORE
    THEN
;

: UPDATE_POS_REDRAW ( x y r -- )
    UPDATE_POS_CHECK
    DUP 0= IF
        0 MOVED_BLOCK 0 FLYING_BLOCK BLOCK_STRUCT_SIZE CMOVE
        REDRAW_FIELD
    ELSE
        DUP STOP = IF
            4 0 DO        
                -1
                    I GET_FLYING_BLOCK_XY
                    FIELD_WITH_STATIC !
            LOOP
            PUT_FLYING_BLOCK
            0 0 0 UPDATE_POS_CHECK
            0= IF
                1 UPDATE_SCORE
                REDRAW_FIELD
                REMOVE_COMPLETED_LINES
                SCHEDULE_MOVE_DOWN
            ELSE
                -1 END !
            THEN
        THEN
    THEN
    DROP
;

: THROTTLED_MOVE_DOWN
    NEXT_MOVE_DOWN 2@ UPTIMEMS D< IF
        SCHEDULE_MOVE_DOWN
        0 1 0 UPDATE_POS_REDRAW
    THEN
;

: CHECK_KEY
    PS2_KEY?
    IF
        DUP $80 = IF
            -1 END !
        ELSE
            DUP CHAR S = IF
                0 1 0 UPDATE_POS_REDRAW
            ELSE
                DUP CHAR A = IF
                    -1 0 0 UPDATE_POS_REDRAW
                ELSE
                    DUP CHAR D = IF
                        1 0 0 UPDATE_POS_REDRAW
                    ELSE
                        DUP CHAR W = IF
                            0 -1 0 UPDATE_POS_REDRAW
                        ELSE
                            DUP BL = IF
                                0 0 -1 UPDATE_POS_REDRAW
                            THEN
                        THEN
                    THEN
                THEN
            THEN
        THEN

        DUP $31 = IF
            0 COPY_SHAPE
            REDRAW_FIELD
        THEN
        DUP $32 = IF
            1 COPY_SHAPE
            REDRAW_FIELD
        THEN
        DUP $33 = IF
            2 COPY_SHAPE
            REDRAW_FIELD
        THEN
        DUP $34 = IF
            3 COPY_SHAPE
            REDRAW_FIELD
        THEN
        DUP $35 = IF
            4 COPY_SHAPE
            REDRAW_FIELD
        THEN
        DUP $36 = IF
            5 COPY_SHAPE
            REDRAW_FIELD
        THEN
        DUP $37 = IF
            6 COPY_SHAPE
            REDRAW_FIELD
        THEN

        DROP
    THEN
;

: MAIN
    DECIMAL
    BEGIN

    0 0 FIELD_WITH_STATIC FIELD_SIZE ERASE
    0 END !
    0 SCORE !
    ' DISPLAY_EMIT (EMIT) !
    INIT_SCREEN

    PS2_KEY DROP \ wait for user input

    0 UPDATE_SCORE

    RND_INIT
    PUT_FLYING_BLOCK
    REDRAW_FIELD
    BEGIN
        CHECK_KEY
        THROTTLED_MOVE_DOWN
        END @
    UNTIL
    END_GAME

    PS2_KEY DROP \ wait for user input

    DISP_CLR

    AGAIN
;

MAIN
