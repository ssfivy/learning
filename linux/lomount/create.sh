#!/bin/bash

# Creating a device and mount it
# Sources:
# https://docstore.mik.ua/orelly/unix3/upt/ch44_07.htm
# https://unix.stackexchange.com/questions/205541/how-to-atomically-allocate-a-loop-device

set -e

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")
WORKDIR=$THIS_SCRIPT_DIR/lrn_work

echo "Cleaning work directory"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/mnt"


cd "$WORKDIR"

echo "Creating file to be used as partition"
dd if=/dev/zero of=image.file bs=1M count=100
echo "Finding first unused loop device"
LOOP_DEVICE=$(losetup -f)
echo "Attaching image file to loop device $LOOP_DEVICE"
sudo losetup "$LOOP_DEVICE" image.file
echo "Partitioning the loop device with ext4"
sudo mkfs.ext4 -c "$LOOP_DEVICE" 100000
echo "Removing the loop device"
sudo losetup -d "$LOOP_DEVICE"
echo "Mounting the image file to $WORKDIR/mnt"
sudo mount -o loop image.file "$WORKDIR/mnt"

echo "Showing mount listing"
mount

sleep 5

echo "Unmounting and cleaning up"
sudo umount "$WORKDIR/mnt"
rm -rf "$WORKDIR"
