    INCLUDE readSome.asm

PARTITION_OFFSET = $1BE ; 16 bytes per record, 4 records
PARTITION_TYPE_OFFSET = $4 ; 1 byte
PARTITION_START_LBA_OFFSET = $8 ; 4 bytes

FAT_FIRST_SECTOR_BYTES_PER_LOGICAL_SECTOR_OFFEST = $B ; 2 bytes
FAT_FIRST_SECTOR_SECTORS_PER_CLUSTER_OFFEST = $D ; 1 byte
FAT_FIRST_SECTOR_RESERVED_LOGICAL_SECTORS_OFFSET = $E ; 2 bytes
FAT_FIRST_SECTOR_NUBMER_OF_FATs_OFFSET = $10 ; 1 byte
FAT_FIRST_SECTOR_MEDIA_DESCRIPTOR_OFFSET = $15 ; 1 byte
FAT_FIRST_SECTOR_TOTAL_LOGICAL_SECTORS_OFFSET = $20 ; 4 bytes
FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET = $24 ; 4 bytes
FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET = $2C ; 4 bytes
FAT_FRIST_SECTOR_FS_INFORMATION_SECTOR_NUMBER_OFFSET = $30 ; 2 bytes

DIR_RECORD_HIGH_START_CLUSTER_OFFSET = $14 ; 2 bytes
DIR_RECORD_LOW_START_CLUSTER_OFFSET = $1a ; 2 bytes
DIR_RECORD_FILE_SIZE_OFFSET = $1c ; 4 bytes
DIR_RECORD_FLAGS_OFFSET = $B ; 1 byte


READ_BOOT_SECTOR_STR:
    STRING "read boot sector signature (ex. 55aa):"
READ_PARTITION_TYPE_STR:
    STRING "read partition type (ex. 0c):"
READ_BYTES_PER_LOGICAL_SECTOR_STR:
    STRING "read bytes per logical sector (ex. 02 00):"
READ_NUMBER_OF_FATs_STR:
    STRING "number of FATs (ex. 2):"
READ_MEDIA_DESCRIPTOR_STR:
    STRING "read media descriptor (ex. F8):"
READ_SECTORS_PER_CLUSTER_STR:
    STRING "sectors per cluster:"
DELETED_STR:
    STRING "deleted file"
VFAT_NAME_STR:
    STRING "VFAT name record"
NAME_STR:
    STRING "NAME: "
START_STR:
    STRING " start: "
SIZE_STR:
    STRING " size: "
FAT_READY:
    STRING "FAT ready"
ROOT_OPENED:
    STRING "Root opened"

TEST_FOLDER:
    DC "FOLDER     "
TEST_FILE:
    DC "HELLO   TXT"

    ALLOC_2 FILE_NAME_POINTER

    ALLOC FAT_SECTOR_0
    ALLOC FAT_SECTOR_1
    ALLOC FAT_SECTOR_2
    ALLOC FAT_SECTOR_3

    ; it will be pseudo data sector !!!
    ; = real data region - 2 * sectors per cluster
    ; for easy cluster address calculation
    ALLOC DATA_SECTOR_0
    ALLOC DATA_SECTOR_1
    ALLOC DATA_SECTOR_2
    ALLOC DATA_SECTOR_3

FAT_SECTORS_PER_CLUSTER = 8

    ALLOC ROOT_DIRECTORY_CLUSTER_NUBMER_0
    ALLOC ROOT_DIRECTORY_CLUSTER_NUBMER_1
    ALLOC ROOT_DIRECTORY_CLUSTER_NUBMER_2
    ALLOC ROOT_DIRECTORY_CLUSTER_NUBMER_3

    ALLOC OPENED_CLUSTER_0
    ALLOC OPENED_CLUSTER_1
    ALLOC OPENED_CLUSTER_2
    ALLOC OPENED_CLUSTER_3
    ALLOC OPENED_SECTOR_IN_CLUSTER
    ALLOC OPENED_SECTOR_0
    ALLOC OPENED_SECTOR_1
    ALLOC OPENED_SECTOR_2
    ALLOC OPENED_SECTOR_3
    ALLOC OPENED_FILE_SIZE_0
    ALLOC OPENED_FILE_SIZE_1
    ALLOC OPENED_FILE_SIZE_2
    ALLOC OPENED_FILE_SIZE_3

