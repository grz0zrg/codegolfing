# graphics codegolfing

All my 32, 64, 128, 256, 512 bytes sizecoding intros / procedural graphics with sources.

Technical details for each of them : [link](https://www.onirom.fr/wiki/codegolf/main/)

Pouet : [link](https://www.pouet.net/groups.php?which=15005)

Website : [link](https://www.onirom.fr/sizecoding.html)

There may be differences in binary size with the party release (especially Linux ones) because i probably tinkered with the source later on... but they should all produce the same result.

## LINUX

All C intros are mostly based on my [tinycelfgraphics](https://github.com/grz0zrg/tinycelfgraphics) framework, the build may be sensible due to some issues but it should works by following my [setup details](https://www.onirom.fr/wiki/blog/14-05-2023_My_linux_graphics_codegolfing_setup/).

There is probably many size optimization lacking in some of them... things i found out much later, most optimized ones are the assembly ones anyway.

Most of them target 1920x1080 resolution but some of them may work with different framebuffer resolution, didn't test most of them with different resolution though.

## TIC-80

Source code is included in the cartridge.

## RISC OS

Stuff here works on RISC OS and Acorn hardware, archives contain sources (see .adf), .adf and binaries for modern RISC OS and early Acorn hardware.

Some intros like ArchiSmall has hardcoded screen address so they require different binaries for different HW.

## Dreamcast

Tested in Redream but also works on real HW, see [this](https://www.onirom.fr/wiki/codegolf/dreamcast/) to build them.

## Atari ST

Tested in [Hatari](https://en.wikipedia.org/wiki/Hatari_(emulator)).

## DOS

Stuff here works on DosBox or [Bochs](https://bochs.sourceforge.io/), see [this](https://www.onirom.fr/wiki/codegolf/dos/) to run them.

## Credits

[sizecoding.org](http://www.sizecoding.org/wiki/Main_Page) and all sizecoders.
