# Rebelstar Raiders - game source code

Source code for the 1984 ZX Spectrum game _Rebelstar Raiders_, developed by
Red Shift using Sinclair BASIC, with a few small Z80 assembly routines
for dealing with graphics and sound.

[These source files](https://github.com/mrcook/rebelstar-raiders-BASIC)
have been extracted from the original TZX tape files using the `tzxcat` Python
tool, along with a custom script written in the Go language (found in the
[extract-go](https://github.com/mrcook/rebelstar-raiders-BASIC/tree/master/extract-go)
directory), used to format the data and add various comments.


## The Game

_Rebelstar Raiders_ is a two player tactical combat game with three separate
scenarios. Each player controls between twenty and thirty characters with
individual names and characteristics, and armed with various weapons. Each
scenario should take between an hour and two hours to play.

The game manual can be found in the
[docs](https://github.com/mrcook/rebelstar-raiders-BASIC/blob/master/docs)
directory.


## `extract-go` Usage

If you wish to extract the game programs/data from your own set of TZX tape
files, you'll need to have the Go and Python languages installed on your
computer, along with the Python [tzxtools](https://github.com/shred/tzxtools).

Then from the Terminal/Console, run the following command from the same
directory where this `README` is located:

```bash
go run extract-go/main.go
```

_Note: the location of the `tzxcat` command needs to be specified in your `$PATH`_


## Copyright Information

Rebelstar Raiders, Copyright RED SHIFT Ltd., 1984. This copyright covers all elements of the game including Visual, Audio and Program.

`extract-go` and additional material, Copyright © 2023 Michael R. Cook, licensed under the terms of the [MIT license](https://opensource.org/licenses/MIT).
