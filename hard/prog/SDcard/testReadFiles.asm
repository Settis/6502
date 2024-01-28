UPPER_RAM_START = $7f00
    INCLUDE "../std/std.asm"
    INCLUDE "fat.asm"
    INCLUDE "crc.asm"
    INCLUDE "uartPrint.asm"

    SEG code
WRONG_CRC_CODE = $FF
FILES_SIZE = 13
FILES_AND_CRC:
    STRING "/testDir/file01.dat"
    DC $00
    STRING "/testDir/file02.dat"
    DC $fa
    STRING "/testDir/file03.dat"
    DC $5f
    STRING "/testDir/file04.dat"
    DC $74
    STRING "/testDir/file05.dat"
    DC $f1
    STRING "/testDir/file06.dat"
    DC $04
    STRING "/testDir/file07.dat"
    DC $f3
    STRING "/testDir/file08.dat"
    DC $1f
    STRING "/testDir/file09.dat"
    DC $9a
    STRING "/testDir/file10.dat"
    DC $c1
    STRING "/testDir/file11.dat"
    DC $5a
    STRING "/testDir/file12.dat"
    DC $14
    STRING "/testDir/file13.dat"
    DC $90

    SEG.U zpVars
failedTests: DS 1
testFilesPointer: DS 2

    SEG code
TEST_FILE_CRC:
    WRITE_WORD FILES_AND_CRC, testFilesPointer
    FOR_X 0, UP_TO, FILES_SIZE
        COPY_2 testFilesPointer, uartStringPointer
        JSR UART_PRINT_STRING_FROM_POINTER
        UART_PRINT_CHAR " "
        JSR testFile
        IF_NOT_ZERO
            JSR INCREMENT_FAILED_TESTS
        END_IF
        JSR UART_PRINT_NUMBER
        UART_PRINTLN
    NEXT_X
    RTS

testFile:
    COPY_2 testFilesPointer, filenamePointer
    JSR OPEN_FILE_BY_NAME
    RTS_IF_NE
    LDA #0
    STA CRC_SUM
    BEGIN
        FOR_Y 0, UP_TO, half_sector_size
            LDA half_sector_pointer,Y
            JSR CRC_A
        NEXT_Y
        JSR READ_NEXT_HALF_SECTOR
    UNTIL_NOT_ZERO
    CMP #IO_END_OF_FILE
    RTS_IF_NE
    ; Skip the filename
    LDY #0
    BEGIN
        INY
        LDA (testFilesPointer),Y
    UNTIL_ZERO
    ; Load CRC after the file name
    INY
    LDA (testFilesPointer),Y
    PHA
    ; Update pointer to next test case
    INY
    CLC
    TYA
    ADC testFilesPointer
    STA testFilesPointer
    LDA testFilesPointer+1
    ADC #0
    STA testFilesPointer+1
    ; Check CRC
    PLA
    CMP CRC_SUM
    IF_EQ
        LDA #0
    ELSE_
        LDA #WRONG_CRC_CODE
    END_IF
    RTS

main:
    JSR INIT_UART_PRINT
    LDA #0
    STA failedTests
    JSR TEST_FILE_NAMES
    JSR TEST_FILE_CRC
    JSR TEST_FILE_NOT_FOUND
    JSR PRINT_TOTAL_RESULT
    JSR UART_PRINT_WAIT_FOR_BUFFER
    RTS

    MACRO START_TEST_WITH
        WRITE_WORD {1}, filenamePointer
        JSR PRINT_TEST_PREFIX
    ENDM

    MACRO CHECK_INTERNAL_NAME
        WRITE_WORD {1}, internalNamePointer
        JSR CHECK_INTERNAL_NAME_SUBROUTINE
    ENDM

LONG_FILE_NAME: STRING "/theLongNameHere.txt"
LONG_EXTENSION_NAME: STRING "/name.extension"
MAX_LENGTH_FILE_NAME: STRING "/12345678.AbC"
MAX_LENGTH_INTERNAL_FILE_NAME: STRING "12345678ABC"
FIRST_FILE_DIR_INTERNAL: STRING "TESTDIR    "
FIRST_FILE_NAME_INTERNAL: STRING "FILE01  DAT"
FULL_DIR_SHORT_FILE_NAME: STRING "/folderII/a.a"
FULL_DIR_INTERNAL: STRING "FOLDERII   "
SHORT_FILE_NAME_INTERNAL: STRING "A       A  "
TEST_FILE_NAMES:
    START_TEST_WITH LONG_FILE_NAME
    JSR TEST_INVALID_FILE_NAME

    START_TEST_WITH LONG_EXTENSION_NAME
    JSR TEST_INVALID_FILE_NAME

    START_TEST_WITH MAX_LENGTH_FILE_NAME
    CHECK_INTERNAL_NAME MAX_LENGTH_INTERNAL_FILE_NAME
    JSR CHECK_END_OF_NAME

    START_TEST_WITH FILES_AND_CRC
    CHECK_INTERNAL_NAME FIRST_FILE_DIR_INTERNAL
    CHECK_INTERNAL_NAME FIRST_FILE_NAME_INTERNAL
    JSR CHECK_END_OF_NAME

    START_TEST_WITH FULL_DIR_SHORT_FILE_NAME
    CHECK_INTERNAL_NAME FULL_DIR_INTERNAL
    CHECK_INTERNAL_NAME SHORT_FILE_NAME_INTERNAL
    JSR CHECK_END_OF_NAME

    RTS


