#!/bin/bash

set -xe

TPM_VERSION=1563
TSS_VERSION=1.4.0

mkdir -p lrn_build
cd lrn_build

wget https://downloads.sourceforge.net/project/ibmtpm20tss/ibmtss${TSS_VERSION}.tar.gz
mkdir -p ibmtss${TSS_VERSION}
pushd ibmtss${TSS_VERSION}
tar -xavf ../ibmtss${TSS_VERSION}.tar.gz
pushd utils
make -f makefiletpmc "-j$(nproc)"
popd
popd

wget https://downloads.sourceforge.net/project/ibmswtpm2/ibmtpm${TPM_VERSION}.tar.gz
mkdir -p ibmtpm${TPM_VERSION}
pushd ibmtpm${TPM_VERSION}
tar -xavf ../ibmtpm${TPM_VERSION}.tar.gz
pushd src
make "-j$(nproc)"
popd
popd
