OUT_DIRS=obj rom

$(info $(shell mkdir -p $(OUT_DIRS)))

obj/%.o: src/%.s
	ca65 $< -o $@ --debug-info

rom/keyboard_check.nes: obj/nes_header.o obj/keyboard_check.o obj/keyboard_font.o
	ld65 $^ --config src/mmc0.cfg -o $@

rom/mmc5_multiplier_check.nes: obj/nes_header.o obj/mmc5_multiplier_check.o obj/keyboard_font.o
	ld65 $^ --config src/mmc5_8kb_rom.cfg -o $@ --mapfile rom/mmc5_multiplier_check.map


all: rom/keyboard_check.nes rom/mmc5_multiplier_check.nes

clean:
	rm -rf obj/*.o rom/*.nes rom/*.map rom/*.dbg
