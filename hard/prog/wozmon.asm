;-------------------------------------------------------------------------
;
;  The WOZ Monitor for the Apple 1
;  Written by Steve Wozniak 1976
;  And updated to work with 16*2 character display
;  Also with ability to work in ROM and runned via UART
;  Hardware:
;       Keyboard connected to VIA1 port A
;       Display connected to VIA1 port B
;
;-------------------------------------------------------------------------

RAM = 1
    IF RAM = 0
        ORG $FC00
    else
        ORG $0300
    endif

                ; .CR     6502
                ; .OR     $FF00
                ; .TF     WOZMON.HEX,HEX,8

;-------------------------------------------------------------------------
;  Memory declaration
;-------------------------------------------------------------------------

;XAML            =     $24            ; Last "opened" location Low
    ALLOC XAML
;XAMH            =     $25            ; Last "opened" location High
    ALLOC XAMH
;STL             =     $26            ; Store address Low
    ALLOC STL
;STH             =     $27            ; Store address High
    ALLOC STH
;L               =     $28            ; Hex value parsing Low
    ALLOC L
;H               =     $29            ; Hex value parsing High
    ALLOC H
;YSAV            =     $2A            ; Used to see if hex value is given
    ALLOC YSAV
;MODE            =     $2B            ; $00=XAM, $7F=STOR, $AE=BLOCK XAM
    ALLOC MODE

IN              =     $0200 ;,$027F    ; Input buffer

; KBD             =     $D010          ; PIA.A keyboard input
; KBDCR           =     $D011          ; PIA.A keyboard control register
; DSP             =     $D012          ; PIA.B display output register
; DSPCR           =     $D013          ; PIA.B display control register

    ALLOC buf_write_ind
    ALLOC buf_read_ind
    ALLOC release_button
    ALLOC shift_pressed

buf_start = $0280 ; Size $0F up to $028F

    ; For steam locomotive
	ALLOC_2 FRAME_CHAR_START
	ALLOC POSITION

; KBD b7..b0 are inputs, b6..b0 is ASCII input, b7 is constant high
;     Programmed to respond to low to high KBD strobe
; DSP b6..b0 are outputs, b7 is input
;     CB2 goes low when data is written, returns high when CB1 goes high
; Interrupts are enabled, though not used. KBD can be jumpered to IRQ,
; whereas DSP can be jumpered to NMI.

;-------------------------------------------------------------------------
;  Constants
;-------------------------------------------------------------------------

BS              =     $DF            ; Backspace key, arrow left key
CR              =     $8D            ; Carriage Return
NEXT_LINE       =     $8E
ESC             =     $9B            ; ESC key
PROMPT          =     ">"            ; Prompt character

keymap:
    .byte "????????????? `?" ; 00-0F
    .byte "?????q1???zsaw2?" ; 10-1F
    .byte "?cxde43?? vftr5?" ; 20-2F
    .byte "?nbhgy6???mju78?" ; 30-3F
    .byte "?,kio09??./l;p-?" ; 40-4F
    .byte "??'?[=?????]?\??" ; 50-5F
    .byte "?????????1?47???" ; 60-6F
    .byte "0.2568???+3-*9??" ; 70-7F
    .byte "????????????? ~?" ; 80-8F
    .byte "?????Q!???ZSAW@?" ; 90-9F
    .byte "?CXDE$#?? VFTR%?" ; A0-AF
    .byte "?NBHGY^???MJU&*?" ; B0-BF
    .byte "?<KIO)(??>?L:P_?" ; C0-CF
    .byte "??'?{+?????}?|??" ; D0-DF
    .byte "?????????!?$&???" ; E0-EF
    .byte ")>@%^*???+#_*(??" ; F0-FF

    INCDIR "std"
    INCLUDE "std.asm"
    INCLUDE "display.asm"

read_kb: ; Interrupt handler for read from Keyboard
    PHA
    TXA
    PHA

    LDA VIA_FIRST_IFR
    LDX buf_write_ind
    LDA VIA_FIRST_RA
    STA buf_start,X
    INX
    TXA
    AND #$0F
    STA buf_write_ind
    
    PLA
    TAX
    PLA

    RTI

