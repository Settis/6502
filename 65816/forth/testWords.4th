' UART_KEY (KEY) !

CREATE ERROR-MSG S" Testing error"

VARIABLE ACTUAL-SP \ stack record
CREATE ACTUAL-RESULTS $20 2* ALLOT
VARIABLE START-SP
VARIABLE T-STARTED
VARIABLE T-ERROR
VARIABLE T-PASSED

: T{ \ ( -- ) record the pre-test depth.
    T-STARTED 1 +!
    SP@ START-SP !
;

: -> \ ( ... -- ) record depth and contents of stack.
    SP@ DUP ACTUAL-SP ! \ record depth
    START-SP @ < IF \ if there is something on the stack
        SP@ START-SP @ SWAP - 0 DO \ save them
            ACTUAL-RESULTS I + !
        R> 1+ >R LOOP
    THEN
;

: }T \ ( ... -- ) comapre stack (expected) contents with saved
    \ (actual) contents.
    SP@ ACTUAL-SP @ = IF          \ if depths match
        SP@ START-SP @ < IF          \ if something on the stack
            SP@ START-SP @ SWAP - 0 DO     \ for each stack item
                ACTUAL-RESULTS I + @    \ compare actual with expected
                <> IF 
                    T-ERROR 1 +!
                    ." INCORRECT RESULT: " ERROR-MSG ERROR LEAVE 
                THEN
            R> 1+ >R LOOP
        THEN
    ELSE                                    \ depth mismatch
        T-ERROR 1 +!
        ." WRONG NUMBER OF RESULTS: " ERROR-MSG ERROR
    THEN

    T-PASSED 1 +!
;

: PRINT-TEST-STAT ( -- )
    CR
    ." Total tests: " T-STARTED @ H. CR
    ." Failed tests: " T-STARTED @ T-PASSED @ - T-ERROR @ - H. CR
    ." Test error: " T-ERROR @ H. CR
;
