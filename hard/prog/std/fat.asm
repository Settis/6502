    include sd_card.asm

_BOOT_SECTOR_SIGNATURE_OFFSET = $1FE ; 2 bytes: 55 aa
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
_DIR_RECORD_SIZE = 32
_DIR_RECORD_REMOVED_FILE_NAME = $E5
_DIR_RECORD_VFAT_FLAG = $0F

    SEG code
INIT_FAT:
    SUBROUTINE
    JSR INIT_SD
    RTS_IF_NE

    ; Read boot sector
    ; A = 0 already
    STA sdSector
    STA sdSector+1
    STA sdSector+2
    STA sdSector+3
    JSR READ_SD_SECTOR
    RTS_IF_NE
    
    ; Check boot sector signature
    LDA sdPageStart + _BOOT_SECTOR_SIGNATURE_OFFSET
    CMP #$55
    BNE .wrongBootSign
    LDA sdPageStart + _BOOT_SECTOR_SIGNATURE_OFFSET+1
    CMP #$AA
    BEQ .goodBootSign
.wrongBootSign:
    LDA #IO_WRONG_BOOT_SIGNATURE
    RTS
.goodBootSign:

    ; Check partition type
    LDA sdPageStart + _PARTITION_OFFSET + _PARTITION_TYPE_OFFSET
    CMP #$0C
    IF_NEQ
        LDA #IO_WRONG_PARTITION_TYPE
        RTS
    END_IF

    ; Read partition start
    FOR_X 0, UP_TO, 4
        LDA [sdPageStart + _PARTITION_OFFSET + _PARTITION_START_LBA_OFFSET],X
        STA sdSector,X
        STA _fatSector,X
    NEXT_X
    JSR READ_SD_SECTOR
    RTS_IF_NE
    
    ; Read FAT first sector
    ; Read bytes per logical sector
    LDA sdPageStart + _FAT_FIRST_SECTOR_BYTES_PER_LOGICAL_SECTOR_OFFEST
    BNE .wrongBytesPerLogicalSector
    LDA sdPageStart + _FAT_FIRST_SECTOR_BYTES_PER_LOGICAL_SECTOR_OFFEST + 1
    CMP #2
    BEQ .proceed
.wrongBytesPerLogicalSector:
    LDA #IO_WRONG_BYTES_PER_LOGICAL_SECTOR
    RTS
