#!/bin/bash

# top-level control script to do all operations automatically

RECOMPILE="false"
# uncomment this to recompile all binaries
#RECOMPILE="true"

REBUILD_FROM_SCRATCH="false"
# uncomment this to rebuild everything from scratch. Implies RECOMPILE="true"
#REBUILD_FROM_SCRATCH="true"
if [[ "$REBUILD_FROM_SCRATCH" == "true" ]]; then RECOMPILE="true"; fi

export RECOMPILE
export REBUILD_FROM_SCRATCH

set -eu
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Chapter 4
time "$THISDIR/build_lfs_0.sh"

# Chapter 5 and 6
time sudo --preserve-env=RECOMPILE,REBUILD_FROM_SCRATCH -u lfs --login "$THISDIR/build_lfs_1.sh"

# This TBD
# Chapter 7
# time sudo --preserve-env=RECOMPILE,REBUILD_FROM_SCRATCH  --login "$THISDIR/build_lfs_2.sh"
