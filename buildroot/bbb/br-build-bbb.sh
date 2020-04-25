#!/bin/bash

# Script to build beaglebone image
# Need retesting

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDROOT=$(realpath "$THIS_SCRIPT_DIR/../buildroot")
DLDIR=$(realpath "$THIS_SCRIPT_DIR/../br_downloads")
BUILD_DIR=$(realpath "$THIS_SCRIPT_DIR/../br_build")

#CONFIG=$(realpath $1)
CONFIG=$THIS_SCRIPT_DIR/bl_cfg

if [ ! -r $CONFIG ]; then
	echo "Will not backup config file!"
fi

mkdir -p $BUILD_DIR
cd $BUILD_DIR

if [ ! -L dl ]; then
	ln -s -T $DLDIR dl
fi

cd $BUILDROOT
time make defconfig BR2_DEFCONFIG=$CONFIG O=$PWD
