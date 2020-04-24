#!/bin/bash

# Clean a repository absolutely thoroughly
# Source: https://stackoverflow.com/questions/61212/how-to-remove-local-untracked-files-from-the-current-git-working-tree

set -xe

# git clean only works in repository root so we change to root
cd "$(git rev-parse --show-toplevel)"

# Clean all untracked and ignored files
# use option -f twice to remove cases where one of the subdirectories is also a git repository
git clean -f -f -d -x

# Also return repository to pristine state
git reset --hard
