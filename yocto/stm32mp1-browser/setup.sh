#!/bin/bash

set -e

UPSTREAM="upstream"

THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
COCKATOODIR="$(realpath "$THISDIR/../../../")"
PROJECTNAME="$(basename "$THISDIR")"
BUILDDIR="$COCKATOODIR/build/${UPSTREAM}/${PROJECTNAME}/conf"

mkdir -p "$BUILDDIR"
pushd "$THISDIR/conf/"
cp  local.conf bblayers.conf "$BUILDDIR"
popd

# shellcheck disable=1090
source "$COCKATOODIR/$UPSTREAM/poky/oe-init-build-env" "$COCKATOODIR/build/$UPSTREAM/$PROJECTNAME"

# print bunch of debugging stuff including who set what variables
#bitbake -e

#bitbake -c cleansstate cairo
#bitbake -k cairo
bitbake -k core-image-weston
