ZP_VARS_START = $C5
CODE_START = $F900
UPPER_RAM_START = $7E00
    INCLUDE "../std/std.asm"
    INCLUDE "fat.asm"

; Don't forget to restore A from stack in iterrupt
INTERRUPT_INDIRECT = $FE ; $ $FF

    SEG.U zpVars
codeStart: ds 2
codePointer: ds 2
fatStatus: ds 1

    SEG code
main:
    LDA #$FF
    STA fatStatus
    JSR INIT_FAT
    BNE fail
    WRITE_WORD INIT_FILE_NAME, filenamePointer
    JSR OPEN_FILE_BY_NAME
    BNE fail
    JSR COPY_FILE
    BNE fail
    JMP (codeStart)
fail:
    STA fatStatus
emptyLoop:
    JMP emptyLoop

INIT_FILE_NAME:
    STRING "/init.run"

COPY_FILE:
    SUBROUTINE
    JSR READ_NEXT_HALF_SECTOR
    RTS_IF_NE
    ; first two bytes are code start
    LDY #0
    LDA (half_sector_pointer),Y
    STA codeStart
    STA codePointer
    INY
    LDA (half_sector_pointer),Y
    STA codeStart+1
    STA codePointer+1
    INY
    LDX #0
    BEGIN
.loop:
        LDA (half_sector_pointer),Y
        STA (codePointer,X)
        INC codePointer
        BNE .skipUpper
        INC codePointer+1
.skipUpper:
        INY
        CPY half_sector_size
        BNE .loop
        JSR READ_NEXT_HALF_SECTOR
    WHILE_ZERO
        LDY #0
    REPEAT_
    CMP #IO_END_OF_FILE
    RTS_IF_NE
    LDA #0
    RTS

interruptHandler: 
    JMP ($FE)

    RESET_VECTOR main, interruptHandler, interruptHandler

    INCLUDE "checkSegments.asm"
    IF _ZP_VARS_END > $FE
        ECHO "ZP vars uses interrup indirect jump"
        ERR
    ENDIF
    