#!/bin/bash

# Install dependencies for this test

set -xe

NGINX_VERSION=1.17.9
UPLOAD_MODULE_VERSION=2.3.0

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
TOPDIR=$THIS_SCRIPT_DIR/lrn_build
BUILDDIR=$TOPDIR/build
PREFIXDIR_NGINX=$TOPDIR/prefix_nginx
RUNTIMEDIR_PROFILER=$TOPDIR/profiler

mkdir -p $BUILDDIR $PREFIXDIR_NGINX $RUNTIMEDIR_PROFILER

# SOme useful links:
# https://raychen.net/blog/2013/08/16/nginx_upload_module.html
# https://serverfault.com/questions/227480/installing-optional-nginx-modules-with-apt-get

# nginx upload module needs to be included at compile time so we have to compile our custom variant ourselves
# Too bad it's not in nginx-extras: https://askubuntu.com/questions/553937/what-is-the-difference-between-the-core-full-extras-and-light-packages-for-ngi

install_tools () {
    echo "TODO: uncomment sources in /etc/apt/sources.list"
    sudo apt-get update

    # Install build dependencies for everything in nginx-extras (the most extensive nginx package available)
    sudo apt-get build-dep nginx-extras
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential
}

#install_tools

# NGINX BUILD
###################
build_nginx () {
    pushd $BUILDDIR
    # get nginx upload module
    UPLOAD_MODULE_EXTRACTED_DIRNAME=nginx-upload-module-${UPLOAD_MODULE_VERSION}
    rm -rf $UPLOAD_MODULE_EXTRACTED_DIRNAME
    wget -c https://github.com/fdintino/nginx-upload-module/archive/${UPLOAD_MODULE_VERSION}.tar.gz
    tar zxf ${UPLOAD_MODULE_VERSION}.tar.gz

    # get main nginx
    NGINX_EXTRACTED_DIRNAME=nginx-${NGINX_VERSION}
    rm -rf $NGINX_EXTRACTED_DIRNAME
    wget -c https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
    tar zxf nginx-${NGINX_VERSION}.tar.gz

    cd $NGINX_EXTRACTED_DIRNAME

    # compile custom nginx
    ./configure \
        --prefix=${PREFIXDIR_NGINX} \
        --sbin-path=${PREFIXDIR_NGINX}/nginx.bin \
        --conf-path=${PREFIXDIR_NGINX}/nginx.conf \
        --pid-path=${PREFIXDIR_NGINX}/nginx.pid \
        --with-http_ssl_module \
        --with-stream \
        --add-module=${BUILDDIR}/$UPLOAD_MODULE_EXTRACTED_DIRNAME \
        --user=$(whoami) \
        --group=$(whoami)

    make "-j$(nproc)"
    # should not need sudo, since this should install in our test directory structure
    make install
    popd
}

build_nginx

# EOF
