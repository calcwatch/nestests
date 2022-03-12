# nestests

This is a repository for NES test ROMs. At the moment, it just contains:
* A test of the [Family BASIC keyboard](https://wiki.nesdev.org/w/index.php?title=Family_BASIC_Keyboard)
* A test of the [MMC5 mutliplier](https://wiki.nesdev.org/w/index.php?title=MMC5#Unsigned_8x8_to_16_Multiplier_.28.245205.2C_.245206_read.2Fwrite.29)

You can build them yourself, or [download one of the releases](https://github.com/calcwatch/nestests/releases).

## How to Build
First, make sure you have `make` set up on your machine, and that you have the `cc65` package installed in your default path. You can get cc65 [here](https://cc65.github.io/). The project requires its assembler (`ca65`) and linker (`ld65`).

Then simply run `make all` from the root directory. It will create a `rom/` subdirectory and put the ROMs there.