PRINT_TEST_PREFIX:
    COPY_2 filenamePointer, uartStringPointer
    JSR UART_PRINT_STRING_FROM_POINTER
    UART_PRINT_CHAR " "
    RTS

    SEG.U zpVars
internalNamePointer: DS 1

    SEG code
CHECK_INTERNAL_NAME_SUBROUTINE:
    JSR EXTRACT_NAME_WRAPPER
    IF_ZERO
        JSR CHECK_EXPECTED_INTERNAL_NAME
    ELSE_
        JSR UART_PRINT_NUMBER
        JSR INCREMENT_FAILED_TESTS
    END_IF
    UART_PRINTLN
    RTS

NOT_ENDED_MSG: STRING "instead of ending: "
CHECK_END_OF_NAME:
    JSR EXTRACT_NAME_WRAPPER
    CMP #_EXTRACT_NEXT_NAME_END
    IF_NEQ
        JSR INCREMENT_FAILED_TESTS
        PHA 
        UART_PRINT_STRING NOT_ENDED_MSG
        PLA
        JSR UART_PRINT_NUMBER
        UART_PRINTLN
    END_IF
    RTS

TEST_INVALID_FILE_NAME:
    JSR EXTRACT_NAME_WRAPPER
    CMP #_EXTRACT_NEXT_NAME_INVALID
    IF_NEQ
        JSR INCREMENT_FAILED_TESTS
    END_IF
    JSR UART_PRINT_NUMBER
    UART_PRINT_STRING EXPTECTED_TAIL_MSG
    LDA #_EXTRACT_NEXT_NAME_INVALID
    JSR UART_PRINT_NUMBER
    UART_PRINTLN
    RTS

WRONG_Y_MSG: STRING "!!!Y is not restored!!!"
EXTRACT_NAME_WRAPPER:
    LDY #$F5
    JSR _EXTRACT_NEXT_NAME
    PHA
    CPY #$F5
    IF_NEQ
        UART_PRINT_STRING WRONG_Y_MSG
        JSR INCREMENT_FAILED_TESTS
    END_IF
    PLA
    RTS

WRONG_NAME_MSG: STRING "wrong name: "
CHECK_EXPECTED_INTERNAL_NAME:
    SUBROUTINE
    LDX #0
    FOR_Y 0, UP_TO, 11
        LDA (_fatFilename),Y
        CMP (internalNamePointer),Y
        IF_NEQ
            LDX #1
            JMP .fail
        END_IF
    NEXT_Y
    RTS
.fail
    JSR INCREMENT_FAILED_TESTS
    UART_PRINT_STRING WRONG_NAME_MSG
    FOR_Y 0, UP_TO, 11
        LDA (_fatFilename),Y
        JSR _write_to_uart
    NEXT_Y
    RTS

WRONG_FILE_NAME: STRING "/testDir/wrong.txt"
EXPTECTED_TAIL_MSG: STRING " expected: "
TEST_FILE_NOT_FOUND:
    UART_PRINT_STRING WRONG_FILE_NAME
    UART_PRINT_CHAR " "
    WRITE_WORD WRONG_FILE_NAME, filenamePointer
    JSR OPEN_FILE_BY_NAME
    CMP #IO_FILE_NOT_FOUND
    IF_NEQ
        JSR INCREMENT_FAILED_TESTS
    END_IF
    JSR UART_PRINT_NUMBER
    UART_PRINT_STRING EXPTECTED_TAIL_MSG
    LDA #IO_FILE_NOT_FOUND
    JSR UART_PRINT_NUMBER
    UART_PRINTLN
    RTS

INCREMENT_FAILED_TESTS:
    PHA
    SEI
    SED
    CLC
    LDA #1
    ADC failedTests
    STA failedTests
    CLD
    CLI
    PLA
    RTS

PASSED_MSG: STRING "Tests passed!"
FAILED_MSG: STRING "Failed tests(dec): "
PRINT_TOTAL_RESULT:
    LDA failedTests
    IF_ZERO
        UART_PRINTLN_STRING PASSED_MSG
    ELSE_
        UART_PRINT_STRING FAILED_MSG
        LDA failedTests
        JSR UART_PRINT_NUMBER
        UART_PRINTLN
    END_IF
    RTS
    
    INCLUDE "checkSegments.asm"
