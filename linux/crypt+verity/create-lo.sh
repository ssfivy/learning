#!/bin/bash

# Experiments in using verifed+encrypted rootfs

# PART 1
# Create file C. Mount it as loopback.
# Create dm-crypt device on top of this loopback. Create ext4 partition on top of the crypt device.
# Put data inside this partition. Close the loopback device and unmount the file.
# Now we have file C, containing dm-crypt layer,

# PART 2
# Create file V. Mount it as loopback. Create ext4 partition in this device.
# Move file C into this partition. Unmount partition.
# Create verity signature of file V.

# PART 3
# Mount file V as loopback again.
# create verity device on top of this partition (using the verity signature earlier).
# Try to mount file C as loopback. Try opening the dm-crypt device. Try reading the original data.

# Diagram of overall scheme              +-----------+
#                                        |           |
#                                        |   Data    |
#                                        |           |
#                              +---------MOUNTPOINT_C--------+
#                              |                             |
#                              |   dm-crypt device           |
#                              |                             |
#                              +-----------------------------+
#               loopback mount |                             |
#              +-------------->+   loopback device: file C   |
#              |               |                             |
#            +--------+        +-----------------------------+
#            |        |
#            | file C |
#            |        |
#  +---------MOUNTPOINT_V--------+
#  |                             +<--------------------------------------+
#  |    dm-verity device         |                                       |
#  |                             |                                 +-------------------+
#  +-----------------------------+                  +-----------+  |                   |
#  |                             |  loopback mount  |           |  | file V            |
#  |    loopback device: file V  +<-----------------+  file V   |  | verity signature  |
#  |                             |                  |           |  |                   |
#  +-----------------------------+                  +-----------+  +-------------------+
#

# This is an experiment of alternate stacking because simply
# stacking dm-crypt and dm-verity on the same lo device does not seem to work in ubuntu 18.04
# (though it does work in ubuntu 20.04)

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

WORKDIR=$THIS_SCRIPT_DIR/lrn_work
ROOTFS=$WORKDIR/root
LOOPFILE_C_NAME=loopfilec
LOOPFILE_C=$WORKDIR/$LOOPFILE_C_NAME
LOOPFILE_V=$WORKDIR/loopfilev
HASHFILE=$WORKDIR/hashfile
PASSWDFILE=$WORKDIR/password
MOUNTPOINT_C=$WORKDIR/mntc
MOUNTPOINT_V=$WORKDIR/mntv
CRYPTDEVICE='croot'
VERITYDEVICE='vroot'
DEV_CRYPT_PATH=/dev/mapper/${CRYPTDEVICE}
DEV_VERITY_PATH=/dev/mapper/${VERITYDEVICE}

echo "Cleaning work directory"
rm -rf "$WORKDIR"
mkdir -p "$MOUNTPOINT_C" "$MOUNTPOINT_V"

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
sudo umount "$MOUNTPOINT_C"
sudo cryptsetup close "$CRYPTDEVICE"
sudo umount "$MOUNTPOINT_V"
sudo veritysetup close "$VERITYDEVICE"
rm -rf "$WORKDIR"
}
trap cleanup_function EXIT

cd "$WORKDIR"

echo "Creating files to be used as partition"
dd if=/dev/zero "of=$LOOPFILE_C" bs=1M count=32 # Need to store ext4 metadata
dd if=/dev/zero "of=$LOOPFILE_V" bs=1M count=64 # Need to store ext4 metadata + the above file

########################## PART 1 ##########################

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
    --iter-time 4 \
    --use-urandom \
    --key-file "$PASSWDFILE" \
    --batch-mode \
    --pbkdf pbkdf2 \
    luksFormat "$LOOPFILE_C"

# Open / unlock the device
sudo cryptsetup -v \
    --key-file "$PASSWDFILE" \
    open "$LOOPFILE_C" "$CRYPTDEVICE"

