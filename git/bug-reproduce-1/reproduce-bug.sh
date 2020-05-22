#!/bin/bash

# Attempt to reproduce a git bug I discovered
# may not be successful

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
WORKDIR=$THIS_SCRIPT_DIR/lrn_work

echo "Printing system information"
cat /etc/os-release
losetup -V

echo "Cleaning work directory"
rm -rf $WORKDIR

# Warning: We start using custom home directory!
# This is so we can simulate git's behavior of opening multiple config files
# without having any effect with the user's actual config file
# or having to recompile git with custom $(prefix).
echo "Setting up custom home directory"
HOME=$WORKDIR/home/irving
echo "Setting up mount point"
MOUNT=$WORKDIR/media/irving/scratch
mkdir -p $HOME $MOUNT

echo "Creating file to be used as partition"
dd if=/dev/zero of=partitionfile bs=1M count=100
echo "Finding first unused loop device"
LOOP_DEVICE=$(losetup -f)
echo "Attaching image file to loop device $LOOP_DEVICE"
sudo losetup "$LOOP_DEVICE" partitionfile
echo "Partitioning the loop device with ext4"
sudo mkfs.ext4 -c "$LOOP_DEVICE" 100000
echo "Removing the loop device"
sudo losetup -d "$LOOP_DEVICE"
echo "Mounting the image file to $MOUNT"
sudo mount -o loop partitionfile "$MOUNT"

echo "Current mount config"
mount | tail -n5

echo "Setting up other directories"
sudo mkdir -p $MOUNT/src
sudo chown irving:irving $MOUNT/src
mkdir -p $MOUNT/src/github.com
ln -s -T $MOUNT/src/           $HOME/src

echo "Setting up alternate git config files"
cat << EOF > $HOME/.gitconfig
[core]
	pager = ""
[user]
	useConfigOnly = true
[includeIf "gitdir:src/github.com/"]
	path = $HOME/.cfg-github
EOF

cat << EOF > $HOME/.cfg-github
[user]
	email = custom-email@users.noreply.github.com
	name = github-username
[core]
	sshCommand = ssh -i ~/.ssh/id_rsa
EOF

echo ""
echo "Overview of directory structure"
cd $WORKDIR
tree -a

echo ""
echo "Check out a sample repository"
cd $MOUNT/src/github.com
#cd $HOME/src/github.com
git clone --depth 1 https://github.com/latchset/clevis.git

echo ""
cd $HOME/src/github.com/clevis
echo "Current directory: $(pwd)"
echo "Git configuration at repository root directory:"
git config -l | cat

echo ""
cd $HOME/src/github.com/clevis/src
echo "Current directory: $(pwd)"
echo "Git configuration at repository subdirectory:"
git config -l | cat

echo "Cleanup"
cd $WORKDIR
sudo umount "$MOUNT"