wait_for_key_press:
read_kb_buffer:
    ; Check if something in the buffer
    LDA buf_read_ind
    CMP buf_write_ind
    BEQ read_kb_buffer
    ; Read the scan code from buffer
    LDX buf_read_ind
    LDA buf_start,X
    TAX
    ; Increase buffer pointer
    LDA buf_read_ind
    CLC
    ADC #$1
    AND #$0F
    STA buf_read_ind
    TXA

    ; Check if that scan code after release
    LDX #0
    CPX release_button
    BEQ print_check_release
    DEC release_button
    CMP #$12
    BEQ shift_released_branch
    CMP #$59
    BEQ shift_released_branch
    JMP read_kb_buffer

print_check_release:
    ; Check for release scan code
    CMP #$F0
    BNE after_release_check
    INC release_button
    JMP read_kb_buffer

shift_released_branch:
    LDX #0
    STX shift_pressed
    JMP read_kb_buffer

after_release_check:
    CMP #$12
    BEQ shift_pressed_branch
    CMP #$59
    BEQ shift_pressed_branch
    JMP check_key_pressed

shift_pressed_branch:
    LDX #1
    STX shift_pressed
    JMP read_kb_buffer

check_key_pressed:
    ; Check if it was pressed some non ASCII
    CMP #$76
    BEQ esc_key_pressed
    CMP #$5A
    BEQ enter_key_pressed
    ; Special case for NUM pad, ignore it
    CMP #$E0
    BEQ read_kb_buffer
    CMP #$75
    BEQ arrow_up_down_pressed
    CMP #$72
    BEQ arrow_up_down_pressed
    CMP #$6B
    BEQ arrow_left_pressed
    CMP #$74
    BEQ arrow_right_pressed
    CMP #$66
    BEQ backspace_pressed
    ; Here is an ASCII convert and return it
    JMP convert_key

esc_key_pressed:
    ; JSR CLEAR_DISPLAY
    ; JMP process_key_end
    LDA #ESC
    RTS

enter_key_pressed:
    ; JSR DISPLAY_CHANGE_LINE
    ; JMP process_key_end
    LDA #CR
    RTS

arrow_up_down_pressed:
    JSR READ_FROM_DISPLAY
    EOR #%01000000
    ORA #%10000000
    JSR SEND_DISPLAY_COMMAND
    JMP read_kb_buffer

arrow_left_pressed:
    JSR READ_FROM_DISPLAY
    SEC
    SBC #1
    ORA #%10000000
    JSR SEND_DISPLAY_COMMAND
    JMP read_kb_buffer

arrow_right_pressed:
    JSR READ_FROM_DISPLAY
    CLC
    ADC #1
    ORA #%10000000
    JSR SEND_DISPLAY_COMMAND
    JMP read_kb_buffer

backspace_pressed:
    ; JSR READ_FROM_DISPLAY
    ; SEC
    ; SBC #1
    ; ORA #%10000000
    ; PHA
    ; JSR SEND_DISPLAY_COMMAND
    ; LDA #" "
    ; JSR PRINT_CHAR
    ; PLA
    ; JSR SEND_DISPLAY_COMMAND
    ; JMP process_key_end
    LDA #BS
    RTS

convert_key:
    LDX #0
    CPX shift_pressed
    BEQ convert_and_return
    ORA #$80
convert_and_return:
    TAX
    LDA keymap,X
    RTS

;-------------------------------------------------------------------------
;  Let's get started
;
;  Remark the RESET routine is only to be entered by asserting the RESET
;  line of the system. This ensures that the data direction registers
;  are selected.
;-------------------------------------------------------------------------

main:
RESET           CLD                  ;   Clear decimal arithmetic mode

    IF RAM = 1
        LDA #<read_kb
        STA $FE
        LDA #>read_kb
        STA $FF
    ENDIF

    LDA #$00
    STA buf_write_ind
    STA buf_read_ind
    STA release_button
    STA shift_pressed

    ; Disable all interrupts
    LDA #$7F
    STA VIA_FIRST_IER

