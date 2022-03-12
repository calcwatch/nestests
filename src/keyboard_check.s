.include "common.inc"

KEYBOARD_MATRIX_ROW_COUNT = 9
KEYBOARD_MATRIX_KEY_COUNT = KEYBOARD_MATRIX_ROW_COUNT * 8

ROW_LOAD_DELAY = $0a

NAMETABLE_START = $2000
NAMETABLE_END = $2400
NAMETABLE_SIZE = NAMETABLE_END - NAMETABLE_START

.macro write_from_buffer col, row, start, end
    move_cursor col, row
    ldy #(end - start)
.scope
    @string_print_loop:
        lda screen_buffer + keyboard_row_end - end - 1, y
        sta PPU::DATA
        dey
        bne @string_print_loop
.endscope
.endmacro

; Writes the zero-terminated ASCII string at the specified address to the
; nametable
.macro write_string addr
    lda #(<addr)
    sta puts_string_pointer
    lda #(>addr)
    sta puts_string_pointer + 1
    jsr puts
.endmacro

; Produces ASCII string with bit 7 high on the last character
.macro flag_terminated_string s
    .repeat .strlen(s) - 1, i
        .byte .strat(s, i)       
    .endrep
    .byte (.strat(s, .strlen(s) - 1) | $80)
.endmacro

; Produces an ASCII string with bit 7 high for all characters.
; Used to create multiple single character "flag-terminated strings" at once
.macro consecutive_single_chars s
    .repeat .strlen(s), i
        .byte (.strat(s, i) | $80)       
    .endrep
.endmacro

.macro matrix_index row, col, bit_num
    .byte (row * 8) + (col * 4) + bit_num - 1
.endmacro

.segment "ZEROPAGE"

string_list_pointer:
    .res 2
key_scratch_space:
    .res KEYBOARD_MATRIX_ROW_COUNT
byte_to_test:
    .res 1
temp_buffer_write_byte:
    .res 1
key_checked:
    .res 1
key_hit:
    .res 1
buffer_ready:
    .res 1
puts_string_pointer:
    .res 2
puts_green_flag:
    .res 1
soft_ppu_mask:
    .res 1

.segment "RAM"

screen_buffer:
    .res $100

.segment "RODATA"

title_string:
    .asciiz "`Keyboard Support Check`"
copyright_string:
    .asciiz .sprintf("%c 2022 Richard Calvi", $1b)
pressed_key_string:
    .asciiz "* `Pressed` keys in `GREEN`."
unpressed_key_string:
    .asciiz "* Unpressed keys in GRAY."
connection_string_1:
    .asciiz "* If `ALL` keys are green,"
connection_string_2:
    .asciiz "check keyboard connection."

keyboard_strings:
keyboard_row_0:
    flag_terminated_string "F1 "
    flag_terminated_string "F2 "
    flag_terminated_string "F3 "
    flag_terminated_string "F4 "
    flag_terminated_string "F5 "
    flag_terminated_string "F6 "
    flag_terminated_string "F7 "
    flag_terminated_string "F8"
keyboard_row_1:
    consecutive_single_chars "1234567890-^"
    ; Note: (1) ca65 treats this as "backslash + space", not an escaped space
    ;       (2) \ is mapped to the Japanese yen symbol
    flag_terminated_string "\ "
    flag_terminated_string "STOP"
keyboard_row_2:
    flag_terminated_string "HOME "
    flag_terminated_string "INS "
    flag_terminated_string "DEL"
keyboard_row_3:
    flag_terminated_string "ESC "
    consecutive_single_chars "QWERTYUIOP@["
    flag_terminated_string " RETURN"
keyboard_row_4:
    flag_terminated_string .sprintf("%c",$1C)
keyboard_row_5:
    flag_terminated_string "CTR "
    consecutive_single_chars "ASDFGHJKL;:]"
    flag_terminated_string " KANA "
    flag_terminated_string .sprintf("%c ",$1F)
    flag_terminated_string .sprintf("%c",$1E)
keyboard_row_6:
    flag_terminated_string .sprintf("%c",$1D)
