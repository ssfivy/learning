#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")
TOPDIR=$(realpath "$THIS_SCRIPT_DIR/../../../")

# Directory where the manifest repository is checked out
# Must match the directory location specified in manifest xml file
MANIFESTREPO="$TOPDIR/learning-manifest"

# Remote name for the manifest repository
# Must match the remote name specified in manifest xml file
REMOTE_NAME="gl-ssfivy-git"

# Branch name in the repository where we will commit all the locked manifests.
FIXEDREV_BRANCH_NAME="buildtags"

# assume fresh repo sync
pushd "$MANIFESTREPO"

cleanrepo () {
    # Discard all changes before we start operations
    git clean -f -f -d -x
    git reset --hard
}
cleanrepo

check-branch-remote () {
    #Validate remote branch too
    if git ls-remote --heads $REMOTE_NAME $FIXEDREV_BRANCH_NAME ; then
        : #remote branch exists
    else
        # create remote branch
        # only works automatically if checked out via ssh
        # since our manifest is using http urls, this does not work for now.
        #git push --set-upstream "$REMOTE_NAME" $FIXEDREV_BRANCH_NAME
        echo "Please create a remote branch named '$FIXEDREV_BRANCH_NAME'"
        exit 1
    fi
}
check-branch-remote

# Branches should be guaranteed setup at this point

lock-manifest () {
    # we want to snapshot default branch
    DEFAULT_BRANCH_NAME=$(git remote show "$REMOTE_NAME" | grep "HEAD branch" | sed 's/.*: //' )
    git checkout "$DEFAULT_BRANCH_NAME"
    # Make sure you snapshot the revisions BEFORE checking out the branch with all the revision data!
    # Since the content of this branch changes everytime we make a snapshot,
    # if you dont do this you will always create a new shapshot record even though nothing else has changed.
    repo manifest -r -o new-default.xml
    # Switch to the branch where we record everything
    git checkout $FIXEDREV_BRANCH_NAME

    # Only create new commit of things change
    if cmp --quiet new-default.xml default.xml ; then
        echo "Revisions not changed, not committing"
    else
        # Overwrite default.xml with our newly generated one
        mv new-default.xml default.xml
        # File is changed, commit and push
        git add default.xml
        # timestamp in my local time
        COMMIT_MESSAGE="Manifest revision locked at $(TZ='Australia/Sydney' date --iso-8601=seconds)"
        git commit -m "$COMMIT_MESSAGE"
        git push $REMOTE_NAME $FIXEDREV_BRANCH_NAME
    fi
}
lock-manifest

# Done!

#EOF
