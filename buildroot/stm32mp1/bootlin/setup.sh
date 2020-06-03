#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDDIR=$(realpath "$THIS_SCRIPT_DIR/build")
BUILDROOTDIR=$(realpath "$THIS_SCRIPT_DIR/buildroot")
DLDIR=$(realpath "$THIS_SCRIPT_DIR/dl")
CONFIGFILE=$(realpath "$THIS_SCRIPT_DIR/dotconfig")

# Download buildroot
if [ -d "$BUILDROOTDIR" ]; then
    pushd "$BUILDROOTDIR"
    git pull
    popd
else
    git clone -b 2020.05 --depth 1 git://git.buildroot.net/buildroot
fi

# Set up clean build directory
rm -rf "$BUILDDIR"
mkdir -p "$BUILDDIR"
mkdir -p "$DLDIR"

# use out-of-tree build
pushd "$BUILDDIR"

# Initial configuration
# if we havent been configured before, use the defconfig for DK2
if [ ! -f "$CONFIGFILE" ]; then
    make O="$PWD" -C "$BUILDROOTDIR" stm32mp157c_dk2_defconfig
    cp "$BUILDROOTDIR/.config" "$CONFIGFILE"
fi

# Put our saved configfile into build dir
cp "$CONFIGFILE" .config

# Open menuconfig to do further changes
make O="$PWD" -C "$BUILDROOTDIR" menuconfig

# save our config before building
cp .config "$CONFIGFILE"

# perform build
time make O="$PWD" -C "$BUILDROOTDIR"
popd


#EOF
