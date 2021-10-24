#compilerflags

A collection of useful c compiler flags. Not in a ready-to-reuse format.

Limitations:
- gcc, not necessarily clang compatible
- need to differentiate flags by compiler version (currently tested with gcc 7.5)
- this is currently geared for building applications, not libraries (e.g. -Werror is bad in library buildscripts)

To add:
- Stuff from https://news.ycombinator.com/item?id=28927064
- -fno-delete-null-pointer-checks https://news.ycombinator.com/item?id=28928481 and https://news.ycombinator.com/item?id=17360316
- things from linux kernel makefile; search KBUILD_CFLAGS in https://github.com/torvalds/linux/blob/master/Makefile