; Setup port directions
    ; LDA #$F3
    ; STA VIA_FIRST_DDRB

; Setup handshakes
    LDA #%11000001
    STA VIA_FIRST_PCR

    ; Enable CA1 interrupt
    LDA #$82
    STA VIA_FIRST_IER

; Disable latch
    LDA #$00
    STA VIA_FIRST_ACR

; CA1 interrupts on positive edge
    ; LDA #$01
    ; STA VIA_FIRST_PCR

; Setup port directions
    LDA #$00
    STA VIA_FIRST_DDRA

    LDA VIA_FIRST_IFR
    LDA VIA_FIRST_RA

    CLI

; Init display 2
    WRITE_WORD VIA_FIRST_PCR, DISPLAY_PCR
    WRITE_WORD VIA_FIRST_RB, DISPLAY_ADDR
    WRITE_WORD VIA_FIRST_DDRB, DISPLAY_DDR
    LDA #%00100000
    STA DISPLAY_PCR_MASK
    JSR INIT_DISPLAY

    ; ; Set display mode shift at the time during writing operation.
    ; LDA #%00000111
    ; JSR SEND_DISPLAY_COMMAND

                LDY     #%01111111  ;   Mask for DSP data direction reg
                ;STY     DSP          ;    (DDR mode is assumed after reset)
                LDA     #%10100111  ;   KBD and DSP control register mask
                ;STA     KBDCR        ;   Enable interrupts, set CA1, CB1 for
                ;STA     DSPCR        ;    positive edge sense/output mode.

; Program falls through to the GETLINE routine to save some program bytes
; Please note that Y still holds $7F, which will cause an automatic Escape

;-------------------------------------------------------------------------
; The GETLINE process
;-------------------------------------------------------------------------

NOTCR           CMP     #BS            ; Backspace key?
                BEQ     BACKSPACE      ; Yes
                CMP     #ESC           ; ESC?
                BEQ     ESCAPE         ; Yes
                INY                    ; Advance text index
                BPL     NEXTCHAR       ; Auto ESC if line longer than 127

ESCAPE          
    JSR CLEAR_DISPLAY
                LDA     #PROMPT        ; Print prompt character
                JSR     ECHO           ; Output it.
; GETLINE: 
    ; doing nothing line was changed in ECHO

; Initial GETLINE
; GETLINE         LDA     #CR            ; Send CR
;                 JSR     ECHO

                LDY     #0+1           ; Start a new input line
BACKSPACE       DEY                    ; Backup text index
                BMI     ESCAPE        ; Oops, line's empty, reinitialize

NEXTCHAR        ;LDA     KBDCR          ; Wait for key press
                ;BPL     NEXTCHAR       ; No key yet!
                ;LDA     KBD            ; Load character. B7 should be '1'
    JSR read_kb_buffer
                STA     IN,Y           ; Add to text buffer
                JSR     ECHO           ; Display character
                CMP     #CR
                BNE     NOTCR          ; It's not CR!

; Line received, now let's parse it
    JSR TEST_FOR_SL

                LDY     #-1            ; Reset text index
                LDA     #0             ; Default mode is XAM
                TAX                    ; X=0

SETBLOCK:
    ASL
SETSTOR         ASL                    ; Leaves $7B if setting STOR mode

SETMODE         STA     MODE           ; Set mode flags

BLSKIP          INY                    ; Advance text index

NEXTITEM        LDA     IN,Y           ; Get character
                CMP     #CR
                ; BEQ     GETLINE        ; We're done if it's CR!
                BNE     PROCEED_NEXT_ITEM
                JSR wait_for_key_press
                JMP ESCAPE
