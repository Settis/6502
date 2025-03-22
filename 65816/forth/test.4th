: EXIT
  $4 EMIT
;

: S" 
  $22
  WORD
  HERE C@
  1+ ALLOT
;

CREATE ERROR-MSG S" Testing error"

: TEST-ERROR
      CR
    HERE COUNT TYPE
    ." ? ERROR: "
    COUNT TYPE
  EXIT
;

' TEST-ERROR (ERROR) !

VARIABLE ACTUAL-SP \ stack record
CREATE ACTUAL-RESULTS $20 2* ALLOT
VARIABLE START-SP

: T{ \ ( -- ) record the pre-test depth.
   SP@ START-SP !
;

: -> \ ( ... -- ) record depth and contents of stack.
   SP@ DUP ACTUAL-SP ! \ record depth
   START-SP @ < IF \ if there is something on the stack
     SP@ START-SP @ SWAP - 0 DO \ save them
       ACTUAL-RESULTS I + !
       R> 1+ >R
     LOOP
   THEN
;

: }T \ ( ... -- ) comapre stack (expected) contents with saved
   \ (actual) contents.
   SP@ ACTUAL-SP @ = IF          \ if depths match
     SP@ START-SP @ < IF          \ if something on the stack
       SP@ START-SP @ SWAP - 0 DO     \ for each stack item
         ACTUAL-RESULTS I + @    \ compare actual with expected
         <> IF ." INCORRECT RESULT: " ERROR-MSG ERROR LEAVE THEN
          R> 1+ >R
       LOOP
     THEN
   ELSE                                    \ depth mismatch
     ." WRONG NUMBER OF RESULTS: " ERROR-MSG ERROR
   THEN
;

: 3 $3 ;

T{ 1 -> 1 }T
T{ 1 1 + -> 2 }T
T{ 1 2 -> 1 2 }T
T{ 1 2 3 SWAP -> 1 3 2 }T
T{ 1 2 3 SWAP -> 1 2 3 }T
T{ 1 2 SWAP -> 1 }T

EXIT
