: WAIT ( n -- )
    0 UPTIMEMS D+
    BEGIN
        2DUP
        UPTIMEMS
        D<
    UNTIL
    2DROP
;

: M_CH ( n -- )
    $F CHVOL
;

: EXIT 
    4 EMIT
;

3 VOL !
