#!/bin/bash

# Assumes we already are checked out by repotool

set -e

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
COCKATOODIR="$(realpath "$THISDIR/../../../")"
BUILDDIR="$COCKATOODIR/build/conf"

mkdir -p "$BUILDDIR"

pushd "$THISDIR/conf/"
cp  local.conf bblayers.conf "$BUILDDIR"
popd

source "$COCKATOODIR/upstream/poky/oe-init-build-env" "$COCKATOODIR/build"


bitbake core-image-minimal
