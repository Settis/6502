    include sd_card.asm
    
    SEG.U zpVars
filenamePointer: ds 2

    SEG code
OPEN_FILE_BY_NAME:
    LDA #IO_OK
    RTS

    SEG.U zpVars
half_sector_pointer: ds 2
half_sector_size: ds 1

    SEG code
READ_NEXT_HALF_SECTOR:
    LDA #IO_END_OF_FILE
    RTS

    SEG.U zpVars
_fatFilename: ds 11

    SEG code
_EXTRACT_NEXT_NAME_OK = 0
_EXTRACT_NEXT_NAME_INVALID = 1
_EXTRACT_NEXT_NAME_END = 2
_EXTRACT_NEXT_NAME:
    SUBROUTINE
    TYA
    PHA
    LDY #0
    LDA (filenamePointer),Y
    ; check if it is the end of the name
    IF_ZERO
        PLA
        TAY
        LDA #_EXTRACT_NEXT_NAME_END
        RTS    
    END_IF
    ; Skip '/'
    CMP #"/"
    IF_NEQ
        JMP .extractNextNameInvalid
    END_IF
    ; In order to skip it we need to increase the pointer
    INC filenamePointer
    IF_EQ ; if we have a zero after incrementing it overflows
        INC filenamePointer+1
    END_IF
    ; Fill internal name with spaces
    LDA #" "
    FOR_Y 0, UP_TO, 11
        STA (_fatFilename),Y
    NEXT_Y
    FOR_Y 0, UP_TO, 8
        LDA (filenamePointer),Y
        BEQ .end
        CMP #"."
        BEQ .nameCopied
        CMP #"/"
        BEQ .end
        JSR _TO_UPPER_CASE
        STA (_fatFilename),Y
    NEXT_Y
    ; After the name must be either '.' or the end
    INY
    LDA (filenamePointer),Y
    BEQ .end
    CMP #"/"

.nameCopied

.end
    PLA
    TAY
    LDA #_EXTRACT_NEXT_NAME_OK
    RTS

.extractNextNameInvalid:
    PLA
    TAY
    LDA #_EXTRACT_NEXT_NAME_INVALID
    RTS

_TO_UPPER_CASE:
    CMP #$60
    IF_GE
        SEC
        SBC #$20
    END_IF
    RTS