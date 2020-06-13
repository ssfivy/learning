#!/bin/bash

# Basically the same as the other setup script but is completely automatic

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDDIR=$(realpath "$THIS_SCRIPT_DIR/build")
BUILDROOTDIR=$(realpath "$THIS_SCRIPT_DIR/buildroot")
DLDIR=$(realpath "$THIS_SCRIPT_DIR/dl")
CONFIGFILE=$(realpath "$THIS_SCRIPT_DIR/dotconfig")

# if we havent been configured before, use the defconfig for DK2
if [ ! -f "$CONFIGFILE" ]; then
    echo "No saved configuration found, aborting"
    exit 1
fi

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

# Put our saved configfile into build dir
cp "$CONFIGFILE" .config

# perform build
time make O="$PWD" -C "$BUILDROOTDIR"
popd


#EOF
