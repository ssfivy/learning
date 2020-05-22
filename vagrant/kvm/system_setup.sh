#!/bin/bash

# setup vagrant using kvm backend https://github.com/vagrant-libvirt/vagrant-libvirt

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")
#BUILDDIR=$(realpath "$THIS_SCRIPT_DIR/../build")

sudo apt-get build-dep vagrant ruby-libvirt
sudo apt-get install -y \
    qemu libvirt-daemon-system libvirt-clients ebtables dnsmasq-base \
    libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev \
    qemu-kvm qemu-utils

vagrant plugin install vagrant-libvirt

# TODO: Install swtpm software
# Either compile from source or use PPAs from https://launchpad.net/ubuntu/+ppas?name_filter=swtpm