PROCEED_NEXT_ITEM:
                CMP     #"."
                BCC     BLSKIP         ; Ignore everything below "."!
                BEQ     SETBLOCK        ; Set BLOCK XAM mode ("." = $AE)
                CMP     #":"
                BEQ     SETSTOR        ; Set STOR mode! $BA will become $7B
                CMP     #"R"
                BEQ     RUN            ; Run the program! Forget the rest
    ; For lower case too
    CMP #"r"
    BEQ RUN
                STX     L              ; Clear input value (X=0)
                STX     H
                STY     YSAV           ; Save Y for comparison

; Here we're trying to parse a new hex value

NEXTHEX         LDA     IN,Y           ; Get character for hex test
                EOR     #$30           ; Map digits to 0-9
                CMP     #9+1           ; Is it a decimal digit?
                BCC     DIG            ; Yes!
    ORA #%00100000 ; I need it for case insensitive convertion
                ADC     #$88           ; Map letter "A"-"F" to $FA-FF
                CMP     #$FA           ; Hex letter?
                BCC     NOTHEX         ; No! Character not hex

DIG             ASL
                ASL                    ; Hex digit to MSD of A
                ASL
                ASL

                LDX     #4             ; Shift count
HEXSHIFT        ASL                    ; Hex digit left, MSB to carry
                ROL     L              ; Rotate into LSD
                ROL     H              ; Rotate into MSD's
                DEX                    ; Done 4 shifts?
                BNE     HEXSHIFT       ; No, loop
                INY                    ; Advance text index
                BNE     NEXTHEX        ; Always taken

NOTHEX          CPY     YSAV           ; Was at least 1 hex digit given?
                BEQ     ESCAPE         ; No! Ignore all, start from scratch

                BIT     MODE           ; Test MODE byte
                BVC     NOTSTOR        ; B6=0 is STOR, 1 is XAM or BLOCK XAM

; STOR mode, save LSD of new hex byte

                LDA     L              ; LSD's of hex data
                STA     (STL,X)        ; Store current 'store index'(X=0)
                INC     STL            ; Increment store index.
                BNE     NEXTITEM       ; No carry!
                INC     STH            ; Add carry to 'store index' high
TONEXTITEM      JMP     NEXTITEM       ; Get next command item.

;-------------------------------------------------------------------------
;  RUN user's program from last opened location
;-------------------------------------------------------------------------

RUN             JMP     (XAML)         ; Run user's program

;-------------------------------------------------------------------------
;  We're not in Store mode
;-------------------------------------------------------------------------

NOTSTOR         BMI     XAMNEXT        ; B7 = 0 for XAM, 1 for BLOCK XAM

; We're in XAM mode now

                LDX     #2             ; Copy 2 bytes
SETADR          LDA     L-1,X          ; Copy hex data to
                STA     STL-1,X        ;  'store index'
                STA     XAML-1,X       ;  and to 'XAM index'
                DEX                    ; Next of 2 bytes
                BNE     SETADR         ; Loop unless X = 0

; Print address and data from this address, fall through next BNE.

NXTPRNT         BNE     PRDATA         ; NE means no address to print
                LDA     #NEXT_LINE            ; Print CR first
                JSR     ECHO
                LDA     XAMH           ; Output high-order byte of address
                JSR     PRBYTE
                LDA     XAML           ; Output low-order byte of address
                JSR     PRBYTE
                LDA     #":"           ; Print colon
                JSR     ECHO
                JMP SKIP_SPACE

PRDATA          LDA     #" "           ; Print space
                JSR     ECHO
SKIP_SPACE:
                LDA     (XAML,X)       ; Get data from address (X=0)
                JSR     PRBYTE         ; Output it in hex format
XAMNEXT         STX     MODE           ; 0 -> MODE (XAM mode).
                LDA     XAML           ; See if there's more to print
                CMP     L
                LDA     XAMH
                SBC     H
                BCS     TONEXTITEM     ; Not less! No more data to output

                INC     XAML           ; Increment 'examine index'
                BNE     MOD8CHK        ; No carry!
                INC     XAMH

MOD8CHK         LDA     XAML           ; If address MOD 4 = 0 start new line
                AND     #%00000011
                BPL     NXTPRNT        ; Always taken.

