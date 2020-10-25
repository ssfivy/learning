#!/bin/bash

# Based on LFS 10 systemd edition
# Second part - run this after build_lfs_0 is finished.
# This part is done as user 'lfs', so this entire script should be called with sudo.

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

# TODO: we prrrobably dont want this under tmp since we arent supposed to have created tmp now?
# maybe create it as tmp2?
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

build_m4 () {
    tar xvf $LFS/sources/m4-1.4.18.tar.xz
    pushd "m4-1.4.18"
    sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
    echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess) && \
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_m4

build_ncurses () {
    tar xvf $LFS/sources/ncurses-6.2.tar.gz
    pushd "ncurses-6.2"
    sed -i s/mawk// configure
    # build 'tic' program
    rm -rf build; mkdir -v build; pushd build
        ../configure
        make -C include
        make -C progs tic
    popd
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        ./configure --prefix=/usr                \
            --host=$LFS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec
            make
            make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
            echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
            mv -v $LFS/usr/lib/libncursesw.so.6* $LFS/lib
            ln -sfv ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so
         }
    popd
}
#build_ncurses

build_bash () {
    tar xvf $LFS/sources/bash-5.0.tar.gz
    pushd "bash-5.0"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        ./configure --prefix=/usr                   \
            --build=$(support/config.guess) \
            --host=$LFS_TGT                 \
            --without-bash-malloc
            make && make DESTDIR=$LFS install
            mv $LFS/usr/bin/bash $LFS/bin/bash
            ln -sv bash $LFS/bin/sh
         }
    popd
}
#build_bash

build_coreutils () {
    tar xvf $LFS/sources/coreutils-8.32.tar.xz
    pushd "coreutils-8.32"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime
            make && make DESTDIR=$LFS install
            mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
            mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm}        $LFS/bin
            mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname}               $LFS/bin
            mv -v $LFS/usr/bin/{head,nice,sleep,touch}                    $LFS/bin
            mv -v $LFS/usr/bin/chroot                                     $LFS/usr/sbin
            mkdir -pv $LFS/usr/share/man/man8
            mv -v $LFS/usr/share/man/man1/chroot.1                        $LFS/usr/share/man/man8/chroot.8
            sed -i 's/"1"/"8"/'                                           $LFS/usr/share/man/man8/chroot.8
         }
    popd
}
#build_coreutils

build_diffutils () {
    tar xvf $LFS/sources/diffutils-3.7.tar.xz
    pushd "diffutils-3.7"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr --host=$LFS_TGT
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_diffutils

build_file () {
    tar xvf $LFS/sources/file-5.39.tar.gz
    pushd "file-5.39"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr --host=$LFS_TGT
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_file

build_findutils () {
    tar xvf $LFS/sources/findutils-4.7.0.tar.xz
    pushd "findutils-4.7.0"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr   \
                        --host=$LFS_TGT \
                        --build=$(build-aux/config.guess)
            make && make DESTDIR=$LFS install
            mv -v $LFS/usr/bin/find $LFS/bin
            sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
         }
    popd
}
#build_findutils

build_gawk () {
    tar xvf $LFS/sources/gawk-5.1.0.tar.xz
    pushd "gawk-5.1.0"
    sed -i 's/extras//' Makefile.in
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(./config.guess)
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_gawk

build_grep () {
    tar xvf $LFS/sources/grep-3.4.tar.xz
    pushd "grep-3.4"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_grep

build_gzip () {
    tar xvf $LFS/sources/gzip-1.10.tar.xz
    pushd "gzip-1.10"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr --host=$LFS_TGT
            make && make DESTDIR=$LFS install
            mv -v $LFS/usr/bin/gzip $LFS/bin
         }
    popd
}
#build_gzip

build_make () {
    tar xvf $LFS/sources/make-4.3.tar.gz
    pushd "make-4.3"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --prefix=/usr   \
            --without-guile \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_make

build_patch () {
    tar xvf $LFS/sources/patch-2.7.6.tar.xz
    pushd "patch-2.7.6"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --build=$(build-aux/config.guess)
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_patch

build_sed () {
    tar xvf $LFS/sources/sed-4.8.tar.xz
    pushd "sed-4.8"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr   \
            --host=$LFS_TGT \
            --bindir=/bin
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_sed

build_tar () {
    tar xvf $LFS/sources/tar-1.32.tar.xz
    pushd "tar-1.32"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --bindir=/bin
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_tar

build_xz () {
    tar xvf $LFS/sources/xz-5.2.5.tar.xz
    pushd "xz-5.2.5"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr                     \
            --host=$LFS_TGT                   \
            --build=$(build-aux/config.guess) \
            --disable-static                  \
            --docdir=/usr/share/doc/xz-5.2.5
            make && make DESTDIR=$LFS install
            mv -v $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat}  $LFS/bin
            mv -v $LFS/usr/lib/liblzma.so.*                       $LFS/lib
            ln -svf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so
         }
    popd
}
#build_xz

build_binutils2 () {
    # Go back to our extracted source
    pushd "binutils-2.35"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    time {
        ../configure                   \
        --prefix=/usr              \
        --build=$(../config.guess) \
        --host=$LFS_TGT            \
        --disable-nls              \
        --enable-shared            \
        --disable-werror           \
        --enable-64-bit-bfd
            make && make DESTDIR=$LFS install
         }
    popd
}
#build_binutils2

build_gcc2 () {
    # go back to our already extracted source
    pushd "gcc-10.2.0"
    rm -rf mpfr gmp mpc
    tar xvf $LFS/sources/mpfr-4.1.0.tar.xz
    tar xvf $LFS/sources/gmp-6.2.0.tar.xz
    tar xvf $LFS/sources/mpc-1.1.0.tar.gz
    mv -v mpfr-4.1.0 mpfr
    mv -v gmp-6.2.0 gmp
    mv -v mpc-1.1.0 mpc
    case $(uname -m) in
      x86_64)
        sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
      ;;
    esac
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    export MAKEFLAGS='-j6' # 12 threads uses more than 24G memory, causes threashing on my machine :(
    mkdir -pv $LFS_TGT/libgcc
    ln -s ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
    time {
            ../configure                                       \
            --build=$(../config.guess)                     \
            --host=$LFS_TGT                                \
            --prefix=/usr                                  \
            CC_FOR_TARGET=$LFS_TGT-gcc                     \
            --with-build-sysroot=$LFS                      \
            --enable-initfini-array                        \
            --disable-nls                                  \
            --disable-multilib                             \
            --disable-decimal-float                        \
            --disable-libatomic                            \
            --disable-libgomp                              \
            --disable-libquadmath                          \
            --disable-libssp                               \
            --disable-libvtv                               \
            --disable-libstdcxx                            \
            --enable-languages=c,c++
            make && make DESTDIR=$LFS install
            ln -sv gcc $LFS/usr/bin/cc
         }
    popd
}
#build_gcc2

echo Finished the user 'lfs' portion of script. Run build_lfs_2.sh to continue .

#EOF
