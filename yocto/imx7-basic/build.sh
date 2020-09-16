#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")

# Get layers
if [ -d poky ]; then
    pushd poky
    git pull
    popd
else
    git clone -b dunfell --depth 1 git://git.yoctoproject.org/poky.git
fi

if [ -d meta-freescale ]; then
    pushd meta-freescale
    git pull
    popd
else
    git clone -b dunfell --depth 1 https://github.com/Freescale/meta-freescale.git
fi

if [ -d meta-timesys ]; then
    pushd meta-timesys
    git pull
    popd
else
    git clone -b dunfell --depth 1 https://github.com/TimeSysGit/meta-timesys.git
fi

# Clean previous local.conf modifications
rm -f "$THIS_SCRIPT_DIR/build/conf/local.conf"

# Source bitbake setup script (should regenerate local.conf)
source "poky/oe-init-build-env"

# Add extra layers
bitbake-layers add-layer "$THIS_SCRIPT_DIR/meta-freescale"
bitbake-layers add-layer "$THIS_SCRIPT_DIR/meta-timesys"

# Modify local.conf
echo '' >> "$THIS_SCRIPT_DIR/build/conf/local.conf"
echo 'MACHINE = "imx7dsabresd"' >> "$THIS_SCRIPT_DIR/build/conf/local.conf"

# Uncommenting this will break build
#echo 'INHERIT += "vigiles" ' >> "$THIS_SCRIPT_DIR/build/conf/local.conf"


# Build
bitbake core-image-minimal
