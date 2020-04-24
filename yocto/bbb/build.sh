#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDDIR=$(realpath "$THIS_SCRIPT_DIR/../build")
LAYERSDIR=$(realpath "$THIS_SCRIPT_DIR/layers")
UPSTREAMDIR=$(realpath "$THIS_SCRIPT_DIR/../upstream")


# We're not aiming for 100% reproducible build here
# so I won't use my usual setup with repotools and manifest files

# Get layers
mkdir -p "$UPSTREAMDIR"
pushd "$UPSTREAMDIR"
if [ -d poky ]; then
    pushd poky
    git pull
    popd
else
    git clone -b dunfell --depth 1 git://git.yoctoproject.org/poky.git
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


# Archive of old commands

# Create new layer
#cd $LAYERSDIR
#bitbake-layers create-layer bbb-experiments
