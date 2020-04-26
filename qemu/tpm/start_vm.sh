#!/bin/bash

# setup vagrant using kvm backend https://github.com/vagrant-libvirt/vagrant-libvirt

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
VM_DIR=$(realpath "$THIS_SCRIPT_DIR/qemu-vm")
TPM_DIR=$(realpath "$THIS_SCRIPT_DIR/mytpm2")

rm -rf /tmp/mytpm2
mkdir -p /tmp/mytpm2


swtpm socket --tpmstate dir=/tmp/mytpm2 \
  --ctrl type=unixio,path=/tmp/mytpm2/swtpm-sock \
  --log level=20 --tpm2 &

do_cleanup () {
    kill %1
}
trap do_cleanup EXIT

start_qemu () {
qemu-system-x86_64 -display sdl -accel kvm \
    -bios /usr/share/qemu/OVMF.fd \
    -m 1024 \
    -hda $VM_DIR/instance-1/instance-1.qcow2
}
start_qemu

start_qemu_cloud () {
qemu-system-x86_64 \
    -display sdl \
    -accel kvm \
    -m 1024 \
    -boot d -bios bios-256k.bin -boot menu=on \
    -chardev socket,id=chrtpm,path=/tmp/mytpm2/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm \
    -device tpm-tis,tpmdev=tpm0 \
    -device virtio-blk-device,drive=image \
    -drive if=none,id=image,file=$VM_DIR/instance-1/instance-1.qcow2 \
    -device virtio-blk-device,drive=cloud \
    -drive if=none,id=cloud,file=$VM_DIR/instance-1/cloudinit.img \
    -device virtio-net-device,netdev=user0 \
    -netdev user,id=user0 \
    -redir tcp:2222::22

}
#start_qemu_cloud

start_kvm () {
     kvm -m 8192 \
    -smp 4 \
    -device e1000,netdev=user.0 \
    -netdev user,id=user.0,hostfwd=tcp::5555-:22 \
    -drive file=$VM_DIR/instance-1/instance-1.qcow2,if=virtio,cache=writeback,index=0 \
    -cdrom $VM_DIR/instance-1/cloudinit.img
}
#start_kvm
