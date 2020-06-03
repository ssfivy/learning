#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDDIR=$(realpath "$THIS_SCRIPT_DIR/build")
LAYERSDIR=$(realpath "$THIS_SCRIPT_DIR/layers")
UPSTREAMDIR=$(realpath "$THIS_SCRIPT_DIR/upstream")

# We're not aiming for 100% reproducible build here
# so I won't use my usual setup with repotools and manifest files

#stm32mp layer is only thud at the moment, sadness

mkdir -p "$UPSTREAMDIR"
pushd "$UPSTREAMDIR"
if [ -d poky ]; then
    pushd poky
    git pull
    popd
else
    git clone -b thud-20.0.2 --depth 1 git://git.yoctoproject.org/poky.git
fi
if [ -d meta-openembedded ]; then
    pushd meta-openembedded
    git pull
    popd
else
    git clone --depth 1 -b thud git://git.openembedded.org/meta-openembedded
fi
if [ -d meta-st-stm32mp ]; then
    pushd meta-st-stm32mp
    git pull
    popd
else
    git clone --depth 1 https://github.com/STMicroelectronics/meta-st-stm32mp.git
fi
popd

# Set up build directory
mkdir -p "$BUILDDIR"
rm -rf "$BUILDDIR/conf"
cp -r "$THIS_SCRIPT_DIR/conf" "$BUILDDIR"
#pushd "$BUILDDIR"
#popd
source "$UPSTREAMDIR/poky/oe-init-build-env" "$BUILDDIR"
bitbake core-image-minimal
