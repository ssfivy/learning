#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")
TOPDIR=$(realpath "$THIS_SCRIPT_DIR/../../../")
MANIFESTREPO="$TOPDIR/learning-repo"

FIXEDREV_BRANCH_NAME="buildtags"

# assume fresh repo sync
pushd "$MANIFESTREPO"

cleanrepo () {
    # Discard all changes before we start operations
    git clean -f -f -d -x
    git reset --hard
}
cleanrepo

check-branch-local () {
    # Ensure the manifest repo has a branch for storing fixed revisions
    if git show-ref --verify --quiet refs/heads/$FIXEDREV_BRANCH_NAME ; then
        : #local branch exists
    else
        # create local branch
        git branch -c $FIXEDREV_BRANCH_NAME
    fi
}
#check-branch-local

check-branch-remote () {
    #Validate remote branch too
    if git ls-remote --heads $FIXEDREV_BRANCH_NAME ; then
        : #remote branch exists
    else
        # create remote branch
        git push --set-upstream gl-ssfivy $FIXEDREV_BRANCH_NAME
    fi
}
#check-branch-remote

# Branches should be guaranteed setup at this point
git checkout $FIXEDREV_BRANCH_NAME

lock-manifest () {
    # Overwrite default.xml with our newly generated one
    rm default.xml
    repo manifest -r -o default.xml
}
#lock-manifest

push-manifest () {
    # commit and push
    git add default.xml
    COMMIT_MESSAGE="Manifest revision locked at $(date --iso-8601=seconds)"
    git commit -m "$COMMIT_MESSAGE"
    git push gl-ssfivy $FIXEDREV_BRANCH_NAME
}
#push-manifest

# Done!

#EOF
