; TODO: Assign variables to in-between registers
.struct APU
              .org $4000
              .res $10
IRQ_ENABLE    .byte
              .res $6
FRAME_COUNTER .byte
.endstruct

.struct PPU
        .org $2000
CTRL    .byte
MASK    .byte
STATUS  .byte
OAMADDR .byte
OAMDATA .byte
SCROLL  .byte
ADDR    .byte
DATA    .byte
.endstruct

PALETTE_RAM_START = $3F00
PALETTE_RAM_END = $3F20
PALETTE_RAM_SIZE = PALETTE_RAM_END - PALETTE_RAM_START

SCREEN_WIDTH = $20

; Prepares PPU::DATA register for writes, starting at the supplied address
.macro set_ppu_addr addr
    lda #(>addr)
    sta PPU::ADDR
    lda #(<addr)
    sta PPU::ADDR
.endmacro

; Sets the PPU up to write to the nametable at the specified column and row
.macro move_cursor col, row
    set_ppu_addr (NAMETABLE_START + (SCREEN_WIDTH * row) + col)
.endmacro

