#!/bin/bash

# Create a filesystem verified by dm-verity anc encrypted with dm-crypt!
# Experiments in using verifed+encrypted rootfs

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

WORKDIR=$THIS_SCRIPT_DIR/lrn_work
ROOTFS=$WORKDIR/root
LOOPFILE=$WORKDIR/loopfile
HASHFILE=$WORKDIR/hashfile
PASSWDFILE=$WORKDIR/password
MOUNTPOINT=$WORKDIR/mnt
CRYPTDEVICE='croot'
VERITYDEVICE='vroot'
DEV_CRYPT_PATH=/dev/mapper/${CRYPTDEVICE}
DEV_VERITY_PATH=/dev/mapper/${VERITYDEVICE}

echo "Cleaning work directory"
rm -rf "$WORKDIR"
mkdir -p "$MOUNTPOINT"

mkdir -p "$ROOTFS"
pushd "$ROOTFS"
echo "Creating some example directory structure to crypt+verify"
mkdir -p boot etc home/root/.ssh opt/program opt/secrets
ssh-keygen -q -N "" -t rsa -b 2048 -f "$ROOTFS/home/root/.ssh/id_rsa"
touch etc/passwd
openssl rand -out "$ROOTFS/opt/secrets/password" 32
popd


cleanup_function () {
echo "cleanup"
set +e
sudo umount "$MOUNTPOINT"
sudo cryptsetup close "$CRYPTDEVICE"
sudo veritysetup close "$VERITYDEVICE"
rm -rf "$WORKDIR"
}
trap cleanup_function EXIT

cd "$WORKDIR"

echo "Creating file to be used as partition,"
dd if=/dev/zero "of=$LOOPFILE" bs=1M count=32

echo "Creating passphrase"
openssl rand -base64 12 > "$PASSWDFILE"

# These are all default options
# LUKS type, aes cipher in xts-plain64 mode,
# 512-bit key for XTS
# iteration kept really short to make experiments faster
# We read passphrase from file for ease of automation and debugabillity since this is experiment code
# Batch mode: do not warn against overwriting data
# We can avoid sudo by using --pbkdf pbkdf2 instead of the default argon2i; source: https://www.mail-archive.com/debian-bugs-dist@lists.debian.org/msg1667311.html
echo "Running cryptsetup"
cryptsetup -v \
    --type luks \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --hash sha256 \
    --iter-time 20 \
    --use-urandom \
    --key-file "$PASSWDFILE" \
    --batch-mode \
    --pbkdf pbkdf2 \
    luksFormat "$LOOPFILE"

# Open / unlock the device
sudo cryptsetup -v \
    --key-file "$PASSWDFILE" \
    open "$LOOPFILE" "$CRYPTDEVICE"

echo "Partitioning the loop device with ext4"
sudo mkfs.ext4 -c "$DEV_CRYPT_PATH"

echo "Mounting the image file to $MOUNTPOINT, put files in, and unmount"
sudo mount -t ext4 "$DEV_CRYPT_PATH" "$MOUNTPOINT"
pushd "$ROOTFS"
sudo cp --archive -- ./* "$MOUNTPOINT"
popd
sudo umount "$MOUNTPOINT"
sudo cryptsetup close "$CRYPTDEVICE"

echo "Create veritysetup hash"
FORMAT_OUTPUT=$(veritysetup format "$LOOPFILE" "$HASHFILE")
roothash=$(echo "$FORMAT_OUTPUT" | grep "Root hash" | cut -f 2)

echo "Validate veritysetup hash without mounting"
# this command is purely userspace and dont need sudo
veritysetup verify "$LOOPFILE" "$HASHFILE" "$roothash" --verbose

echo "Create dm-verity mapping"
sudo veritysetup open "$LOOPFILE" "$VERITYDEVICE" "$HASHFILE" "$roothash"
echo "veritysetup open return code $?"

echo "Check verity status"
sudo dmsetup ls --tree
sudo veritysetup status "$VERITYDEVICE"  || echo "veritysetup status return code $?"
sudo cryptsetup status "$CRYPTDEVICE" || echo "cryptsetup status return code $?"

echo "Open the verity device using cryptsetup"
# Open / unlock the device
sudo cryptsetup -v \
    --key-file "$PASSWDFILE" \
    open "$DEV_VERITY_PATH" "$CRYPTDEVICE"

echo "Mount the opened cryptsetup device"
sudo mount -t ext4 -o ro "$DEV_CRYPT_PATH" "$MOUNTPOINT"

echo "check verity hashfile contents (first 20 lines of hexdump)"
hexdump -C "$HASHFILE" | head -n 20

echo "check luks header contents (first 20 lines of hexdump)"
hexdump -C "$LOOPFILE" | head -n 20

echo "check file contents"
tree -a "$MOUNTPOINT"
cmp --verbose "$ROOTFS/opt/secrets/password" "$MOUNTPOINT/opt/secrets/password"
cmp --verbose "$ROOTFS/home/root/.ssh/id_rsa" "$MOUNTPOINT/home/root/.ssh/id_rsa"

echo "Check verity status"
sudo dmsetup ls --tree
sudo veritysetup status "$VERITYDEVICE"
sudo cryptsetup status "$CRYPTDEVICE"

echo "Test complete, triggering cleanup!"

#EOF - cleanup should be triggered here
