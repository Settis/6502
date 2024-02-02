    include sd_card.asm

_PARTITION_OFFSET = $1BE ; 16 bytes per record, 4 records
_PARTITION_TYPE_OFFSET = $4 ; 1 byte
_PARTITION_START_LBA_OFFSET = $8 ; 4 bytes

_FAT_FIRST_SECTOR_BYTES_PER_LOGICAL_SECTOR_OFFEST = $B ; 2 bytes
_FAT_FIRST_SECTOR_SECTORS_PER_CLUSTER_OFFEST = $D ; 1 byte
_FAT_FIRST_SECTOR_RESERVED_LOGICAL_SECTORS_OFFSET = $E ; 2 bytes
_FAT_FIRST_SECTOR_NUBMER_OF_FATs_OFFSET = $10 ; 1 byte
_FAT_FIRST_SECTOR_MEDIA_DESCRIPTOR_OFFSET = $15 ; 1 byte
_FAT_FIRST_SECTOR_TOTAL_LOGICAL_SECTORS_OFFSET = $20 ; 4 bytes
_FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET = $24 ; 4 bytes
_FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET = $2C ; 4 bytes
_FAT_FRIST_SECTOR_FS_INFORMATION_SECTOR_NUMBER_OFFSET = $30 ; 2 bytes

_DIR_RECORD_HIGH_START_CLUSTER_OFFSET = $14 ; 2 bytes
_DIR_RECORD_LOW_START_CLUSTER_OFFSET = $1a ; 2 bytes
_DIR_RECORD_FILE_SIZE_OFFSET = $1c ; 4 bytes
_DIR_RECORD_FLAGS_OFFSET = $B ; 1 byte

    SEG code
BOOT_SECTOR_SIGN_MSG: STRING "Boot sector sign: "
INIT_FAT:
    JSR INIT_SD
    RTS_IF_NE
    ; A = 0 already
    STA sdSector
    STA sdSector+1
    STA sdSector+2
    STA sdSector+3
    JSR READ_SD_SECTOR
    RTS_IF_NE
    
    UART_PRINT_STRING BOOT_SECTOR_SIGN_MSG
    LDA sdPageStart + $1FE
    JSR UART_PRINT_NUMBER
    LDA sdPageStart + $1FF
    JSR UART_PRINT_NUMBER
    UART_PRINTLN
    LDA #0
    RTS
    
    SEG.U zpVars
filenamePointer: ds 2
_fatSector: ds 4
; it will be pseudo data sector !!!
; = real data region - 2 * sectors per cluster
; for easy cluster address calculation
_dataSector: ds 4
_fatSectorsPerCluster: ds 1
_rootDirectoryClusterNumber: ds 4
_openedCluster: ds 4
_openedSectorInCluster: ds 1
_openedSector: ds 4
_openedFileSize: ds 4

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
        STA _fatFilename,Y
    NEXT_Y
    ; Copy file name
    FOR_Y 0, UP_TO, 8
        LDA (filenamePointer),Y
        BEQ .end
        CMP #"."
        BEQ .nameCopied
        CMP #"/"
        BEQ .end
        JSR _TO_UPPER_CASE
        STA _fatFilename,Y
    NEXT_Y
    ; After the name must be either '.' or the end
    ; INY is not needed Y = 8 already at the end of the loop
    LDA (filenamePointer),Y
    BEQ .end
    CMP #"/"
    BEQ .end
    CMP #"."
    BEQ .nameCopied
    JMP .extractNextNameInvalid
.nameCopied
    INY ; in order to point on first extension character
    JSR _SHIFT_FILENAME_POINTER_BY_Y
    ; Copy extension
    FOR_Y 0, UP_TO, 3
        LDA (filenamePointer),Y
        BEQ .end
        CMP #"/"
        BEQ .end
        JSR _TO_UPPER_CASE
        STA _fatFilename+8,Y
    NEXT_Y
    ; After extension it must be either '/' or end of line
    LDA (filenamePointer),Y
    BEQ .end
    CMP #"/"
    BEQ .end
    JMP .extractNextNameInvalid
.end
    JSR _SHIFT_FILENAME_POINTER_BY_Y
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

_SHIFT_FILENAME_POINTER_BY_Y:
    CLC
    TYA
    ADC filenamePointer
    STA filenamePointer
    IF_C_SET
        INC filenamePointer+1
    END_IF  
    RTS
