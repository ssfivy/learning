#!/bin/bash

# Run the container for building buildroot, with automounting this repository

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")
TOPDIR=$(realpath "$THIS_SCRIPT_DIR/../../")

cd "$THIS_SCRIPT_DIR"

# FIXME: Will always rebuild image
docker build --tag buildroot:runsh .

# Warning: Beware of uid/gid / permission errors since this is building through bind mount!
# Gitlab CI will check out the repo so it will not use bind mounts

# Warning #2: gitlab CI shared runners may change, so caching may be useless
# and we definitely do not want to redownload everything at build time.
docker run \
    --name buildroot-runsh \
    --mount "type=bind,src=$TOPDIR,target=/mnt" \
    -it \
    buildroot:runsh \
    /mnt/buildroot/stm32mp1/bootlin/autobuild.sh