.proceed:

    ; Check number of FATs
    LDA sdPageStart + _FAT_FIRST_SECTOR_NUBMER_OF_FATs_OFFSET
    CMP #2
    IF_NEQ
        LDA #IO_WRONG_FATS_NUMBER
        RTS
    END_IF

    ; Check media descriptor
    LDA sdPageStart + _FAT_FIRST_SECTOR_MEDIA_DESCRIPTOR_OFFSET
    CMP #$F8
    IF_NEQ
        LDA #IO_WRONG_FAT_MEDIA_DESCRIPTOR
        RTS
    END_IF

    ; Read sectors per cluster
    LDA sdPageStart + _FAT_FIRST_SECTOR_SECTORS_PER_CLUSTER_OFFEST
    IF_ZERO
        LDA #IO_ZERO_SECTORS_PER_CLUSTER
        RTS
    END_IF
    STA _sectorsPerCluster

    ; Read root dir cluster
    FOR_X 0, UP_TO, 4
        LDA [sdPageStart + _FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET],X
        STA _rootDirectoryClusterNumber,X
    NEXT_X

    ; Calc FAT #1 region sector
    ; It is partition start sector (already in FAT_SECTOR_#) + fat reserved logical sectors
    CLC
    LDA sdPageStart + _FAT_FIRST_SECTOR_RESERVED_LOGICAL_SECTORS_OFFSET
    ADC _fatSector
    STA _fatSector
    LDA sdPageStart + _FAT_FIRST_SECTOR_RESERVED_LOGICAL_SECTORS_OFFSET + 1
    ADC _fatSector + 1
    STA _fatSector + 1
    IF_C_SET
        INC _fatSector + 2
        IF_ZERO
            INC _fatSector + 3
        END_IF
    END_IF

    ; Calc DATA region sector
    ; It is FAT_SECTOR + SECTORS_PER_FAT * NUMBER_OF_FATs (expected as 2)
    FOR_X 0, UP_TO, 4
        LDA [sdPageStart + _FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET],X
        STA _dataSector,X
    NEXT_X
    ; multiply it by 2
    ASL _dataSector
    ROL _dataSector + 1
    ROL _dataSector + 2
    ROL _dataSector + 3
    ; Add FAT_SECTOR
    CLC
    LDA _dataSector
    ADC _fatSector
    STA _dataSector
    LDA _dataSector + 1
    ADC _fatSector + 1
    STA _dataSector + 1
    LDA _dataSector + 2
    ADC _fatSector + 2
    STA _dataSector + 2
    LDA _dataSector + 3
    ADC _fatSector + 3
    STA _dataSector + 3
    ; subtract two clusters for simplification
    LDA _sectorsPerCluster
    ASL
    STA _tmpDoubleClusters
    SEC
    LDA _dataSector
    SBC _tmpDoubleClusters
    STA _dataSector
    IF_C_CLR
        DEC _dataSector + 1
        IF_ZERO
            DEC _dataSector + 2
            IF_ZERO
                DEC _dataSector + 3
            END_IF
        END_IF
    END_IF
    LDA #0
    RTS
    
    SEG.U zpVars
filenamePointer: ds 2
_fatSector: ds 4
; it will be pseudo data sector !!!
; = real data region - 2 * sectors per cluster
; for easy cluster address calculation
_dataSector: ds 4
_sectorsPerCluster: ds 1
_rootDirectoryClusterNumber: ds 4
_openedCluster: ds 4
_openedSectorInCluster: ds 1
_tmpDoubleClusters = _openedSectorInCluster
_openedSector: ds 4
_openedFileSize: ds 4

    SEG code
OPEN_FILE_BY_NAME:
    TXA
    PHA
    TYA
    PHA
    JSR _INNER_OPEN_FILE_BY_NAME
    STA _crc ; I hope it will be OK
    PLA
    TAY
    PLA
    TAX
    LDA _crc
    RTS

_INNER_OPEN_FILE_BY_NAME:
    SUBROUTINE
    JSR _OPEN_ROOT
    RTS_IF_NE
.loop:
    JSR _EXTRACT_NEXT_NAME
    BEQ .openIt
    BMI .opened
    LDA #IO_INVALID_FILENAME_FORMAT
    RTS
.opened:
    LDA #$FF
    STA half_sector_pointer + 1
    LDA #IO_OK
    RTS
.openIt:
    JSR _OPEN_FILE_IN_FOLDER
    BEQ .loop
    RTS

; Changes X & Y
_OPEN_ROOT:
    FOR_X 0, UP_TO, 4
        LDA _rootDirectoryClusterNumber,X
        STA _openedCluster,X
    NEXT_X
    ; JMP _OPEN_CLUSTER ; not needed, the _OPEN_CLUSTER goes next
    ; end is here

; expects _openedCluster
; sets opened sector and reads it
; sets sector in cluster to 0
; Changes X & Y
_OPEN_CLUSTER:
    LDA #0
    STA _openedSectorInCluster
    ; openedSector = openedCluster*sectorsPerCluster + pseudoDataRegion
    ;   copy 
    FOR_X 0, UP_TO, 4
        LDA _openedCluster,X
        STA _openedSector,X
    NEXT_X
    ;   multiply
    LDA _sectorsPerCluster
    BEGIN
        LSR
    WHILE_C_CLR
        ASL _openedSector
        ROL _openedSector + 1
        ROL _openedSector + 2
        ROL _openedSector + 3
    REPEAT_
    ;   add pseudo data region
    CLC
    LDA _openedSector
    ADC _dataSector
    STA _openedSector
    STA sdSector
    LDA _openedSector + 1
    ADC _dataSector + 1
    STA _openedSector + 1
    STA sdSector + 1
    LDA _openedSector + 2
    ADC _dataSector + 2
    STA _openedSector + 2
    STA sdSector + 2
    LDA _openedSector + 3
    ADC _dataSector + 3
    STA _openedSector + 3
    STA sdSector + 3
    JMP READ_SD_SECTOR
    ; end is here

    SEG.U zpVars
half_sector_pointer: ds 2
half_sector_size: ds 1

    SEG code
; The method called from the beggining of reading the file and for each next sub-sector
READ_NEXT_HALF_SECTOR:
    JSR _CHECK_ZERO_SIZE
    RTS_IF_NE
    
; first run:
;   if file_size > FF
;       half_sector_size = FF
;   else 
;       half_sector_size = file_size
; not first run:
;   file_size -= 100 && check borrow bit to return END of file
;   update_half_sector_size
;   update pointer to next half of sector in memory
;   or read next sector

    LDA half_sector_pointer + 1
    ; if can't be on upper memory, so it's first run
    BPL .secondRun
    WRITE_WORD sdPageStart, half_sector_pointer
    JSR _UPDATE_HALF_SECTOR_SIZE
    LDA #IO_OK
    RTS
.secondRun:
;   file_size -= 100 && check borrow bit to return END of file
    LDA _openedFileSize+1
    SEC
    SBC #1
    STA _openedFileSize+1
    IF_C_CLR
        LDA _openedFileSize+2
        SEC
        SBC #1
        STA _openedFileSize+2
        IF_C_CLR
            LDA _openedFileSize+3
            SEC
            SBC #1
            STA _openedFileSize+3
            IF_C_CLR
                LDA #IO_END_OF_FILE
                RTS
            END_IF
        END_IF
    END_IF
    JSR _CHECK_ZERO_SIZE
    RTS_IF_NE
    JSR _UPDATE_HALF_SECTOR_SIZE
    LDA half_sector_pointer + 1
    CMP #>sdPageStart
    BNE .readNextSector
    INC half_sector_pointer + 1
    LDA #IO_OK
    RTS
.readNextSector:
    DEC half_sector_pointer + 1
    JMP _READ_NEXT_SECTOR
    ; end of subroutine

_CHECK_ZERO_SIZE:
    SUBROUTINE
    LDA _openedFileSize
    BNE .proceed
    LDA _openedFileSize+1
    BNE .proceed
    LDA _openedFileSize+2
    BNE .proceed
    LDA _openedFileSize+3
    BNE .proceed
    LDA #IO_END_OF_FILE
    RTS
.proceed:
    LDA #0
    RTS

_UPDATE_HALF_SECTOR_SIZE:
    SUBROUTINE
    LDA _openedFileSize+1
    BNE .fullPage
    LDA _openedFileSize+2
    BNE .fullPage
    LDA _openedFileSize+3
    BNE .fullPage
    LDA _openedFileSize ; must not be a 0
    BNE .end ; instead of JMP
.fullPage:
    LDA #0
.end:
    STA half_sector_size
    RTS

    SEG.U zpVars
_fatFilename: ds 11

    SEG code
_EXTRACT_NEXT_NAME_OK = 0
_EXTRACT_NEXT_NAME_INVALID = 1
_EXTRACT_NEXT_NAME_END = $FF
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

    SEG.U zpVars
_dirReadPointer: ds 2

    SEG code
_OPEN_FILE_IN_FOLDER:
    BEGIN
        WRITE_WORD sdPageStart, _dirReadPointer
        JSR _OPEN_FILE_IN_THE_PAGE
        RTS_IF_PLUS
        JSR _READ_NEXT_SECTOR
    UNTIL_NOT_ZERO
    LDA #IO_FILE_NOT_FOUND
    RTS

; uses X & Y
_OPEN_FILE_IN_THE_PAGE:
    SUBROUTINE
    ; it can be 16 dir records on the page
    FOR_X 0, UP_TO, 16
        LDY #0
        LDA (_dirReadPointer),Y
        ; check if it is the end of folder
        BEQ .notFound
        ; check if the file is removed
        CMP #_DIR_RECORD_REMOVED_FILE_NAME
        BEQ .nextRecord
        ; check if the record is VFAT name
        LDY #_DIR_RECORD_FLAGS_OFFSET
        LDA (_dirReadPointer),Y
        CMP #_DIR_RECORD_VFAT_FLAG
        BEQ .nextRecord
        ; check the name
        FOR_Y 0, UP_TO, 11
            LDA (_dirReadPointer),Y
            CMP _fatFilename,Y
            BNE .nextRecord
        NEXT_Y
        ; it's needed file
        JMP _OPEN_CURRENT_DIR_RECORD
.nextRecord:
        CLC
        LDA _dirReadPointer
        ADC #_DIR_RECORD_SIZE
        STA _dirReadPointer
        IF_C_SET
            INC _dirReadPointer + 1
        END_IF
    NEXT_X
.notFound
    LDA #$FF ; it's negative so I can recognize it easy
    RTS

_OPEN_CURRENT_DIR_RECORD:
    ; copy file size
    FOR_Y _DIR_RECORD_FILE_SIZE_OFFSET, UP_TO, _DIR_RECORD_FILE_SIZE_OFFSET + 4
        LDA (_dirReadPointer),Y
        STA [_openedFileSize-_DIR_RECORD_FILE_SIZE_OFFSET],Y
    NEXT_Y
    ; copy file start cluster
    LDY #_DIR_RECORD_LOW_START_CLUSTER_OFFSET
    LDA (_dirReadPointer),Y
    STA _openedCluster
    INY
    LDA (_dirReadPointer),Y
    STA _openedCluster + 1
    LDY #_DIR_RECORD_HIGH_START_CLUSTER_OFFSET
    LDA (_dirReadPointer),Y
    STA _openedCluster + 2
    INY
    LDA (_dirReadPointer),Y
    STA _openedCluster + 3
    JMP _OPEN_CLUSTER
    ; the end here

; After the cluster is opened this routine either read the next page inside the cluster or figures out via FAT
; where the next cluster is and reads it
_READ_NEXT_SECTOR:
    SUBROUTINE
    ; Increase the current opened sector and see if it still fit in the cluster
    INC _openedSectorInCluster
    LDA _sectorsPerCluster
    CMP _openedSectorInCluster
    BEQ .nextCluster
    ; Increase opened sector number
    INC _openedSector
    IF_ZERO
        INC _openedSector+1
        IF_ZERO
            INC _openedSector+2
            IF_ZERO
                INC _openedSector+3
            END_IF
        END_IF
    END_IF
    FOR_X 0, UP_TO, 4
        LDA _openedSector,X
        STA sdSector,X
    NEXT_X
    JMP READ_SD_SECTOR
.nextCluster
    LDA #IO_FAT_END_OF_CLUSTERS
    RTS