keyboard_row_7:
    flag_terminated_string "SHIFT "
    consecutive_single_chars "ZXCVBNM,./_"
    flag_terminated_string " SHIFT"
keyboard_row_8:
    flag_terminated_string "GRPH "
    flag_terminated_string "SPACE"
keyboard_row_end:

screen_order_to_matrix_index:
    matrix_index 7, 0, 1    ; 'F1'
    matrix_index 6, 0, 1    ; 'F2'
    matrix_index 5, 0, 1    ; 'F3'
    matrix_index 4, 0, 1    ; 'F4'
    matrix_index 3, 0, 1    ; 'F5'
    matrix_index 2, 0, 1    ; 'F6'
    matrix_index 1, 0, 1    ; 'F7'
    matrix_index 0, 0, 1    ; 'F8'
    matrix_index 7, 1, 3    ; '1'
    matrix_index 7, 1, 4    ; '2'
    matrix_index 6, 1, 4    ; '3'
    matrix_index 5, 1, 4    ; '4'
    matrix_index 5, 1, 3    ; '5'
    matrix_index 4, 1, 4    ; '6'
    matrix_index 4, 1, 3    ; '7'
    matrix_index 3, 1, 4    ; '8'
    matrix_index 3, 1, 3    ; '9'
    matrix_index 2, 1, 4    ; '0'
    matrix_index 1, 1, 3    ; '-'
    matrix_index 1, 1, 4    ; '^'
    matrix_index 0, 1, 3    ; Japanese Yen symbol
    matrix_index 0, 1, 4    ; 'STOP'
    matrix_index 8, 0, 1    ; 'HOME'
    matrix_index 8, 1, 4    ; 'INS'
    matrix_index 8, 1, 3    ; 'DEL'
    matrix_index 7, 0, 2    ; 'ESC'
    matrix_index 7, 0, 3    ; 'Q'
    matrix_index 6, 0, 2    ; 'W'
    matrix_index 6, 1, 3    ; 'E'
    matrix_index 5, 0, 3    ; 'R'
    matrix_index 5, 0, 2    ; 'T'
    matrix_index 4, 0, 2    ; 'Y'
    matrix_index 3, 0, 3    ; 'U'
    matrix_index 3, 0, 2    ; 'I'
    matrix_index 2, 0, 2    ; 'O'
    matrix_index 2, 1, 3    ; 'P'
    matrix_index 1, 0, 2    ; '@'
    matrix_index 0, 0, 3    ; '['
    matrix_index 0, 0, 2    ; 'RETURN'
    matrix_index 8, 0, 2    ; 'UP'
    matrix_index 7, 0, 4    ; 'CTR'
    matrix_index 6, 0, 4    ; 'A'
    matrix_index 6, 0, 3    ; 'S'
    matrix_index 5, 0, 4    ; 'D'
    matrix_index 5, 1, 1    ; 'F'
    matrix_index 4, 0, 3    ; 'G'
    matrix_index 4, 0, 4    ; 'H'
    matrix_index 3, 0, 4    ; 'J'
    matrix_index 2, 0, 4    ; 'K'
    matrix_index 2, 0, 3    ; 'L'
    matrix_index 1, 0, 4    ; ';'
    matrix_index 1, 0, 3    ; ':'
    matrix_index 0, 0, 4    ; ']'
    matrix_index 0, 1, 1    ; 'KANA'
    matrix_index 8, 0, 4    ; 'LEFT'
    matrix_index 8, 0, 3    ; 'RIGHT'
    matrix_index 8, 1, 1    ; 'DOWN'
    matrix_index 7, 1, 1    ; 'SHIFT' (left)
    matrix_index 6, 1, 2    ; 'Z'
    matrix_index 6, 1, 1    ; 'X'
    matrix_index 5, 1, 2    ; 'C'
    matrix_index 4, 1, 2    ; 'V'
    matrix_index 4, 1, 1    ; 'B'
    matrix_index 3, 1, 2    ; 'N'
    matrix_index 3, 1, 1    ; 'M'
    matrix_index 2, 1, 2    ; ','
    matrix_index 2, 1, 1    ; '.'
    matrix_index 1, 1, 2    ; '/'
    matrix_index 1, 1, 1    ; '_'
    matrix_index 0, 1, 2    ; 'SHIFT' (right)
    matrix_index 7, 1, 2    ; 'GRPH'
    matrix_index 8, 1, 2    ; 'SPACE'

