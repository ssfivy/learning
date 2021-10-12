#compilerflags

A collection of useful c compiler flags. Not in a ready-to-reuse format.

Limitations:
- gcc, not necessarily clang compatible
- need to differentiate flags by compiler version (currently tested with gcc 7.5)
- this is currently geared for building applications, not libraries (e.g. -Werror is bad in library buildscripts)
