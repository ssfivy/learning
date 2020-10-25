#!/bin/bash

# Based on LFS 10 systemd edition

set -eu
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
COCKATOODIR="$(realpath "$THISDIR/../../../")"

BUILDDIR="$COCKATOODIR/build_lfs"

LFSDISKFILE="$BUILDDIR/lfsdiskfile"

mkdir -p "$BUILDDIR"
cd "$BUILDDIR"

create_partition () {
# 2.4 - create partition
echo "Creating sparse file to be used as partition"
dd if=/dev/zero "of=$LFSDISKFILE" bs=1 count=0 seek=20G
du -h --apparent-size "$LFSDISKFILE" # max size file can expand to
du -h  "$LFSDISKFILE" # actual size on disk
echo "Finding first unused loop device"
LOOP_DEVICE=$(losetup -f)
echo "Attaching image file to loop device $LOOP_DEVICE"
sudo losetup "$LOOP_DEVICE" "$LFSDISKFILE"
# 2.5 - create filesystem on partition
# Not using swap to simplify things a bit - also I have humongous RAM
echo "Partitioning the loop device with ext4"
sudo mkfs.ext4 -c "$LOOP_DEVICE"
echo "Removing the loop device"
sudo losetup -d "$LOOP_DEVICE"
}
#create_partition

# 2.6 - set $LFS variable
LFS="/mnt/lfs"
sudo -E mkdir -p "$LFS"

#2.7 - Mount lfs partition
if ! mountpoint "$LFS" ; then
echo "Mounting the image file to $LFS"
sudo mount -o loop "$LFSDISKFILE" "$LFS"
fi

get_sources() {
# 3.1 - downloading sources
# Yes we do all this as root, next step we will set the users stuff
sudo -E mkdir -p -v "$LFS/sources"
sudo -E chmod -v a+wt "$LFS/sources"
pushd "$LFS/sources"
    # Grab source files
    # Warning: This wget-list file isn't specific to book release version 10
    # so future releases might break this!
    sudo -E wget --continue http://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list
    #sudo -E wget --input-file=wget-list --continue --directory-prefix="$LFS/sources"
    # Validate checksums
    sudo -E wget http://www.linuxfromscratch.org/lfs/view/stable-systemd/md5sums
    md5sum -c md5sums
    # No need to grab patches seaprately, the wget-list file above already contains the patches.
    #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/bash-5.0-upstream_fixes-1.patch
    #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/bzip2-1.0.8-install_docs-1.patch
    #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/coreutils-8.32-i18n-1.patch
    #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/glibc-2.32-fhs-1.patch
    #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/kbd-2.3.0-backspace-1.patch
popd
}
#get_sources

# 4.2 Create directory layout
sudo -E mkdir -pv "$LFS"/{bin,etc,lib,sbin,usr,var,tmp}
case $(uname -m) in
  x86_64) sudo -E mkdir -pv "$LFS/lib64" ;;
esac
sudo -E mkdir -pv "$LFS/tools"

create_lfs_user () {
# 4.3 Create lfs user
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
# Set password. Plaintext hardcoded since this is simply learning exercise.
echo "lfs:lfspwd" | sudo chpasswd
# Change dir permissions
sudo -E chown -v lfs "$LFS"/{usr,lib,var,etc,bin,sbin,tmp,tools}
case $(uname -m) in
  x86_64) sudo -E chown -v lfs "$LFS/lib64" ;;
esac
sudo -E chown -v lfs "$LFS/sources"
}
#create_lfs_user

echo Finished the root portion of script. Run build_lfs_1.sh to continue operation as user 'lfs'.


#EOF
