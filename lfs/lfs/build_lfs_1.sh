#!/bin/bash

# Based on LFS 10 systemd edition
# Second part - run this after build_lfs_0 is finished.

set -eu
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# 2.6 - set $LFS variable
LFS="/mnt/lfs"

#2.7 - Mount lfs partition
if ! mountpoint "$LFS" ; then
    echo Run build_lfs_0.sh to mount the mountpoint!
    exit 1
fi

# 4.3 Check that we are lfs user
if [[ $(whoami) != "lfs" ]]; then
    echo "This script needs to be run as the 'lfs' user!"
    echo "Run this script like this to do that:"
    echo "sudo -u lfs --login $THISDIR/${BASH_SOURCE[0]}"
    exit 1
fi

echo Lets continue lfs!
echo "I am $(whoami), currently at $(pwd)"

# 4.4 Set up environment
setup_env () {
# Dont use bash_profile - the exec wreaks havoc on automation.
# You should have executed this script from sudo without the '-E' flag,
# which means drop (almost) all environment variables.
#cat > ~/.bash_profile << "EOF"
#exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
#EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
export LFS LC_ALL LFS_TGT PATH
EOF
# WARNING: Do we need to remove /etc/bash.bashrc on the host system?
}
#setup_env
#source "$HOME/.bash_profile"
source "$HOME/.bashrc"


# General compilation instructions
# TODO: Check /bin/sh is bash
# TODO: Check /usr/bin/awk -> gawk
# TODO: check /usr/bin/yacc -> bison

LFSBUILD1="$LFS/tmp/build1"
mkdir -p "$LFSBUILD1"
cd "$LFSBUILD1"

build_binutils () {
    tar xvf $LFS/sources/binutils-2.35.tar.xz
    pushd "binutils-2.35"
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ../configure --prefix=$LFS/tools       \
             --with-sysroot=$LFS        \
             --target="$LFS_TGT"          \
             --disable-nls              \
             --disable-werror && \
             make && make install
         }
    popd
}
#build_binutils

build_gcc1 () {
    tar xvf $LFS/sources/gcc-10.2.0.tar.xz
    pushd "gcc-10.2.0"
    tar xvf $LFS/sources/mpfr-4.1.0.tar.xz
    tar xvf $LFS/sources/gmp-6.2.0.tar.xz
    tar xvf $LFS/sources/mpc-1.1.0.tar.gz
    mv -v mpfr-4.1.0 mpfr
    mv -v gmp-6.2.0 gmp
    mv -v mpc-1.1.0 mpc
    case $(uname -m) in
        x86_64)
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
        ;;
    esac
    # Create empty build dir
    rm -rf build; mkdir -v build; pushd build
    export MAKEFLAGS='-j6' # 12 threads uses more than 24G memory, causes threashing on my machine :(
    time {
    ../configure                                       \
        --target=$LFS_TGT                              \
        --prefix=$LFS/tools                            \
        --with-glibc-version=2.11                      \
        --with-sysroot=$LFS                            \
        --with-newlib                                  \
        --without-headers                              \
        --enable-initfini-array                        \
        --disable-nls                                  \
        --disable-shared                               \
        --disable-multilib                             \
        --disable-decimal-float                        \
        --disable-threads                              \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libquadmath                          \
        --disable-libssp                               \
        --disable-libvtv                               \
        --disable-libstdcxx                            \
        --enable-languages=c,c++ && \
             make && make install
         }

    popd
    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
        "$(dirname $($LFS_TGT-gcc -print-libgcc-file-name))"/install-tools/include/limits.h
    popd
}
#build_gcc1

build_linuxapiheaders () {
    tar xvf $LFS/sources/linux-5.8.3.tar.xz
    pushd "linux-5.8.3"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            make mrproper
            make headers
            find usr/include -name '.*' -delete
            rm usr/include/Makefile
            cp -rv usr/include $LFS/usr
         }
    popd
}
#build_linuxapiheaders

build_glibc () {
    tar xvf $LFS/sources/glibc-2.32.tar.xz
    pushd "glibc-2.32"
    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac
    patch -Np1 -i $LFS/sources/glibc-2.32-fhs-1.patch
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    export MAKEFLAGS='-j1' # book says may fail with parallel make
    time {
            ../configure                             \
              --prefix=/usr                      \
              --host=$LFS_TGT                    \
              --build=$(../scripts/config.guess) \
              --enable-kernel=3.2                \
              --with-headers=$LFS/usr/include    \
              libc_cv_slibdir=/lib && \
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_glibc

sanity_check_initial_toolchain () {
    echo 'int main(){}' > dummy.c
    $LFS_TGT-gcc dummy.c
    readelf -l a.out | grep '/ld-linux'
    rm -v dummy.c a.out
}
#sanity_check_initial_toolchain

finalize_limith () {
    $LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders
}
#finalize_limith

build_libstdcpp1 () {
    # source code of this is part of gcc
    pushd "gcc-10.2.0"
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --build=$(../config.guess)      \
        --prefix=/usr                   \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0 && \
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_libstdcpp1

# Chapter 6 - Crosscompile temporary tools





#EOF
