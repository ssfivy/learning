#!/bin/bash

# Create a dm-verity verified filesystem!
# Experiments in using verifed rootfs

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

WORKDIR=$THIS_SCRIPT_DIR/lrn_work
ROOTFS=$WORKDIR/root
LOOPFILE=$WORKDIR/loopfile
HASHFILE=$WORKDIR/hashfile
MOUNTPOINT=$WORKDIR/mnt
VERITYDEVICE='vroot'

echo "Cleaning work directory"
rm -rf "$WORKDIR"
mkdir -p "$MOUNTPOINT"

mkdir -p "$ROOTFS"
pushd "$ROOTFS"
echo "Creating some example directory structure to verify"
mkdir -p boot etc home/root/.ssh opt/program opt/secrets
ssh-keygen -q -N "" -t rsa -b 2048 -f "$ROOTFS/home/root/.ssh/id_rsa"
touch etc/passwd
openssl rand -out "$ROOTFS/opt/secrets/password" 32
popd


cd "$WORKDIR"

echo "Creating file to be used as partition, format it with ext4, put files in, and unmount"
dd if=/dev/zero "of=$LOOPFILE" bs=1M count=8
LOOP_DEVICE=$(sudo losetup -f)
sudo losetup "$LOOP_DEVICE" "$LOOPFILE"
sudo mkfs.ext4 -c "$LOOP_DEVICE" 8m
sudo losetup -d "$LOOP_DEVICE"
sudo mount -o loop "$LOOPFILE" "$MOUNTPOINT"
pushd "$ROOTFS"
sudo cp --archive -- ./* "$MOUNTPOINT"
popd
sudo umount "$MOUNTPOINT"

echo "Create veritysetup hash"
FORMAT_OUTPUT=$(veritysetup format "$LOOPFILE" "$HASHFILE")
roothash=$(echo "$FORMAT_OUTPUT" | grep "Root hash" | cut -f 2)

cleanup_function () {
echo "cleanup"
set +e
sudo umount "$MOUNTPOINT"
sudo veritysetup close "$VERITYDEVICE"
rm -rf "$WORKDIR"
}
trap cleanup_function EXIT

echo "Validate veritysetup hash without mounting"
# this command is purely userspace and dont need sudo
veritysetup verify "$LOOPFILE" "$HASHFILE" "$roothash" --verbose

echo "Create dm-verity mapping"
sudo veritysetup open "$LOOPFILE" "$VERITYDEVICE" "$HASHFILE" "$roothash"
echo "veritysetup open return code $?"
sudo mount -t ext4 -o ro "/dev/mapper/$VERITYDEVICE" "$MOUNTPOINT"

echo "check verity superblock contents (first 50 lines of hexdump)"
hexdump -C "$HASHFILE" | head -n 50

echo "check file contents"
tree -a "$MOUNTPOINT"
cmp --verbose "$ROOTFS/opt/secrets/password" "$MOUNTPOINT/opt/secrets/password"
cmp --verbose "$ROOTFS/home/root/.ssh/id_rsa" "$MOUNTPOINT/home/root/.ssh/id_rsa"

echo "Check verity status"
sudo dmsetup ls --tree
sudo veritysetup status "$VERITYDEVICE"

echo "Let's try messing with the files!"
sudo umount "$MOUNTPOINT"
sudo veritysetup close "$VERITYDEVICE"
# Mess with the underlying files directly on disk, skipping verity device
# this IS possible, verity doesnt prevent this if you have root
# but verity will detect things and refuse to load binaries
sudo mount -o loop "$LOOPFILE" "$MOUNTPOINT"
echo "x" >> "$MOUNTPOINT/opt/secrets/password"
sudo umount "$MOUNTPOINT"

echo "Let's check if we can mount things again!"
# TODO: Understand failure modes here!
sudo veritysetup open "$LOOPFILE" "$VERITYDEVICE" "$HASHFILE" "$roothash"
echo "veritysetup open return code $?"
ls -la "/dev/mapper/"
sudo mount -o ro "/dev/mapper/$VERITYDEVICE" "$MOUNTPOINT"
# this should barf and die
cat "$MOUNTPOINT/opt/secrets/password" || echo "SUCCESS: dm-verity error"

#EOF - cleanup should be triggered here
