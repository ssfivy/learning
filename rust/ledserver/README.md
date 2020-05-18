# ledserver

An experiment for controlling led on my raspi floral bonnet from a web API.
Basically rust learning 102.

## Prerequisites

See https://github.com/japaric/rust-cross
and https://github.com/japaric/rust-cross/issues/42

Note that raspi zero is ARMv6 among other complications so the usual armv7 stuff wont work!
Also apparently if we aren't using the official raspi-specific toolchain the soft float can cause weird crashes (booo for weird cpu architectures). Hopefully we are fine though, let's just try to write code that avoids floating point shall we?

To setup rust cross compiler:

`rustup target add arm-unknown-linux-gnueabi`

Need gnu linker installed separately:

`sudo apt-get install gcc-arm-linux-gnueabi`
