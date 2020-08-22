#!/bin/bash

# The way to get a variable to the directory where this file resides!

# Source: https://stackoverflow.com/a/246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $DIR

# Source: https://stackoverflow.com/a/4774063
# This one seems to derefecence symlinks
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
echo $SCRIPTPATH
