# nestests

This is a repository for NES test ROMs. At the moment, it just contains a test of the Family BASIC keyboard.

You can build it yourself, or [download one of the releases](https://github.com/calcwatch/nestests/releases).

## How to Build
First, make sure you have `make` set up on your machine, and that you have the `cc65` package installed in your default path. You can get cc65 [here](https://cc65.github.io/). The project requires its assembler (`ca65`) and linker (`ld65`).

Then simply run `make` from the root directory. It will create a `rom/` subdirectory and put the ROM there.
