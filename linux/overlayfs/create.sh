#!/bin/bash

set -e

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

# This is our experimental root directory
ROOTDIR=$THIS_SCRIPT_DIR/lrn_work
ETCDIR="$ROOTDIR/etc"
TMPDIR="$ROOTDIR/tmp"
UPPERETCDIR="$TMPDIR/upperetc"
WORKDIR="$TMPDIR/workdir"

cleanup() {
    echo "Trap: Cleanup"
    sudo umount "$ETCDIR"
    sudo umount "$TMPDIR"
}

trap cleanup EXIT

echo "Creating fresh directories"
rm -rf "$ROOTDIR"
mkdir -p "$ETCDIR" "$TMPDIR"

cd "$ROOTDIR"

echo ""
echo "Pre-work: Let's mount a tmpfs on /tmp"
echo "====================================="
echo ""
sudo mount -t tmpfs \
    -o "size=100M,nr_inodes=10k,mode=700,uid=$(id -u),gid=$(id -g)" \
    tmpfs \
    "$TMPDIR"
echo "$TMPDIR"
ls -la "$TMPDIR"

# Now we create the upper and workdir under tmpfs
mkdir -p "$UPPERETCDIR" "$WORKDIR"

echo ""
echo "add some files to the base rootfs"
echo "================================="
echo ""
echo "defaulthostname"    > "$ETCDIR/hostname"
echo "Australia/Sydney"   > "$ETCDIR/timezone"
echo "stuff_we_dont_want" > "$ETCDIR/passwd"
chmod 600 "$ETCDIR/hostname" "$ETCDIR/timezone" "$ETCDIR/passwd"
echo "$ETCDIR"
ls -la "$ETCDIR"

echo ""
echo "State of files"
echo "=============="
echo ""
echo "$ETCDIR"
ls -la "$ETCDIR"
cat "$ETCDIR"/*
echo ""
echo "$UPPERETCDIR"
ls -la "$UPPERETCDIR"

echo ""
echo "Perform the overlay mount!"
echo "=========================="
echo ""

sudo mount -t overlay \
    -o "lowerdir=$ETCDIR,upperdir=$UPPERETCDIR,workdir=$WORKDIR" \
    overlay "$ETCDIR"

echo ""
echo "Showing mount listing"
echo "====================="
echo ""
mount | tail -n 2

echo ""
echo "State of files"
echo "=============="
echo ""
echo "$ETCDIR"
ls -la "$ETCDIR"
cat "$ETCDIR"/*
echo ""
echo "$UPPERETCDIR"
ls -la "$UPPERETCDIR"

echo ""
echo "We are now Helios, located in Area 51"
echo "and I dont need a passwd for I am god"
echo "====================================="
echo ""
echo "Helios"  > "$ETCDIR/hostname"
echo "America/Area_51" > "$ETCDIR/timezone"
rm "$ETCDIR/passwd"


echo ""
echo "State of files"
echo "=============="
echo ""
echo "$ETCDIR"
cat "$ETCDIR"/*
ls -la "$ETCDIR"
echo ""
echo "$UPPERETCDIR"
ls -la "$UPPERETCDIR"
cat "$UPPERETCDIR/hostname" "$UPPERETCDIR/timezone"


echo ""
echo "Unmount overlayfs"
echo "================="
echo ""
sudo umount "$ETCDIR"

echo ""
echo "State of files"
echo "=============="
echo ""
echo "$ETCDIR"
ls -la "$ETCDIR"
cat "$ETCDIR"/*
echo ""
echo "$UPPERETCDIR"
ls -la "$UPPERETCDIR"
cat "$UPPERETCDIR/hostname" "$UPPERETCDIR/timezone"

echo ""
echo "Cleanup"
echo ""
sudo umount "$TMPDIR"
rm -rf "$ROOTDIR"
trap - EXIT
echo "Done!"