and_bits:
    .byte $01, $02, $04, $08, $10, $20, $40, $80

palette_data:
.repeat 8
    .byte $0f,$0f,$00,$3A
.endrep

.segment "CODE"

nmi:
    pha                             ; save A
    txa                             ; copy X
    pha                             ; save X
    tya                             ; copy Y
    pha                             ; save Y

    lda soft_ppu_mask
    sta PPU::MASK

    lda buffer_ready
    bne print_from_buffer
    jmp end_of_nmi

print_from_buffer:
    ldy #$00

    ; I stamp out the string writing routine each time so that
    ; it can just _barely_ finish before the vblank ends.
    ; There's no time to call subroutines.
    write_from_buffer 2, 13, keyboard_row_0, keyboard_row_1
    write_from_buffer 3, 15, keyboard_row_1, keyboard_row_2
    write_from_buffer 17, 17, keyboard_row_2, keyboard_row_3
    write_from_buffer 2, 19, keyboard_row_3, keyboard_row_4
    write_from_buffer 27, 20, keyboard_row_4, keyboard_row_5
    write_from_buffer 4, 21, keyboard_row_5, keyboard_row_6
    write_from_buffer 27, 22, keyboard_row_6, keyboard_row_7
    write_from_buffer 2, 23, keyboard_row_7, keyboard_row_8
    write_from_buffer 7, 25, keyboard_row_8, keyboard_row_end

end_of_nmi:
    lda #$00
    sta PPU::SCROLL    ; Set x & y scroll positions to 0
    sta PPU::SCROLL

    pla                             ; pull Y
    tay                             ; restore Y
    pla                             ; pull X
    tax                             ; restore X
    pla                             ; restore A
    rti

; Not used
irq:
    rti

reset:
    sei
    cld            ; Disable binary-encoded decimal support, by convention
        
    lda #$00
    sta PPU::CTRL       ; Disable NMIs
    sta PPU::MASK       ; turn PPU off
    sta APU::IRQ_ENABLE ; Disable DMC IRQs
    lda #$C0
    sta APU::FRAME_COUNTER

    ldx #$02       ; Wait for 2 vblanks so that the PPU can warm up
@wait_for_ppu:
    bit PPU::STATUS
    bpl @wait_for_ppu
    dex
    bne @wait_for_ppu

    ldx #$FF        ; set X for stack
    txs             ; clear stack

    ; clear RAM
    lda #$00
    ldx #$00
zero_out_loop:
    sta $00, x
    sta $200, x
    STA $300, x
    sta $400, x
    sta $500, x
    sta $600, x
    sta $700, x
    inx
    bne zero_out_loop
    
    ; set so that the first inc in the NMI will make it zero
    lda #$FF
    sta key_checked

    lda PPU::STATUS   ; read PPU status to reset the high/low latch to high

    ; clear nametable
    set_ppu_addr NAMETABLE_START
    lda #' ' ; character to write
    ldy #(>NAMETABLE_SIZE) ; # of pages to write to
write_page:
    ldx #$00
write_byte:
    sta PPU::DATA
    inx
    bne write_byte
    dey
    bne write_page

    ; Write title and info text
    move_cursor 5, 3
    write_string title_string

    move_cursor 6, 5
    write_string copyright_string

    move_cursor 2, 7
    write_string pressed_key_string

    move_cursor 2, 8
    write_string unpressed_key_string

    move_cursor 2, 9
    write_string connection_string_1

    move_cursor 4, 10
    write_string connection_string_2

    ; set palettes
    set_ppu_addr PALETTE_RAM_START

    ldx #$00

