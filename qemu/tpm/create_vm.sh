#!/bin/bash

# based on https://gist.github.com/george-hawkins/16ee37063213f348a17717a7007d2c79
# and https://blog.dustinkirkland.com/2016/09/howto-launch-ubuntu-cloud-image-with.html
# https://www.cyberciti.biz/faq/how-to-use-kvm-cloud-images-on-ubuntu-linux/

set -xe

IMAGE_DLPATH="https://cloud-images.ubuntu.com/releases/focal/release/ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img"
#IMAGE_DLPATH="https://releases.ubuntu.com/20.04/ubuntu-20.04-live-server-amd64.iso"
IMAGE_NAME=$(basename "$IMAGE_DLPATH")

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
VM_DIR=$(realpath "$THIS_SCRIPT_DIR/qemu-vm")
TPM_DIR=$(realpath "$THIS_SCRIPT_DIR/mytpm2")

mkdir -p  $VM_DIR/base
mkdir -p  $VM_DIR/instance-1
#chmod 777 $VM_DIR/instance-1  #give access to user libvirt-qemu

install_prerequisites () {
    # TODO: Add qemu, libvirt, kvm install
    if [[ ! $(id -Gn $USER | grep '\bkvm\b') ]]; then
        echo "ERROR: User must be a member of kvm group to run qemu"
        exit 1
    fi

    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
        cloud-utils libvirt-daemon ovmf
}
#install_prerequisites

download_image () {
    pushd $VM_DIR/base
    wget -c $IMAGE_DLPATH
    qemu-img info $IMAGE_NAME
    popd
}
#download_image

create_disk_image () {
qemu-img create -f qcow2 \
    -o backing_file=$VM_DIR/base/$IMAGE_NAME \
    $VM_DIR/instance-1/instance-1.qcow2
qemu-img resize $VM_DIR/instance-1/instance-1.qcow2 5G
qemu-img info $VM_DIR/instance-1/instance-1.qcow2
#chmod 777 $VM_DIR/instance-1/instance-1.qcow2 #give access to user libvirt-qemu
}
#create_disk_image

create_instance_image () {
qemu-img create -f qcow2 $VM_DIR/instance-1/instance-1.qcow2 5G
qemu-img info $VM_DIR/instance-1/instance-1.qcow2
}
#create_instance_image

setup_cloud_init() {
pushd $VM_DIR/instance-1
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
#chmod 777 cloudinit.img #give access to user libvirt-qemu
popd
}

setup_cloud_init