main:
    JSR INIT_UART_PRINT
    JSR initSD
    JSR initFAT
    UART_PRINTLN_STRING FAT_READY
    JSR openRoot
    UART_PRINTLN_STRING ROOT_OPENED

    LDA #<TEST_FOLDER
    STA FILE_NAME_POINTER
    LDA #>TEST_FOLDER
    STA FILE_NAME_POINTER + 1
    JSR openFile

    LDA #<TEST_FILE
    STA FILE_NAME_POINTER
    LDA #>TEST_FILE
    STA FILE_NAME_POINTER + 1
    JSR openFile

    JSR writeTextFileToUART

    ;JSR listFiles

    JSR UART_PRINT_WAIT_FOR_BUFFER
    RTS

writeTextFileToUART:
    SUBROUTINE
    LDX #0
.loop
    TXA
    PHA
    LDA SD_PAGE_ADDR,X
    JSR write_to_uart
    PLA
    TAX
    INX
    CPX OPENED_FILE_SIZE_0
    BNE .loop
    RTS

; Tries to initialize FAT in the first partition
initFAT:
    ; Read boot signature in 0 sector
    LDA #0
    STA SD_SECTOR_0
    STA SD_SECTOR_1
    STA SD_SECTOR_2
    STA SD_SECTOR_3
    JSR readSector

    UART_PRINT_STRING READ_BOOT_SECTOR_STR
    LDA SD_PAGE_ADDR + $1FE
    JSR UART_PRINT_NUMBER
    LDA SD_PAGE_ADDR + $1FF
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    UART_PRINT_STRING READ_PARTITION_TYPE_STR
    LDA SD_PAGE_ADDR + PARTITION_OFFSET + PARTITION_TYPE_OFFSET
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    LDA SD_PAGE_ADDR + PARTITION_OFFSET + PARTITION_START_LBA_OFFSET
    STA SD_SECTOR_0
    STA FAT_SECTOR_0
    LDA SD_PAGE_ADDR + PARTITION_OFFSET + PARTITION_START_LBA_OFFSET + 1
    STA SD_SECTOR_1
    STA FAT_SECTOR_1
    LDA SD_PAGE_ADDR + PARTITION_OFFSET + PARTITION_START_LBA_OFFSET + 2
    STA SD_SECTOR_2
    STA FAT_SECTOR_2
    LDA SD_PAGE_ADDR + PARTITION_OFFSET + PARTITION_START_LBA_OFFSET + 3
    STA SD_SECTOR_3
    STA FAT_SECTOR_3

    ; Read FAT first sector
    JSR readSector
    UART_PRINT_STRING READ_BYTES_PER_LOGICAL_SECTOR_STR
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_BYTES_PER_LOGICAL_SECTOR_OFFEST + 1
    JSR UART_PRINT_NUMBER
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_BYTES_PER_LOGICAL_SECTOR_OFFEST
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    UART_PRINT_STRING READ_NUMBER_OF_FATs_STR
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_NUBMER_OF_FATs_OFFSET
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    UART_PRINT_STRING READ_MEDIA_DESCRIPTOR_STR
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_MEDIA_DESCRIPTOR_OFFSET
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    ; It's expected to have 8 here
    UART_PRINT_STRING READ_SECTORS_PER_CLUSTER_STR
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_SECTORS_PER_CLUSTER_OFFEST
    JSR UART_PRINT_NUMBER
    UART_PRINTLN

    ; Read root dir cluster
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET
    STA ROOT_DIRECTORY_CLUSTER_NUBMER_0
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET + 1
    STA ROOT_DIRECTORY_CLUSTER_NUBMER_1
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET + 2
    STA ROOT_DIRECTORY_CLUSTER_NUBMER_2
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_ROOT_DIRECTORY_CLUSTER_NUMBER_OFFSET + 3
    STA ROOT_DIRECTORY_CLUSTER_NUBMER_3

    ; Calc FAT #1 region sector
    ; It is partition start sector (already in FAT_SECTOR_#) + fat reserved logical sectors
    CLC
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_RESERVED_LOGICAL_SECTORS_OFFSET
    ADC FAT_SECTOR_0
    STA FAT_SECTOR_0
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_RESERVED_LOGICAL_SECTORS_OFFSET + 1
    ADC FAT_SECTOR_1
    STA FAT_SECTOR_1
    LDA #0
    ADC FAT_SECTOR_2
    STA FAT_SECTOR_2
    LDA #0
    ADC FAT_SECTOR_3
    STA FAT_SECTOR_3

    ; Calc DATA region sector
    ; It is FAT_SECTOR + SECTORS_PER_FAT * NUMBER_OF_FATs (expected as 2)
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET
    STA DATA_SECTOR_0
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET + 1
    STA DATA_SECTOR_1
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET + 2
    STA DATA_SECTOR_2
    LDA SD_PAGE_ADDR + FAT_FIRST_SECTOR_LOGICAL_SECTORS_PER_FAT_OFFSET + 3
    STA DATA_SECTOR_3
    ; multiply it by 2
    ASL DATA_SECTOR_0
    ROL DATA_SECTOR_1
    ROL DATA_SECTOR_2
    ROL DATA_SECTOR_3
    ; Add FAT_SECTOR
    CLC
    LDA DATA_SECTOR_0
    ADC FAT_SECTOR_0
    STA DATA_SECTOR_0
    LDA DATA_SECTOR_1
    ADC FAT_SECTOR_1
    STA DATA_SECTOR_1
    LDA DATA_SECTOR_2
    ADC FAT_SECTOR_2
    STA DATA_SECTOR_2
    LDA DATA_SECTOR_3
    ADC FAT_SECTOR_3
    STA DATA_SECTOR_3
    ; subtract two clusters for simplification
    SEC
    LDA DATA_SECTOR_0
    SBC #[FAT_SECTORS_PER_CLUSTER*2]
    STA DATA_SECTOR_0
    LDA DATA_SECTOR_1
    SBC #0
    STA DATA_SECTOR_1
    LDA DATA_SECTOR_2
    SBC #0
    STA DATA_SECTOR_2
    LDA DATA_SECTOR_3
    SBC #0
    STA DATA_SECTOR_3

    RTS

openRoot:
    LDA ROOT_DIRECTORY_CLUSTER_NUBMER_0
    STA OPENED_CLUSTER_0
    LDA ROOT_DIRECTORY_CLUSTER_NUBMER_1
    STA OPENED_CLUSTER_1
    LDA ROOT_DIRECTORY_CLUSTER_NUBMER_2
    STA OPENED_CLUSTER_2
    LDA ROOT_DIRECTORY_CLUSTER_NUBMER_3
    STA OPENED_CLUSTER_3
    JSR openCluster
    RTS

; FINE_NAME_POINTER must be set
openFile:
    LDA #<SD_PAGE_ADDR
    STA DIR_READ_POINTER
    LDA #>SD_PAGE_ADDR
    STA DIR_READ_POINTER + 1
    ; it can be 16 dir records on the page
    SUBROUTINE
    LDX #16
.loop
    LDY #0
    LDA (DIR_READ_POINTER),Y
    BNE .proceed
    ; this it the end of files
    RTS
.proceed
    CMP #$e5
    BEQ .end
    LDY #DIR_RECORD_FLAGS_OFFSET
    LDA (DIR_READ_POINTER),Y
    CMP #$0f
    BEQ .end

    ; let's check the name
    LDY #0
.nameLoop
    LDA (DIR_READ_POINTER),Y
    CMP (FILE_NAME_POINTER),Y
    BNE .end
    INY
    CPY #11
    BNE .nameLoop
    JSR openCurrentDirRecord
    RTS
.end
    CLC
    LDA DIR_READ_POINTER
    ADC #32
    STA DIR_READ_POINTER
    LDA DIR_READ_POINTER + 1
    ADC #0
    STA DIR_READ_POINTER + 1
    DEX
    BNE .loop
    RTS

openCurrentDirRecord:
    ; it's needed file, copy it's size
    LDY #DIR_RECORD_FILE_SIZE_OFFSET
    LDA (DIR_READ_POINTER),Y
    STA OPENED_FILE_SIZE_0
    INY
    LDA (DIR_READ_POINTER),Y
    STA OPENED_FILE_SIZE_1
    INY
    LDA (DIR_READ_POINTER),Y
    STA OPENED_FILE_SIZE_2
    INY
    LDA (DIR_READ_POINTER),Y
    STA OPENED_FILE_SIZE_3

    ; open it
    LDY #DIR_RECORD_LOW_START_CLUSTER_OFFSET
    LDA (DIR_READ_POINTER),Y
    STA OPENED_CLUSTER_0
    INY
    LDA (DIR_READ_POINTER),Y
    STA OPENED_CLUSTER_1
    LDY #DIR_RECORD_HIGH_START_CLUSTER_OFFSET
    LDA (DIR_READ_POINTER),Y
    STA OPENED_CLUSTER_2
    INY
    LDA (DIR_READ_POINTER),Y
    STA OPENED_CLUSTER_3
    JSR openCluster
    RTS

    ALLOC_2 DIR_READ_POINTER
listFiles:
    LDA #<SD_PAGE_ADDR
    STA DIR_READ_POINTER
    LDA #>SD_PAGE_ADDR
    STA DIR_READ_POINTER + 1
    ; it can be 16 dir records on the page
    SUBROUTINE
    LDX #16
.loop
    LDY #0
    LDA (DIR_READ_POINTER),Y
    BNE .proceed
    ; this it the end of files
    RTS
.proceed
    CMP #$e5
    BNE .notDeleted
    UART_PRINTLN_STRING DELETED_STR
    JMP .end
.notDeleted
    LDY #DIR_RECORD_FLAGS_OFFSET
    LDA (DIR_READ_POINTER),Y
    CMP #$0f
    BNE .notVfatName
    UART_PRINTLN_STRING VFAT_NAME_STR
    JMP .end
.notVfatName
    JSR writeFileRecord
.end
    CLC
    LDA DIR_READ_POINTER
    ADC #32
    STA DIR_READ_POINTER
    LDA DIR_READ_POINTER + 1
    ADC #0
    STA DIR_READ_POINTER + 1
    DEX
    BNE .loop
    RTS

writeFileRecord:
    LDY #0
    SUBROUTINE
    UART_PRINT_STRING NAME_STR
.loop:
    LDA (DIR_READ_POINTER),Y
    JSR write_to_uart
    INY
    CPY #11
    BNE .loop

    UART_PRINT_STRING START_STR
    LDY #[DIR_RECORD_HIGH_START_CLUSTER_OFFSET+1]
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER
    DEY
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER
    LDY #[DIR_RECORD_LOW_START_CLUSTER_OFFSET+1]
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER
    DEY
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER

    UART_PRINT_STRING SIZE_STR
    LDY #[DIR_RECORD_FILE_SIZE_OFFSET+3]
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER
    DEY
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER
    DEY
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER
    DEY
    LDA (DIR_READ_POINTER),Y
    JSR UART_PRINT_NUMBER

    UART_PRINTLN

    RTS

; expects opened_cluster
; sets opened sector and reads it
; sets sector in cluster to 0
openCluster:
    LDA #0
    STA OPENED_SECTOR_IN_CLUSTER
    LDA OPENED_CLUSTER_0
    STA OPENED_SECTOR_0
    LDA OPENED_CLUSTER_1
    STA OPENED_SECTOR_1
    LDA OPENED_CLUSTER_2
    STA OPENED_SECTOR_2
    LDA OPENED_CLUSTER_3
    STA OPENED_SECTOR_3
    SUBROUTINE
    ; multiply by 8
    LDX #3
.loop
    ASL OPENED_SECTOR_0
    ROL OPENED_SECTOR_1
    ROL OPENED_SECTOR_2
    ROL OPENED_SECTOR_3
    DEX
    BNE .loop
    ; add pseudo data region
    CLC
    LDA OPENED_SECTOR_0
    ADC DATA_SECTOR_0
    STA OPENED_SECTOR_0
    STA SD_SECTOR_0
    LDA OPENED_SECTOR_1
    ADC DATA_SECTOR_1
    STA OPENED_SECTOR_1
    STA SD_SECTOR_1
    LDA OPENED_SECTOR_2
    ADC DATA_SECTOR_2
    STA OPENED_SECTOR_2
    STA SD_SECTOR_2
    LDA OPENED_SECTOR_3
    ADC DATA_SECTOR_3
    STA OPENED_SECTOR_3
    STA SD_SECTOR_3

    JSR readSector
    RTS

; reads next sector in cluster
; or finds next cluster according to FAT
nextPage:
    RTS
