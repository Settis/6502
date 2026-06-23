$5F00 CONSTANT SEED
$5F02 CONSTANT GOAL
$5F06 CONSTANT INPUT
$5F0A CONSTANT BULLS
$5F0C CONSTANT COWS
$5F0E CONSTANT WIN
$5F10 CONSTANT GAMES

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

: BC_INIT
    RND_INIT
    0 WIN !
    0 GAMES !
;

: BC_GEN_GOAL
    GOAL DUP 4 + SWAP DO
        0 I C!
    LOOP
    GOAL DUP 4 + SWAP DO
        0 BEGIN
            DROP
            RND 10 /MOD DROP ABS $30 +
            0
            GOAL DUP 4 + SWAP DO
                OVER I C@ = OR
            LOOP
            NOT
        UNTIL
        I C!
    LOOP
;

: BC_INPUT
    INPUT DUP 4 + SWAP DO
            KEY DUP $29 > OVER $3A < AND IF
                DUP EMIT I C! 1
            ELSE
                DROP 0
            THEN
    +LOOP
;

: BC_EVAL
    0 BULLS !
    0 COWS !

    4 0 DO
        INPUT I + C@
        GOAL I + C@ = IF
            1 BULLS +!
        ELSE
            4 0 DO
                I J = NOT IF
                    INPUT J + C@
                    GOAL I + C@ = IF
                        1 COWS +!
                    THEN
                THEN
            LOOP
        THEN
    LOOP
;

: BC
    BC_GEN_GOAL
    1 GAMES +!
    CR
    9 1 DO
        I . $3A EMIT SPACE
        BC_INPUT
        BC_EVAL

        SPACE BULLS @ . $42 EMIT
        SPACE COWS @ . $43 EMIT

        BULLS @ 4 = IF
            1 WIN +!
            LEAVE
        ELSE
            CR
        THEN

    LOOP

    BULLS @ 4 = NOT IF
        ." It was:"
        GOAL DUP 4 + SWAP DO
            I C@ EMIT
        LOOP
    THEN
;

: BC_STAT
    WIN @ . $2F EMIT GAMES @ .
;

BC_INIT
