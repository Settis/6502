CREATE ERROR-MSG S" Testing error"

VARIABLE ACTUAL-SP \ stack record
CREATE ACTUAL-RESULTS $20 2* ALLOT
VARIABLE START-SP
VARIABLE T-STARTED
VARIABLE T-ERROR
VARIABLE T-PASSED

: T{ \ ( -- ) record the pre-test depth.
    1 T-STARTED +!
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
                    1 T-ERROR +!
                    ." INCORRECT RESULT: " ERROR-MSG ERROR LEAVE 
                THEN
            R> 1+ >R LOOP
        THEN
    ELSE                                    \ depth mismatch
        1 T-ERROR +!
        ." WRONG NUMBER OF RESULTS: " ERROR-MSG ERROR
    THEN

    1 T-PASSED +!
;

: PRINT-TEST-STAT ( -- )
    CR
    ." Total tests: " T-STARTED ? CR
    ." Passed tests: " T-PASSED ? CR
    ." Failed tests: " T-STARTED @ T-PASSED @ - T-ERROR @ - . CR
    ." Test error: " T-ERROR ? CR
;
