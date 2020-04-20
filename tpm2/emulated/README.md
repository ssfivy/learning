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


## TODO
- Use vagrant libvirt backend, or straight up qemu for its tpm2 emulation features
    - https://github.com/vagrant-libvirt/vagrant-libvirt#installation
    - Try using libvirt backend to run a VM which has tpm2 emulated from the get-go. This should make Clevis work.

[x] Add Microsoft's software tpm2 emulator: https://github.com/microsoft/ms-tpm-20-ref
[x] Add swtpm ( &libtpmms) https://github.com/stefanberger/swtpm
- Try using swtpm backend to tpm2-tss: https://github.com/tpm2-software/tpm2-tss/pull/1542

- Try performing basic crypto operations using tpm2 tools
    - initialise / reset tpm
    - encrypt / decrypt data (symmetric key)
    - encrypt / decrypt data (asymmetric key)?
    - sign / verify

- Try setting up performance evaluation code for TPM operations.
    - Perhaps use openssl engine backend and run its speedtest?

- Try adding this to CI systems

- Note: Good overview on how those softwares relate to one another: https://lwn.net/Articles/768419/

## Guest additions
The ubuntu image from vagrant does not come with guest additions installed (wut).

To install it, an easy way is to use the plugin:

`vagrant plugin install vagrant-vbguest`

then simply do

`vagrant up`

or if you already have an image:

`vagrant vbguest`

Simple!
