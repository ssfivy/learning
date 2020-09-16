#!/bin/bash

# Assumes we already are checked out by repotool

set -e

UPSTREAM="upstream"

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
COCKATOODIR="$(realpath "$THISDIR/../../../")"
BUILDDIR="$COCKATOODIR/build/conf"

mkdir -p "$BUILDDIR"
pushd "$THISDIR/conf/"
cp  local.conf bblayers.conf "$BUILDDIR"
popd

source "$COCKATOODIR/$UPSTREAM/poky/oe-init-build-env" "$COCKATOODIR/build/$UPSTREAM"

#bitbake -e

bitbake -k core-image-full-cmdline
