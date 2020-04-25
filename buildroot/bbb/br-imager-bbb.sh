#!/bin/bash

# Create beaglebone black bootable image from buildroot output
# run this script as root or with sudo
# Need retesting

set -xe

# Hardcoded so I dont make mistakes
THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
BUILDROOT=$(realpath "$THIS_SCRIPT_DIR/../buildroot")
DLDIR=$(realpath "$THIS_SCRIPT_DIR/../br_downloads")
BUILD_DIR=$(realpath "$THIS_SCRIPT_DIR/../br_build")
WORKDIR=$BUILD_DIR/images
DISK=/dev/sdd

if [ ! -b $DISK ]; then
    echo "$DISK is not a block device, aborting"
    exit 1
fi

PARTEDOPTIONS="--machine --script --align optimal"

# nuke all existing partitions
dd if=/dev/zero of=$DISK bs=1M count=1
parted $PARTEDOPTIONS $DISK mklabel msdos
# create boot partition
parted $PARTEDOPTIONS $DISK mkpart primary fat16 1MiB 129MiB
parted $PARTEDOPTIONS $DISK set 1 boot on
# create root partition
parted $PARTEDOPTIONS $DISK mkpart primary 129MiB 100%

# flush partition changes
sync
sleep 2

# Create filesystems
mkfs.vfat -F 32 -n BOOT "${DISK}1"
mkfs.ext4 -L ROOTFS -E nodiscard -F -v "${DISK}2"

# flush partition changes
sync
sleep 2


# Copy files to boot partition
mount "${DISK}1" /mnt
pushd ${WORKDIR}
cp MLO /mnt
cp u-boot.img /mnt
cp *Image /mnt
cp *.dtb /mnt

cat > uEnv.txt <<EOF
bootdir=
bootpart=0:1
devtype=mmc
args_mmc=setenv bootargs console=${console} ${optargs} root=/dev/mmcblk0p2 rw rootfstype=${mmcrootfstype}
uenvcmd=run loadimage;run loadramdisk;run findfdt;run loadfdt;run mmcloados
EOF

cp uEnv.txt /mnt

popd
umount /mnt
sync

# Copy files to root partition
mount "${DISK}2" /mnt
pushd /mnt
tar xvf "${WORKDIR}/rootfs.tar"
popd
umount /mnt
sync

echo "Finished!"
