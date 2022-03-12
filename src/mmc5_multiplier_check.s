.include "common.inc"
.include "mmc5.inc"

NAMETABLE_START = $2000
NAMETABLE_END = $2400
NAMETABLE_SIZE = NAMETABLE_END - NAMETABLE_START

; Writes the zero-terminated ASCII string at the specified address to the
; nametable
.macro write_string addr
    lda #(<addr)
    sta puts_string_pointer
    lda #(>addr)
    sta puts_string_pointer + 1
    jsr puts
.endmacro

.macro lower_nibble_to_hex
    and #$0f
    ora #$30
    cmp #$3a
    bcc :+
    adc #$06
:
.endmacro

.macro upper_nibble_to_hex
    lsr
    lsr 
    lsr
    lsr
    lower_nibble_to_hex
.endmacro

.macro print_hex_byte
    sta hex_temp
    upper_nibble_to_hex
    sta PPU::DATA
    lda hex_temp
    lower_nibble_to_hex    
    sta PPU::DATA
.endmacro

.segment "ZEROPAGE"

soft_ppu_mask:
    .res 1
puts_string_pointer:
    .res 2
sum:
    .res 2
product:
    .res 2
hex_temp:
    .res 1
started_test_loop:
    .res 1
test_result:
    .res 1

.segment "RAM"

.segment "PRGRAM"

.segment "RODATA"

title_string:
    .asciiz "MMC5 Multiplier Test"
copyright_string:
    .asciiz .sprintf("%c 2022 Richard Calvi", $1b)
placeholder_equation:
    .asciiz "$__ * $__ = $____"
expected_result:
    .asciiz "(Expected:  $____)"

palette_data:
.repeat 8
    .byte $0f,$0f,$00,$3A
.endrep

.segment "CODE"

puts:
    ldy #$00
@print_loop:
    lda (puts_string_pointer), y
    beq @done_printing
    sta PPU::DATA
    iny
    bne @print_loop ; should branch always, unless we hit 256 chars
@done_printing:
    rts

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

    ; enable 4 8kB banks
    lda #$03
    sta $5100

    ; enable 2 4kB CHR page
    lda #$01
    sta $5101

    ; point all PPU nametable pages to VRAM page 0
    lda #$00
    sta $5105

    ; select bank 0 for tiles
    lda #$00
    STA $5123

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

    move_cursor 6, 3
    write_string title_string

    move_cursor 6, 5
    write_string copyright_string

    move_cursor 7, 9
    write_string placeholder_equation

    move_cursor 7, 11
    write_string expected_result


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

    jsr multiplier_test

infinite_loop:
    jmp infinite_loop

multiplier_test:
    lda #$01
    sta started_test_loop

    ldx #$00
    ldy #$00

multiplicand_loop:
    lda #$00
    sta sum
    sta sum+1
multiplier_loop:
    stx MMC5::Multiplier::Factors::MULTIPLICAND
    sty MMC5::Multiplier::Factors::MULTIPLIER

    lda MMC5::Multiplier::PRODUCT
    sta product
    lda MMC5::Multiplier::PRODUCT+1
    sta product+1

    lda sum
    cmp product
    bne test_failed

    lda sum+1
    cmp product+1
    bne test_failed

    ; Increment sum by x
    txa
    clc
    adc sum
    sta sum
    lda #$00
    adc sum+1
    sta sum+1

    iny
    bne multiplier_loop

    inx
    bne multiplicand_loop

    ; Tests passed; display final result where x and y are $ff
    dey
    dex

    ; We know that product and sum always match by this point
    lda product
    sta sum
    lda product+1
    sta sum+1

    bne done

test_failed:
    lda #$AB
    sta test_result
done:
    
    rts

nmi:
    pha                             ; save A
    txa                             ; copy X
    pha                             ; save X
    tya                             ; copy Y
    pha                             ; save Y

    lda soft_ppu_mask
    sta PPU::MASK

    lda started_test_loop
    bne print_numbers

    jmp done_printing_numbers

print_numbers:

    move_cursor 8, 9
    txa
    print_hex_byte

    move_cursor 14, 9
    tya
    print_hex_byte

    move_cursor 20, 9
    lda product+1
    print_hex_byte
    lda product
    print_hex_byte

    move_cursor 20, 11
    lda sum+1
    print_hex_byte
    lda sum
    print_hex_byte

done_printing_numbers:
    lda #$00
    sta PPU::SCROLL    ; Set x & y scroll positions to 0
    sta PPU::SCROLL

    pla                             ; pull Y
    tay                             ; restore Y
    pla                             ; pull X
    tax                             ; restore X
    pla                             ; restore A
    rti


irq:
    rti

.segment "VECTORS"

.addr nmi
.addr reset
.addr irq
