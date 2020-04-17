#!/bin/bash

set -xe

TPM_VERSION=1563
TSS_VERSION=1.4.0

cd lrn_build

pushd ibmtpm${TPM_VERSION}/src
./tpm_server &
popd

#pushd ibmtss${TSS_VERSION}/utils
#./powerup
#./startup
#popd

export TPM2TOOLS_TCTI_NAME=socket
tpm2_startup -c
tpm2_pcrlist
sudo tpm2-abrmd --allow-root --tcti=mssim &
