# tpm2 emulation VM

This sets up a VM containing a tpm2 emulator,
so you can play with clevis, tpm2-tools and friends.

## Setting up tpm2 stuff

Use the shell scripts in this dir

References (Oudated so be careful):
- https://blog.hansenpartnership.com/tpm2-and-linux/
- https://github.com/tpm2-software/tpm2-tools/wiki/Getting-Started
- https://wiki.ubuntu.com/TPM/Testing

## Clevis tpm2
Unfortunately it looks like Clevis is hardcoded to use in-kernel resource manager only (e.g. /dev/tpm*). Apparently this is because they need to be able to run in early boot / initramfs.

I don't know if this means the clevis developers all work with tpm2 enabled hardware or if there is a way to emulate in-kernel tpm that I have not discovered yet.

Reference: https://github.com/latchset/clevis/issues/123

## Guest additions
The ubuntu image from vagrant does not come with guest additions installed (wut).

To install it, an easy way is to use the plugin:

`vagrant plugin install vagrant-vbguest`

then simply do

`vagrant up`

or if you already have an image:

`vagrant vbguest`

Simple!
