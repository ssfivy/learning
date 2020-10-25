#!/bin/bash

# Based on LFS 10 systemd edition
# Third part - this part is run with root again

set -eu
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# 2.6 - set $LFS variable
LFS="/mnt/lfs"

#2.7 - Mount lfs partition
if ! mountpoint "$LFS" ; then
    echo Run build_lfs_0.sh to mount the mountpoint!
    exit 1
fi

# 4.3 Check that we are root user
if [[ $(whoami) != "root" ]]; then
    echo "This script needs to be run as the 'root' user!"
    echo "Run this script like this to do that:"
    echo "sudo --login $THISDIR/${BASH_SOURCE[0]}"
    exit 1
fi

echo Lets continue lfs!
echo "I am $(whoami), currently at $(pwd)"

# Chapter 7 - chroot and build more tools

change_back_to_root () {
    chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
    case $(uname -m) in
      x86_64) chown -R root:root $LFS/lib64 ;;
    esac
}
change_back_to_root

prep_virtual_kernel_fs () {
    mkdir -pv $LFS/{dev,proc,sys,run}
    mknod -m 600 $LFS/dev/console c 5 1
    mknod -m 666 $LFS/dev/null c 1 3
    mount -v --bind /dev $LFS/dev
    mount -v --bind /dev/pts $LFS/dev/pts
    mount -vt proc proc $LFS/proc
    mount -vt sysfs sysfs $LFS/sys
    mount -vt tmpfs tmpfs $LFS/run
    if [ -h $LFS/dev/shm ]; then
        mkdir -pv $LFS/$(readlink $LFS/dev/shm)
    fi
}
prep_virtual_kernel_fs

enter_chroot() {
    # Since we dont want an interactive session,
    # we chroot and start the next script

    # Copy the next script(s) to the chrooted env so we can start them
    mkdir -pv "$LFS/tmp2"
    cp -v $THISDIR/* "$LFS/tmp2"


    # set term to xterm since I tend to use weird terminals
    chroot "$LFS" /usr/bin/env -i   \
    HOME=/root                  \
    TERM="xterm"                \
    PS1='(lfs chroot) \u:\w\$ ' \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin \
    RECOMPILE="$RECOMPILE" \
    /bin/bash --login +h tmp2/build_lfs_3.sh
}
enter_chroot

clean_virtual_kernel_fs () {
    # Section 7.14 - cleanup
    umount $LFS/dev{/pts,}
    umount $LFS/{sys,proc,run}
}
clean_virtual_kernel_fs



#EOF
