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

: HERE ( -- a )
    DP @
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

: MINUS ( n -- -n) \ change sign
    NOT 1 +
;

: - ( n n -- n ) \ subtract
    MINUS +
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

: [
    0 STATE !
; IMMEDIATE

: ]
    C0 STATE !
;

: TEST ( f -- n)
   5555 SWAP
   ( IF ) 0BRANCH [ HERE 0 , ] 
       1234
   ( ELSE ) BRANCH [ HERE 0 , SWAP ] [ HERE SWAP ! ]
       FEDC
   ( ENDIF ) [ HERE SWAP ! ]
   AAAA
;

0 TEST
1 TEST