echo "Partitioning the loopc device with ext4"
sudo mkfs.ext4 -c "$DEV_CRYPT_PATH"

echo "Mounting the image file to $MOUNTPOINT_C, put files in, and unmount"
sudo mount -t ext4 "$DEV_CRYPT_PATH" "$MOUNTPOINT_C"
pushd "$ROOTFS"
sudo cp --archive -- ./* "$MOUNTPOINT_C"
popd
sudo umount "$MOUNTPOINT_C"
sudo cryptsetup close "$CRYPTDEVICE"

########################## PART 2 ##########################

echo "Finding first unused loop device"
LOOP_DEVICE_V=$(losetup -f)

echo "Attaching file V to loop device $LOOP_DEVICE_V"
sudo losetup "$LOOP_DEVICE_V" "$LOOPFILE_V"

echo "Partitioning the loop device with ext4"
sudo mkfs.ext4 -c "$LOOP_DEVICE_V"

echo "Mounting file V to $MOUNTPOINT_V, put files in, and unmount"
sudo mount -t ext4 "$LOOP_DEVICE_V" "$MOUNTPOINT_V"
sudo cp "$LOOPFILE_C" "$MOUNTPOINT_V"
sudo sync
sudo umount "$MOUNTPOINT_V"


echo "Create veritysetup hash"
FORMAT_OUTPUT=$(veritysetup format "$LOOPFILE_V" "$HASHFILE")
roothash=$(echo "$FORMAT_OUTPUT" | grep "Root hash" | cut -f 2)

echo "Validate veritysetup hash without mounting"
# this command is purely userspace and dont need sudo
veritysetup verify "$LOOPFILE_V" "$HASHFILE" "$roothash" --verbose

########################## PART 3 ##########################

echo "Create dm-verity mapping"
sudo veritysetup open "$LOOPFILE_V" "$VERITYDEVICE" "$HASHFILE" "$roothash"
echo "veritysetup open return code $?"

echo "Check crypt/verity status"
sudo dmsetup ls --tree
sudo veritysetup status "$VERITYDEVICE"  || echo "veritysetup status return code $?"
sudo cryptsetup status "$CRYPTDEVICE" || echo "cryptsetup status return code $?"

echo "Mounting file V to $MOUNTPOINT_V, "
sudo mount -t ext4 -o ro "$DEV_VERITY_PATH" "$MOUNTPOINT_V"

echo "Check mount status"
mount | tail

echo "Open the verity device using cryptsetup"
# Open / unlock the device
sudo cryptsetup -v \
    --key-file "$PASSWDFILE" \
    open "${MOUNTPOINT_V}/${LOOPFILE_C_NAME}" "$CRYPTDEVICE"

echo "Check crypt/verity status"
sudo dmsetup ls --tree
sudo veritysetup status "$VERITYDEVICE"  || echo "veritysetup status return code $?"
sudo cryptsetup status "$CRYPTDEVICE" || echo "cryptsetup status return code $?"

echo "Mount the opened cryptsetup device"
sudo mount -t ext4 -o ro "$DEV_CRYPT_PATH" "$MOUNTPOINT_C"

echo "Check mount status"
mount | tail

echo "check verity hashfile contents (first 20 lines of hexdump)"
hexdump -C "$HASHFILE" | head -n 20

echo "check luks header contents (first 20 lines of hexdump)"
hexdump -C "${MOUNTPOINT_V}/${LOOPFILE_C_NAME}" | head -n 20

echo "check file contents"
tree -a "$MOUNTPOINT_C"
cmp --verbose "$ROOTFS/opt/secrets/password" "$MOUNTPOINT_C/opt/secrets/password"
cmp --verbose "$ROOTFS/home/root/.ssh/id_rsa" "$MOUNTPOINT_C/home/root/.ssh/id_rsa"

echo "Test complete, triggering cleanup!"

#EOF - cleanup should be triggered here