;-------------------------------------------------------------------------
;  Subroutine to print a byte in A in hex form (destructive)
;-------------------------------------------------------------------------

PRBYTE          PHA                    ; Save A for LSD
                LSR
                LSR
                LSR                    ; MSD to LSD position
                LSR
                JSR     PRHEX          ; Output hex digit
                PLA                    ; Restore A

; Fall through to print hex routine

;-------------------------------------------------------------------------
;  Subroutine to print a hexadecimal digit
;-------------------------------------------------------------------------

PRHEX           AND     #%00001111    ; Mask LSD for hex print
                ORA     #"0"           ; Add "0"
                CMP     #"9"+1         ; Is it a decimal digit?
                BCC     ECHO           ; Yes! output it
                ADC     #6             ; Add offset for letter A-F

; Fall through to print routine

;-------------------------------------------------------------------------
;  Subroutine to print a character to the terminal
;-------------------------------------------------------------------------

; ECHO            BIT     DSP            ; DA bit (B7) cleared yet?
;                 BMI     ECHO           ; No! Wait for display ready
;                 STA     DSP            ; Output character. Sets DA
;                 RTS

ECHO:
    PHA
    CASE ACCUM
        CASE_OF BS
            JSR READ_FROM_DISPLAY
            SEC
            SBC #1
            ORA #%10000000
            PHA
            JSR SEND_DISPLAY_COMMAND
            LDA #" "
            JSR PRINT_CHAR
            PLA
            JSR SEND_DISPLAY_COMMAND
        END_OF
        CASE_OF CR
            ; Ignoring CR from keyboard
        END_OF
        CASE_OF NEXT_LINE
            ; Load cursor position
            JSR READ_FROM_DISPLAY
            AND #%01000000
            IF_NOT_ZERO
                TXA
                PHA
                JSR wait_for_key_press
                JSR CLEAR_DISPLAY
                PLA
                TAX
                LDA #%10000000
            ELSE_
                LDA #%11000000
            END_IF
            JSR SEND_DISPLAY_COMMAND
        END_OF
        if RAM = 1
            CASE_OF ESC
                ; Disable interrupts from keyboard
                ; Disable all interrupts
                LDA #$7F
                STA VIA_FIRST_IER
                ; Read keyboard content just in case
                LDA VIA_FIRST_IFR
                LDA VIA_FIRST_RA
                ; Work with stack
                PLA ; pull character
                PLA ; pull echo L
                PLA ; pull echo H
                RTS
            END_OF
        endif
        JSR PRINT_CHAR
    END_CASE
    PLA
    RTS

SL_LINE:
    DC "s","l",CR

TEST_FOR_SL:
    FOR_X 0, UP_TO, 3
        LDA SL_LINE,X
        CMP IN,X
        IF_NEQ
            RTS
        END_IF
    NEXT_X

STEAM_LOCOMOTIVE:
    ; Disable cursor
	LDA #%00001100
	JSR SEND_DISPLAY_COMMAND

S_L_LOOP:
    LDA #%00000001
	JSR SEND_DISPLAY_COMMAND
	JSR delay_1_52

	; Shift whole display 5 chars left
	FOR_X 0, UP_TO, 5
		LDA #%00011000
		JSR SEND_DISPLAY_COMMAND
	NEXT_X
	; write locomotive
	; Set cursor to 1 line 0 char
	LDA #%11000000
	JSR SEND_DISPLAY_COMMAND
	FOR_Y 0, UP_TO, 6
		TYA
		JSR PRINT_CHAR
	NEXT_Y

	LDA #16+5
	STA POSITION

