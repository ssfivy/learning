#!/bin/bash

# setup vagrant using kvm backend https://github.com/vagrant-libvirt/vagrant-libvirt

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s $0)")

vagrant up --provider=libvirt


# Effort Aborted
# Looks like vagrant libvirt backend does not have feature to specify tpm emulator backend and specifying tpm 2.0
