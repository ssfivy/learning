#!/bin/bash

# Script to start configuration and keeping the config files not deleted
# Need retesting

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDROOT=$(realpath "$THIS_SCRIPT_DIR/../buildroot")
DLDIR=$(realpath "$THIS_SCRIPT_DIR/../br_downloads")
BUILD_DIR=$(realpath "$THIS_SCRIPT_DIR/../br_build")