THE_SAME_POS:
	WRITE_WORD CHARACTERS, FRAME_CHAR_START
	
	; Printing frame
	FOR_X 0, UP_TO, 6

		CASE X_REG
			CASE_OF #$0
				; write steam
				; Set cursor to 0 line 3 char
				LDA #%10000011
				JSR SEND_DISPLAY_COMMAND
				LDA #$6
				JSR PRINT_CHAR
				LDA #$7
				JSR PRINT_CHAR
				LDA #" "
				JSR PRINT_CHAR
			END_OF
			CASE_OF #$4
				; write steam
				; Set cursor to 0 line 3 char
				LDA #%10000011
				JSR SEND_DISPLAY_COMMAND
				LDA #" "
				JSR PRINT_CHAR
				LDA #$6
				JSR PRINT_CHAR
				LDA #$7
				JSR PRINT_CHAR
			END_OF
		END_CASE

		FOR_Y 0, UP_TO, 8*8
			TYA
			ORA #%01000000
			JSR SEND_DISPLAY_COMMAND
			LDA (FRAME_CHAR_START),Y
			JSR PRINT_CHAR
		NEXT_Y

		FOR_Y 0, UP_TO, 6
			JSR delay_10
		NEXT_Y

		CLC
		LDA FRAME_CHAR_START
		ADC #8*8
		STA FRAME_CHAR_START
		LDA FRAME_CHAR_START+1
		ADC #0
		STA FRAME_CHAR_START+1
	
	NEXT_X

	; Move whole display to right
	LDA #%00011100
	JSR SEND_DISPLAY_COMMAND

	DEC POSITION
	BNE THE_SAME_POS

	JMP S_L_LOOP
    
CHARACTERS:
; Frame #0
; Char 0
    DC %00000
	DC %00000
	DC %10000
	DC %11111
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 1
	DC %00000
	DC %00000
	DC %00010
	DC %11111
	DC %11111
	DC %11110
	DC %10100
	DC %01000
; Char 2
	DC %11111
	DC %01001
	DC %01001
	DC %01001
	DC %01111
	DC %11111
	DC %01010
	DC %00100
; Char 3
	DC %00000
	DC %00100
	DC %01110
	DC %11111
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 4
	DC %11110
	DC %01100
	DC %01100
	DC %11110
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 5
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
; Char 6
	DC %01010
	DC %10101
	DC %01001
	DC %10110
	DC %00100
	DC %11010
	DC %00001
	DC %00000
; Char 7
	DC %00000
	DC %10000
	DC %00000
	DC %01000
	DC %10000
	DC %01000
	DC %10100
	DC %01100
; Frame #1
; Char 0
	DC %00000
	DC %00000
	DC %01000
	DC %01111
	DC %01111
	DC %01111
	DC %00101
	DC %00010
; Char 1
	DC %00000
	DC %00000
	DC %00001
	DC %11111
	DC %11111
	DC %11111
	DC %01010
	DC %00100
; Char 2
	DC %01111
	DC %00100
	DC %00100
	DC %00100
	DC %10111
	DC %11111
	DC %00101
	DC %00010
; Char 3
	DC %00000
	DC %00010
	DC %00111
	DC %11111
	DC %11111
	DC %11111
	DC %00101
	DC %00010
; Char 4
	DC %01111
	DC %00110
	DC %00110
	DC %11111
	DC %11111
	DC %11111
	DC %00101
	DC %00010
; Char 5
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
; Char 6
	DC %01011
	DC %00110
	DC %00011
	DC %01010
	DC %00101
	DC %00010
	DC %00001
	DC %00000
; Char 7
	DC %00000
	DC %10000
	DC %01000
	DC %11000
	DC %01100
	DC %10010
	DC %01100
	DC %10100
; Frame #2
; Char 0
	DC %00000
	DC %00000
	DC %00100
	DC %00111
	DC %00111
	DC %00111
	DC %00010
	DC %00001
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %00101
	DC %00010
; Char 2
	DC %00111
	DC %00010
	DC %00010
	DC %10010
	DC %11011
	DC %01111
	DC %00010
	DC %00001
; Char 3
	DC %10000
	DC %10001
	DC %10011
	DC %11111
	DC %11111
	DC %11111
	DC %00010
	DC %00001
; Char 4
	DC %00111
	DC %00011
	DC %00011
	DC %11111
	DC %11111
	DC %11111
	DC %00010
	DC %00001
; Char 5
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %10000
	DC %10000
	DC %00000
	DC %00000
