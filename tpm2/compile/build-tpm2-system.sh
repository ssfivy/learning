#!/bin/bash
# Builds tpm2-tss and tpm2-tools from scratch
# System version, will perform sudo and install stuff globally

set -xe
TOPDIR=$(mktemp -d)     # if you want one-off directory
TOPDIR=$HOME/tpm2-build # if you want to leave artifact on disk
mkdir -p "$TOPDIR"
cd "$TOPDIR"

get_repo() {
    REPODIR="$1"
    TAG="$2"
    if [ -d "$REPODIR" ]; then
        pushd "$REPODIR"
        git checkout "$TAG"
        popd
    else
        # hopefully this doesnt barf, if it does remove the shallow clone part and it should work
        git clone --depth 1 --branch "$TAG" "https://github.com/tpm2-software/$REPODIR.git"
    fi
    pushd "$REPODIR"
    git reset --hard
    git clean -dxf
    popd
}

get_sources () {
    get_repo    tpm2-tss        "2.4.2"
    get_repo    tpm2-tools      "4.2.1"
    get_repo    tpm2-tss-engine "v1.1.0-rc1"
}

build_tpm2tss () {
    REPODIR=tpm2-tss
    pushd $REPODIR

    ./bootstrap
    ./configure --with-udevrulesdir --with-udevrulesprefix # These don't seem to work?
    make "-j$(nproc)" check
    sudo make install

    # FIXME: Is this needed?
    #sudo cp dist/tpm-udev.rules             /etc/udev/rules.d/40-tpm-udev.rules
    #sudo cp dist/sysusers.d/tpm2-tss.conf   /etc/sysusers.d/tpm2-tss.conf
    #sudo addgroup --system tss
    #ME=$(whoami); sudo -E echo $ME tss
    # do this every startup (default udev rule doesnt seem to work?)
    # sudo chgrp tss /dev/tpmrm0

    popd
    sudo ldconfig #update runtime bindings so our libs can be found
}

build_tpm2tools () {
    REPODIR=tpm2-tools
    pushd $REPODIR

    ./bootstrap
    ./configure
    make "-j$(nproc)"
    sudo make install
    popd
}

build_tpm2tssengine() {
    REPODIR=tpm2-tss-engine
    pushd $REPODIR

    ./bootstrap
    ./configure
    make "-j$(nproc)"
    sudo make install
    popd
}

get_sources
build_tpm2tss
build_tpm2tools
build_tpm2tssengine