palette_loop:
    lda palette_data, x
    sta PPU::DATA    ; Write palette color to PPU
    inx
    cpx #PALETTE_RAM_SIZE
    bne palette_loop

    lda #$00
    sta PPU::SCROLL    ; Set x & y scroll positions to 0
    sta PPU::SCROLL

    lda #$0E
    sta soft_ppu_mask ; Enable backgrounds on next vblank, but not sprites

    lda #$80
    sta PPU::CTRL ; Enable NMI on vblank

    cli         ; Enable the interrupts

infinite_loop:
    ldy #$00; keyboard row count

    lda #$05    ; reset code
    sta $4016   ; reset keyboard scan to row 0, column 0
key_row_scan_loop:
    lda #$04   ; "next row" code
    sta $4016  ; select column 0, next row if not just reset
    ldx #ROW_LOAD_DELAY
@wait_for_row:
    dex
    bne @wait_for_row

    lda $4017  ; read column 0 data

    ; do stuff with col 0
    LSR A; slide it to the right to knock off bit 0 (a "don't care")
    and #$0F ; knock off bits we don't care about
    sta key_scratch_space, y ; store in temp space for now

    lda #$06   ; "next column" code
    sta $4016  ; select column 1
    ldx #ROW_LOAD_DELAY
@wait_for_column:
    dex
    bne @wait_for_column

    lda $4017  ; read column 1 data

    ldx #$08    ; set the column count

    ; do stuff with col 1
    asl a
    asl a
    asl a
    and #$f0 ; knock off bits we don't care about
    ora key_scratch_space, y ; join it with the bits from col 0
    sta key_scratch_space, y
    iny

    cpy #KEYBOARD_MATRIX_ROW_COUNT
    bne key_row_scan_loop

; Screen buffer writing: It writes the buffer out backwards so that the
; print loops can decrement Y until Y==0, saving the need for an X iterator
    lda #(<keyboard_strings)
    sta string_list_pointer
    lda #(>keyboard_strings)
    sta string_list_pointer+1

    ldy #$00
string_list_loop:
    cpy #(keyboard_row_end - keyboard_strings)
    beq done_with_strings

    inc key_checked

    ldx key_checked
    lda screen_order_to_matrix_index, x
    lsr
    lsr
    lsr
    and #$1F
    tax
    lda key_scratch_space, x
    sta temp_buffer_write_byte
    ldx key_checked
    lda screen_order_to_matrix_index, x
    and #$07
    tax
    lda temp_buffer_write_byte
    and and_bits, x
    beq @set_key_hit
    lda #$00
    sta key_hit
    beq @load_string
@set_key_hit:
    lda #$80
    sta key_hit
    bne @load_string
@load_string:
    lda keyboard_strings, y
string_write_loop:
    sta temp_buffer_write_byte
    tya         ; A = Y
    eor #$FF    ; A = -Y - 1
    clc
    adc #(keyboard_row_end - keyboard_strings) ; A = buffer_length - Y - 1
    tax                                        ; X = buffer_length - Y - 1
    lda temp_buffer_write_byte
    and #$7F
    ora key_hit
    sta screen_buffer, x
    iny
    lda temp_buffer_write_byte
    bmi string_list_loop  ; byte with b7==1 means it's the last char of the string
    lda keyboard_strings, y
    bne string_write_loop ; branch always, since bytes in string list should never be 0
done_with_strings:
    lda #$FF
    sta key_checked

    lda #$01
    sta buffer_ready

    jmp infinite_loop

; This prints a null-terminated string referenced at puts_string_pointer to
; the screen. By default, the text will be gray. The "`" character is used to
; toggle green text, and will not be printed. The string must be less than 256
; characters long.
puts:
    ldy #$00
    sty puts_green_flag
@print_loop:
    lda (puts_string_pointer), y
    beq @done_printing
    cmp #'`'
    beq @toggle_green
    eor puts_green_flag
    sta PPU::DATA
    iny
    bne @print_loop ; should branch always, unless we hit 256 chars
    beq @done_printing
@toggle_green:
    lda #$80
    eor puts_green_flag
    sta puts_green_flag
    iny
    bne @print_loop ; should branch always, unless we hit 256 chars
@done_printing:
    rts

.segment "VECTORS"

.addr nmi
.addr reset
.addr irq
