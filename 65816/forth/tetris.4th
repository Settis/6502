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

CREATE SCREEN_1_LINE 
CHAR T C, CHAR E C, CHAR T C, CHAR R C, CHAR I C, CHAR S C,
BL C, BL C, BL C, BL C, 
$FF C, 0 C, 1 C, 2 C, 3 C, $FF C,

CREATE SCREEN_2_LINE 
BL C, BL C, BL C, BL C, BL C, BL C, 
BL C, BL C, BL C, BL C, 
$FF C, 4 C, 5 C, 6 C, 7 C, $FF C,

CREATE BITMAP 8 8 * ALLOT
BITMAP 8 8 * ERASE

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

CREATE FLYING_BLOCK BLOCK_STRUCT_SIZE ALLOT
\ for plan the turns and moves
CREATE MOVED_BLOCK BLOCK_STRUCT_SIZE ALLOT

4 5 * CONSTANT FIELD_WIDTH
2 8 * CONSTANT FIELD_HEIGHT
FIELD_HEIGHT FIELD_WIDTH * 2* CONSTANT FIELD_SIZE

\ For static blocks on flor
CREATE FIELD_WITH_STATIC FIELD_SIZE ALLOT
FIELD_WITH_STATIC FIELD_SIZE ERASE
\ For compose static blocks and flying block
CREATE FIELD_BUFFER FIELD_SIZE ALLOT

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
    FLYING_BLOCK 4 +
    12 CMOVE
;

: PUT_FLYING_BLOCK 
    2 FLYING_BLOCK !
    1 FLYING_BLOCK 2+ !
    \ set block number
    1
    COPY_SHAPE
;

VARIABLE NEXT_MOVE_DOWN 0 ,
: THROTTLED_MOVE_DOWN
;

: XY_TO_OFFSET ( x y -- offset )
    20 * + 2*
;

: PREPARE_BUFFER 
    FIELD_WITH_STATIC FIELD_BUFFER FIELD_SIZE CMOVE

    -1
    FLYING_BLOCK @ FLYING_BLOCK 2+ @ XY_TO_OFFSET
    FIELD_BUFFER + !

    4 1 DO
        -1
        FLYING_BLOCK I 4 * + @
        FLYING_BLOCK @ +
        FLYING_BLOCK I 4 * + 2+ @
        FLYING_BLOCK 2+ @ +
        XY_TO_OFFSET
        FIELD_BUFFER + !
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
            FIELD_BUFFER I 5 * 2* + 320 J * +
            BITMAP I 8 * + 4 8 * J * +
            CHARACTER_BITMAP
        LOOP
    LOOP
;

: UPDATE_FIELD
    8 0 DO
        BITMAP 8 I * + I DISP_SET_CHAR
    LOOP
;

VARIABLE NEXT_UPDATE 0 ,
: THROTTLED_UPDATE_FIELD
    NEXT_UPDATE 2@
    UPTIMEMS
    D< IF 
        UPTIMEMS 500 0 D+
        NEXT_UPDATE 2!
        PREPARE_BUFFER
        UPDATE_BITMAP
        UPDATE_FIELD
    THEN
;

: REDRAW_FIELD
    PREPARE_BUFFER
    UPDATE_BITMAP
    UPDATE_FIELD
;

: UPDATE_POS ( x y r -- )
    IF
        4 1 DO
            FLYING_BLOCK I 4 * + @ \ Y[n+1] = X[n]
            MOVED_BLOCK I 4 * + 2+ !

            FLYING_BLOCK I 4 * + 2+ @ \ X[n+1] = -Y[n]
            -1 *
            MOVED_BLOCK I 4 * + !
        LOOP
    ELSE
        FLYING_BLOCK 4 + MOVED_BLOCK 4 + BLOCK_STRUCT_SIZE 4 - CMOVE
    THEN
    FLYING_BLOCK 2+ @ + MOVED_BLOCK 2+ !
    FLYING_BLOCK @ + MOVED_BLOCK !
;

: UPDATE_POS_REDRAW ( x y r -- )
    UPDATE_POS

    \ I need to check it, but I ignore

    MOVED_BLOCK FLYING_BLOCK BLOCK_STRUCT_SIZE CMOVE

    REDRAW_FIELD
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
    0 END !
    INIT_SCREEN
    PUT_FLYING_BLOCK
    REDRAW_FIELD
    BEGIN
        CHECK_KEY
        THROTTLED_MOVE_DOWN
        END @
    UNTIL
    DISP_CLR
    EXIT
;

MAIN