; Char 6
	DC %00001
	DC %00011
	DC %00000
	DC %00010
	DC %00001
	DC %00001
	DC %00000
	DC %00000
; Char 7
	DC %01000
	DC %10100
	DC %10010
	DC %01100
	DC %10000
	DC %01010
	DC %10110
	DC %01101
; Frame #3
; Char 0
	DC %00000
	DC %00000
	DC %00010
	DC %00011
	DC %00011
	DC %00011
	DC %00001
	DC %00000
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %10010
	DC %00001
; Char 2
	DC %00011
	DC %00001
	DC %10001
	DC %11001
	DC %11101
	DC %10111
	DC %00001
	DC %00000
; Char 3
	DC %11000
	DC %01000
	DC %01001
	DC %01111
	DC %11111
	DC %11111
	DC %10001
	DC %00000
; Char 4
	DC %00011
	DC %00001
	DC %10001
	DC %11111
	DC %11111
	DC %11111
	DC %10001
	DC %00000
; Char 5
	DC %10000
	DC %00000
	DC %00000
	DC %10000
	DC %11000
	DC %11000
	DC %10000
	DC %00000
; Char 6
	DC %00001
	DC %00000
	DC %00001
	DC %00001
	DC %00000
	DC %00001
	DC %00000
	DC %00000
; Char 7
	DC %01000
	DC %11100
	DC %11010
	DC %01100
	DC %10011
	DC %01100
	DC %00011
	DC %00001
; Frame #4
; Char 0
	DC %00000
	DC %00000
	DC %00001
	DC %00001
	DC %00001
	DC %00001
	DC %00000
	DC %00000
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %01001
	DC %10000
; Char 2
	DC %00001
	DC %00000
	DC %01000
	DC %11100
	DC %11110
	DC %11011
	DC %10000
	DC %00000
; Char 3
	DC %11100
	DC %00100
	DC %00100
	DC %00111
	DC %11111
	DC %11111
	DC %01000
	DC %10000
; Char 4
	DC %00001
	DC %10000
	DC %11000
	DC %11111
	DC %11111
	DC %11111
	DC %01000
	DC %10000
; Char 5
	DC %11000
	DC %10000
	DC %10000
	DC %11000
	DC %11100
	DC %11100
	DC %01000
	DC %10000
; Char 6
	DC %10100
	DC %01011
	DC %10101
	DC %01110
	DC %11101
	DC %10110
	DC %00101
	DC %00010
; Char 7
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %10000
	DC %10000
	DC %10000
; Frame #5
; Char 0
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
	DC %00000
; Char 1
	DC %00000
	DC %00000
	DC %00000
	DC %11111
	DC %11111
	DC %11111
	DC %10100
	DC %01000
; Char 2
	DC %00000
	DC %00000
	DC %00100
	DC %11110
	DC %11111
	DC %11101
	DC %01000
	DC %10000
; Char 3
	DC %11110
	DC %10010
	DC %10010
	DC %10011
	DC %11111
	DC %11111
	DC %10100
	DC %01000
; Char 4
	DC %00000
	DC %01000
	DC %11100
	DC %11111
	DC %11111
	DC %11111
	DC %10100
	DC %01000
; Char 5
	DC %11100
	DC %11000
	DC %11000
	DC %11100
	DC %11110
	DC %11110
	DC %10100
	DC %01000
; Char 6
	DC %10100
	DC %11101
	DC %01011
	DC %11101
	DC %10001
	DC %01010
	DC %00001
	DC %00000
; Char 7
	DC %00000
	DC %10000
	DC %00000
	DC %10000
	DC %00000
	DC %10000
	DC %11000
	DC %01000


;-------------------------------------------------------------------------
;  Vector area
;-------------------------------------------------------------------------

;                 .DA     $0000          ; Unused, what a pity
; NMI_VEC         .DA     $0F00          ; NMI vector
; RESET_VEC       .DA     RESET          ; RESET vector
; IRQ_VEC         .DA     $0000          ; IRQ vector

;-------------------------------------------------------------------------

                ; .LI     OFF