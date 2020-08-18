#!/bin/bash
# Builds tpm2-tss and tpm2-tools from scratch
# Playground version, should not affect your actual system install

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")
TOPDIR=$THIS_SCRIPT_DIR/lrn_build

CONFIGURE_PREFIX=$TOPDIR/usr

# These are needed so tpm2-tools build can find
# the newly compiled tpm2-tss libs
PKG_CONFIG_PATH="$CONFIGURE_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_PATH

# Bash completion dir doesnt seem to be reconfigured by specifying --prefix at configure time
# we manually configure it here for now
BASHCOMPDIR=$CONFIGURE_PREFIX/share/bash-completion/completions

mkdir -p "$TOPDIR"
cd "$TOPDIR"

get_repo() {
    REPODIR="$1"
    TAG="$2"

    # obtain sources
    if [ -d "$REPODIR" ]; then
        pushd "$REPODIR"
        git checkout "$TAG"
        popd
    else
        # dont do shallow clone, we want to be able to experiment compiling different versions
        git clone --branch "$TAG" "https://github.com/tpm2-software/$REPODIR.git"
    fi

    # purge all artifacts
    pushd "$REPODIR"
    git reset --hard
    git clean -dxf
    popd

    rm -rf "$CONFIGURE_PREFIX"
}

get_sources () {
    get_repo    tpm2-tss        "2.4.2"
    get_repo    tpm2-tools      "4.2.1"
    get_repo    tpm2-tss-engine "v1.1.0-rc1"
}

build_tpm2tss () {
    REPODIR=tpm2-tss
    pushd $REPODIR

    ./bootstrap
    ./configure "--prefix=$CONFIGURE_PREFIX"
    make "-j$(nproc)" check
    make install
    popd
}

build_tpm2tools () {
    REPODIR=tpm2-tools
    pushd $REPODIR

    ./bootstrap
    ./configure "--prefix=$CONFIGURE_PREFIX" "--with-bashcompdir=$BASHCOMPDIR"
    make "-j$(nproc)"
    make install
    popd
}

build_tpm2tssengine() {
    # Custom dir install doesnt seem to work with this one. Oh well, TBD later
    REPODIR=tpm2-tss-engine
    pushd $REPODIR

    ./bootstrap
    ./configure "--prefix=$CONFIGURE_PREFIX" "--with-bashcompdir=$BASHCOMPDIR"
    make "-j$(nproc)"
    make install
    popd
}

build_tpm2tss_withdocker () {
    REPODIR=tpm2-tss
    pushd $REPODIR

    # dockerfile does not specify customisable tag?
    # lets try a quick workaround
    sed -i 's/tpm2-tss AS/tpm2-tss:ubuntu-18.04 AS/' Dockerfile

    # docker build instructions from repo. doesnt work :(
    docker build -t tpm2 .
    docker run --name temp tpm2 /bin/true
    docker cp temp:/tmp/tpm2-tss tpm2-tss
    docker rm temp
}

#install_builddeps
get_sources
build_tpm2tss
build_tpm2tools
build_tpm2tssengine
