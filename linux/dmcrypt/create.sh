#!/bin/bash

# Creating a device and mount it
# Sources:
# https://docstore.mik.ua/orelly/unix3/upt/ch44_07.htm
# https://unix.stackexchange.com/questions/205541/how-to-atomically-allocate-a-loop-device

# FYI look up the tomb project if you plan to use this for general file encryption

set -xe

NAME=learning-device

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

WORKDIR=$THIS_SCRIPT_DIR/lrn_work
LOOPFILE=$WORKDIR/loopfile
MOUNTPOINT=$WORKDIR/mnt
PASSWDFILE=$WORKDIR/password
DEV_PATH=/dev/mapper/${NAME}

echo "Cleaning work directory"
rm -rf "$WORKDIR"
mkdir -p "$MOUNTPOINT"


cd "$WORKDIR"

echo "Creating file to be used as partition"
# use random source for this - for security
# /dev/urandom is too slow for this
SIZE_BYTES=$(echo "scale=2; 100 * 1024 ^ 2;" | bc) # Generate 100MB
openssl rand -out "$LOOPFILE" "$SIZE_BYTES"

echo "Creating passphrase"
openssl rand -base64 12 > "$PASSWDFILE"

# These are all default options
# LUKS type, aes cipher in xts-plain64 mode,
# 512-bit key for XTS, iterations set to similar to my desktop machine
# We read passphrase from file for ease of automation and debugabillity since this is experiment code
# Batch mode: do not warn against overwriting data
# We can avoid sudo by using --pbkdf pbkdf2 instead of the default argon2i; source: https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1667311.html
echo "Running cryptsetup"
cryptsetup -v \
    --type luks \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha256 \
    --iter-time 2000 \
    --use-urandom \
    --key-file "$PASSWDFILE" \
    --batch-mode \
    --pbkdf pbkdf2 \
    luksFormat "$LOOPFILE"

# Open / unlock the device
sudo cryptsetup -v \
    --key-file "$PASSWDFILE" \
    open "$LOOPFILE" "$NAME"

echo "Partitioning the loop device with ext4"
sudo mkfs.ext4 -c "$DEV_PATH"

echo "Mounting the image file to $MOUNTPOINT"
sudo mount -t ext4 "$DEV_PATH" "$MOUNTPOINT"

echo "Showing mount listing"
mount

sleep 5

echo "Unmounting and cleaning up"
sudo umount "$MOUNTPOINT"
sudo cryptsetup close "$NAME"
rm -rf "$WORKDIR"
