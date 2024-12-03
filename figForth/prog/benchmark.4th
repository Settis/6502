\ 10 000 ticks
\ 270E T_START_VAL !
\ 50 000 ticks
C34E T_START_VAL !

HERE

T_START

6 CONSTANT SIZE

VARIABLE DATA_ADDR SIZE 2* ALLOT

: GET_NEXT ( n -- n )
    MINUS
    DUP 0< IF
        1+
    ELSE
        1-
    ENDIF
;

: INIT 
    8001
    SIZE 0 DO
        DUP
        I 2* DATA_ADDR + !
        GET_NEXT
    LOOP
    DROP
;

: PRINT
    SIZE 0 DO
        I 2*
        DATA_ADDR + @
        . 
    LOOP
;

: SORT
;

T_STOP
." Compile time:" T_CNT @ . CR

HERE SWAP - \ Total dictionary size
SIZE 2* -
." Dictionary:" . CR

T_START
INIT
T_STOP
." Init time:" T_CNT @ . CR
." Array: " PRINT CR

T_START
SORT
T_STOP
." Sort time:" T_CNT @ . CR
." Array: " PRINT CR
