#!/bin/bash

# Based on LFS 10 systemd edition
# Fourth part - this is run inside the chrooted system

set -eu
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo Should be inside the chrooted location. Lets continue lfs!
echo "I am $(whoami), currently at $(pwd)"

# we are root (uid0) but cannot check that we are root since /etc/passwd dont exist
# so whoami doesnt work. Eh lets just continue.

# Disable hashing. Really important to make sure we can pick up new tools!
set +h

create_dirs () {
    # Chapter 7.5 - creating directories
    mkdir -pv /{boot,home,mnt,opt,srv}
    mkdir -pv /etc/{opt,sysconfig}
    mkdir -pv /lib/firmware
    mkdir -pv /media/{floppy,cdrom}
    mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
    mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
    mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
    mkdir -pv /usr/{,local/}share/man/man{1..8}
    mkdir -pv /var/{cache,local,log,mail,opt,spool}
    mkdir -pv /var/lib/{color,misc,locate}

    ln -sfv /run /var/run
    ln -sfv /run/lock /var/lock

    install -dv -m 0750 /root
    install -dv -m 1777 /tmp /var/tmp
}
#create_dirs

create_files_symlinks () {
    # Chapter 7.6 - Create essential files and symlinks
    ln -sv /proc/self/mounts /etc/mtab
    echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
    cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false
systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
systemd-network:x:76:76:systemd Network Management:/:/bin/false
systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
cat > /etc/group << "EOF"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
systemd-journal:x:23:
input:x:24:
mail:x:34:
kvm:x:61:
systemd-bus-proxy:x:72:
systemd-journal-gateway:x:73:
systemd-journal-remote:x:74:
systemd-journal-upload:x:75:
systemd-network:x:76:
systemd-resolve:x:77:
systemd-timesync:x:78:
systemd-coredump:x:79:
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF
    echo "tester:x:$(ls -n $(tty) | cut -d" " -f3):101::/home/tester:/bin/bash" >> /etc/passwd
    echo "tester:x:101:" >> /etc/group
    install -o tester -d /home/tester
    # Do this if you want the bash prmopt to look nice in interactive mode
    # We are in batch mode so no need to do this since it complicates scripting
    #exec /bin/bash --login +h
    touch /var/log/{btmp,lastlog,faillog,wtmp}
    chgrp -v utmp /var/log/lastlog
    chmod -v 664  /var/log/lastlog
    chmod -v 600  /var/log/btmp
}
#create_files_symlinks


# TODO: we prrrobably dont want this under tmp since we arent supposed to have created tmp now?
# maybe create it as tmp2?
# must match previous location in build_lfs_1.sh
LFSBUILD1="/tmp/build1"
mkdir -p "$LFSBUILD1"
cd "$LFSBUILD1"

build_libstdcpp2 () {
    # source code of this is part of gcc
    pushd "gcc-10.2.0"
    ln -s gthr-posix.h libgcc/gthr-default.h
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ../libstdc++-v3/configure            \
        CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
        --prefix=/usr                    \
        --disable-multilib               \
        --disable-nls                    \
        --host=$(uname -m)-lfs-linux-gnu \
        --disable-libstdcxx-pch
            make && make install
         }
    popd
}
#build_libstdcpp2

build_gettext() {
    tar xvf /sources/gettext-0.21.tar.xz
    pushd "gettext-0.21"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
            ./configure --disable-shared
            make
            cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
         }
    popd
}
#build_gettext

build_bison () {
    tar xvf /sources/bison-3.7.1.tar.xz
    pushd "bison-3.7.1"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
    ./configure --prefix=/usr \
            --docdir=/usr/share/doc/bison-3.7.1
            make && make install
         }
    popd
}
#build_bison

build_perl () {
    tar xvf /sources/perl-5.32.0.tar.xz
    pushd "perl-5.32.0"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        sh Configure -des                                        \
             -Dprefix=/usr                               \
             -Dvendorprefix=/usr                         \
             -Dprivlib=/usr/lib/perl5/5.32/core_perl     \
             -Darchlib=/usr/lib/perl5/5.32/core_perl     \
             -Dsitelib=/usr/lib/perl5/5.32/site_perl     \
             -Dsitearch=/usr/lib/perl5/5.32/site_perl    \
             -Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
             -Dvendorarch=/usr/lib/perl5/5.32/vendor_perl
            make && make install
         }
    popd
}
#build_perl

build_python() {
    tar xvf /sources/Python-3.8.5.tar.xz
    pushd "Python-3.8.5"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        ./configure --prefix=/usr   \
            --enable-shared \
            --without-ensurepip
            make && make install
         }
    popd
}
#build_python

build_texinfo () {
    tar xvf /sources/texinfo-6.7.tar.xz
    pushd "texinfo-6.7"
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        ./configure --prefix=/usr
            make && make install
         }
    popd
}
#build_texinfo

build_util-linux() {
    tar xvf /sources/util-linux-2.36.tar.xz
    pushd "util-linux-2.36"
    mkdir -pv /var/lib/hwclock
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    time {
        ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
            --docdir=/usr/share/doc/util-linux-2.36 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python
            make && make install
         }
    popd
}
#build_util-linux

cleanup () {
    # Section 7.14 - cleanup
    find /usr/{lib,libexec} -name \*.la -delete
    rm -rf /usr/share/{info,man,doc}/*
}
#cleanup





build_() {
    tar xvf /sources/.tar.xz
    pushd ""
    export MAKEFLAGS='-j' # Use ALL THE CORES to compile
    # Create empty build dir
    rm -rf build; mkdir -v build; cd build
    time {
            make && make install
         }
    popd
}
#build_

#EOF
