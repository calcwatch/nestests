.struct MMC5
; TODO: Add sound registers ($5000 - $5015)
                       .org $5100
PRG_MODE               .byte
CHR_MODE               .byte
PRG_RAM_PROTECT_1      .byte
PRG_RAM_PROTECT_2      .byte
EXTENDED_RAM_MODE      .byte
NAMETABLE_MAPPING      .byte
FILL_MODE_TILE         .byte
FILL_MODE_COLOR        .byte
                       .org $5113
PRG_BANKSWITCHING_6XXX .byte
PRG_BANKSWITCHING_8XXX .byte
PRG_BANKSWITCHING_AXXX .byte
PRG_BANKSWITCHING_CXXX .byte
PRG_BANKSWITCHING_EXXX .byte
                       .org $5120
CHR_BANKSWITCHING_00XX .byte
CHR_BANKSWITCHING_04XX .byte
CHR_BANKSWITCHING_08XX .byte
CHR_BANKSWITCHING_0CXX .byte
CHR_BANKSWITCHING_10XX .byte
CHR_BANKSWITCHING_14XX .byte
CHR_BANKSWITCHING_18XX .byte
CHR_BANKSWITCHING_1CXX .byte
; I could use a more concise name for these...
CHR_BANKSWITCHING_00XX_AND_10XX .byte
CHR_BANKSWITCHING_04XX_AND_14XX .byte
CHR_BANKSWITCHING_08XX_AND_18XX .byte
CHR_BANKSWITCHING_0CXX_AND_1CXX .byte
                       .org $5130
UPPER_CHR_BANK_BITS    .byte
                       .org $5200
VERTICAL_SPLIT_MODE    .byte
VERTICAL_SPLIT_SCROLL  .byte
VERTICAL_SPLIT_BANK    .byte
IRQ_SCANLINE_COMPARE   .byte
SCANLINE_IRQ_STATUS    .byte
.struct Multiplier
    .union
        .org $5205
        .struct Factors
            .org $5205
            MULTIPLICAND .byte
            MULTIPLIER   .byte
        .endstruct
        PRODUCT        .word
    .endunion
.endstruct
.endstruct
