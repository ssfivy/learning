

# Based on LFS 10 systemd edition

set -eu
THISDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
COCKATOODIR="$(realpath "$THISDIR/../../../")"

BUILDDIR="$COCKATOODIR/build_lfs"
ORIG_SOURCEDIR="$BUILDDIR/sources"
LFSDISKFILE="$BUILDDIR/lfsdiskfile"

mkdir -p "$BUILDDIR"
cd "$BUILDDIR"

# 2.6 - set $LFS variable
# Do this first since almost all paths folow from this
LFS="/mnt/lfs"
sudo -E mkdir -p "$LFS"

# Nuke all previous work if we need to rebuild from scratch
if [[ "$REBUILD_FROM_SCRATCH" == "true" ]]; then
    if mountpoint "$LFS" ; then
        # if we want to rebuild, unmount if mounted so we can delete properly
        sudo umount "$LFS"
    fi
    rm -f "$LFSDISKFILE"
fi

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
if [[ "$REBUILD_FROM_SCRATCH" == "true" ]]; then create_partition; fi

#2.7 - Mount lfs partition
if ! mountpoint "$LFS" ; then
echo "Mounting the image file to $LFS"
sudo mount -o loop "$LFSDISKFILE" "$LFS"
fi


get_sources() {
# 3.1 - downloading sources
# Yes we do all this as root, next step we will set the users stuff
sudo -E mkdir -p -v "$ORIG_SOURCEDIR"
sudo -E chmod -v a+wt "$ORIG_SOURCEDIR"
pushd "$ORIG_SOURCEDIR"
    # Grab source files
    sudo -E wget http://www.linuxfromscratch.org/lfs/view/stable-systemd/md5sums

    # Try save some effort: Build only when md5sums invalid
    if ! md5sum -c md5sums; then
        # Warning: This wget-list file isn't specific to book release version 10
        # so future releases might break this!
        sudo -E wget --continue http://www.linuxfromscratch.org/lfs/view/stable-systemd/wget-list
        sudo -E wget --input-file=wget-list --continue --directory-prefix="$ORIG_SOURCEDIR"
        # Validate checksums again
        md5sum -c md5sums
        # No need to grab patches seaprately, the wget-list file above already contains the patches.
        #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/bash-5.0-upstream_fixes-1.patch
        #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/bzip2-1.0.8-install_docs-1.patch
        #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/coreutils-8.32-i18n-1.patch
        #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/glibc-2.32-fhs-1.patch
        #sudo -E wget --continue http://www.linuxfromscratch.org/patches/lfs/10.0/kbd-2.3.0-backspace-1.patch
    fi
popd
}
get_sources

apply_sources() {
# 3.1 - downloading sources
# Yes we do all this as root, next step we will set the users stuff
sudo -E mkdir -p -v "$LFS/sources"
sudo -E chmod -v a+wt "$LFS/sources"
sudo cp -v "$ORIG_SOURCEDIR"/* "$LFS/sources"
}
#apply_sources
if [[ "$REBUILD_FROM_SCRATCH" == "true" ]]; then apply_sources; fi


# 4.2 Create directory layout
sudo -E mkdir -pv "$LFS"/{bin,etc,lib,sbin,usr,var,tmp}
case $(uname -m) in
  x86_64) sudo -E mkdir -pv "$LFS/lib64" ;;
esac
sudo -E mkdir -pv "$LFS/tools"

sudo -E mkdir -p "$LFS/tmp2" # directory for building stuff

create_lfs_user_onhost () {
# 4.3 Create lfs user
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
# Set password. Plaintext hardcoded since this is simply learning exercise.
echo "lfs:lfspwd" | sudo chpasswd
}
#create_lfs_user_onhost
#if [[ "$REBUILD_FROM_SCRATCH" == "true" ]]; then create_lfs_user; fi #FIXME: not reentrant


change_dir_permissions () {
# 4.3 Create lfs user ; Change dir permissions
sudo -E chown -v lfs "$LFS"/{usr,lib,var,etc,bin,sbin,tmp,tools,tmp2}
case $(uname -m) in
  x86_64) sudo -E chown -v lfs "$LFS/lib64" ;;
esac
sudo -E chown -v lfs "$LFS/sources"

}
#change_dir_permissions
if [[ "$REBUILD_FROM_SCRATCH" == "true" ]]; then change_dir_permissions; fi



echo Finished the root portion of script. Run build_lfs_1.sh to continue operation as user 'lfs'.


#EOF
