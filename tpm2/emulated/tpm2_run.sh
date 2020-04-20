#!/bin/bash

set -xe

TPM_VERSION=1563
TSS_VERSION=1.4.0

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
TOPDIR=$THIS_SCRIPT_DIR/lrn_build
PREFIXDIR_SWTPM2=$TOPDIR/swtpm-prefix

# Run tpm emulator
##################
cd $TOPDIR

run_ibmswtpm () {
pushd ibmtpm${TPM_VERSION}/src
./tpm_server &
popd
}


run_msswtpm2 () {
pushd ms-tpm-20-ref/TPMCmd/Simulator/src
./tpm2-simulator
popd
}

run_swtpm () {
    mkdir -p /tmp/myvtpm
    pushd $PREFIXDIR_SWTPM2/bin
    ./swtpm socket --tpmstate dir=/tmp/myvtpm --tpm2 --ctrl type=tcp,port=2322 \
   --server type=tcp,port=2321 --flags not-need-init &
    popd
}

# Startup sequence
###################
run_ibmtss_startup() {
pushd ibmtss${TSS_VERSION}/utils
./powerup
./startup
popd
}

run_tpm2_startup () {
export TPM2TOOLS_TCTI_NAME=socket
tpm2_startup -c
tpm2_pcrlist
}

#run_ibmswtpm
#run_msswtpm2
#run_swtpm

#run_ibmtss_startup
#run_tpm2_startup


#sudo tpm2-abrmd --allow-root --tcti=mssim &
