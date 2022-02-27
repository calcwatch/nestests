OUT_DIRS=obj rom

$(info $(shell mkdir -p $(OUT_DIRS)))

obj/%.o: src/%.s
	ca65 $< -o $@

rom/keyboard_check.nes: obj/nes_header.o obj/keyboard_check.o obj/keyboard_font.o
	ld65 $^ --config src/mmc0.cfg -o $@

all: rom/keyboard_diagnostics.nes

clean:
	rm -rf obj/*.o rom/*.nes
