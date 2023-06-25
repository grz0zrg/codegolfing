# graphics codegolfing

All my 64, 128, 256, 512 bytes sizecoding intros / procedural graphics with sources.

Technical details for each of them : [link](https://www.onirom.fr/wiki/codegolf/main/)

Pouet : [link](https://www.pouet.net/groups.php?which=15005)

Website : [link](https://www.onirom.fr/sizecoding.html)

There may be differences in binary size with the party release (especially Linux ones) because i probably tinkered with the source later on... but they should all produce the same result.

## LINUX

All C intros are mostly based on my [tinycelfgraphics](https://github.com/grz0zrg/tinycelfgraphics) framework, the build may be sensible due to some issues but it should works by following my [setup details](https://www.onirom.fr/wiki/blog/14-05-2023_My_linux_graphics_codegolfing_setup/).

There is probably many size optimization lacking in some of them... things i found out much later, most optimized ones are the assembly ones anyway.

The intros target 1920x1080 resolution but some of them may work with different framebuffer resolution, didn't test most of them with different resolution though.

There is some intros (Crimson, Zeta) where i don't remember them being done in assembly at all (i also have C prototype for them) but they were released at the same time as Mmrnmhrm so the final version was probably assembly.

## TIC-80

Source code is included in the cartridge.

## RISC OS

Stuff here works on RISC OS and Acorn hardware, archives contain sources, .adf and binaries for modern RISC OS and early Acorn hardware.

## Credits

[sizecoding.org](http://www.sizecoding.org/wiki/Main_Page) and all sizecoders.
