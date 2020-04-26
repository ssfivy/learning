#!/bin/bash

# Run a one-off virtual machine image with TPM support
# Will create the VM if none existed

set -xe

# TODO: Figure out how to use ubuntu cloud vm image so we don't need to go through vm install process
# or use hashicorp packer to make one
#IMAGE_DLPATH="https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
IMAGE_DLPATH="https://releases.ubuntu.com/20.04/ubuntu-20.04-live-server-amd64.iso"
IMAGE_NAME=$(basename "$IMAGE_DLPATH")

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
VM_DIR=$(realpath "$THIS_SCRIPT_DIR/qemu-vm")
TPM_DIR=$(realpath "$THIS_SCRIPT_DIR/mytpm2")

mkdir -p  $VM_DIR/base
mkdir -p  $VM_DIR/instance-2

install_prerequisites () {
    # TODO: Add qemu, libvirt, kvm install
    if [[ ! $(id -Gn $USER | grep '\bkvm\b') ]]; then
        echo "ERROR: User must be a member of kvm group to run qemu"
        exit 1
    fi
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        qemu qemu-kvm
}
install_prerequisites

download_image () {
    pushd $VM_DIR/base
    wget -c $IMAGE_DLPATH
    qemu-img info $IMAGE_NAME
    popd
}
download_image


create_instance_image () {
qemu-img create -f qcow2 $VM_DIR/instance-2/instance-2.qcow2 8G
qemu-img info $VM_DIR/instance-2/instance-2.qcow2
}
create_instance_image

setup_cloud_init() {
pushd $VM_DIR/instance-2
SSH_PUBLICKEY="$(cat $HOME/.ssh/id_rsa.pub)"
cat > cloudinit.txt << EOF
#cloud-config
users:
  - name: $USER
    ssh-authorized-keys:
      - $SSH_PUBLICKEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
EOF

cloud-localds --disk-format qcow2 cloudinit.img cloudinit.txt
popd
}
#setup_cloud_init

start_kvm () {
    qemu-system-x86_64 \
    -display sdl \
    -accel kvm \
    -m 1024 \
    -smp 4 \
    -device e1000,netdev=user.0 \
    -netdev user,id=user.0,hostfwd=tcp::5555-:22 \
    -drive file=$VM_DIR/instance-2/instance-2.qcow2,if=virtio,cache=writeback,index=0 \
    -chardev socket,id=chrtpm,path=/tmp/mytpm2/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0 \
    -cdrom $VM_DIR/base/$IMAGE_NAME
}
start_kvm

# ssh -p 5555 $USER@localhost

#EOF
