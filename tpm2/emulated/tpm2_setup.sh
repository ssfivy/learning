#!/bin/bash

set -xe


TPM_VERSION=1563
TSS_VERSION=1.4.0

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
TOPDIR=$THIS_SCRIPT_DIR/lrn_build
PREFIXDIR_SWTPM2=$TOPDIR/swtpm-prefix

mkdir -p $TOPDIR
cd $TOPDIR

install_system() {
    sudo apt-get install -y autoconf-archive devscripts equivs build-essential
    # dependency for swtpm2
    sudo apt-get install -y \
    libtool \
    debhelper \
    libfuse-dev \
    libglib2.0-dev \
    libgmp-dev \
    expect \
    libtasn1-dev \
    socat \
    python3-twisted \
    gnutls-dev \
    gnutls-bin \
    libssl-dev \
    net-tools \
    gawk \
    softhsm2 \
    libseccomp-dev \
    pkg-config \
    dh-exec
}

build_ibmtss () {
wget https://downloads.sourceforge.net/project/ibmtpm20tss/ibmtss${TSS_VERSION}.tar.gz
mkdir -p ibmtss${TSS_VERSION}
pushd ibmtss${TSS_VERSION}
tar -xavf ../ibmtss${TSS_VERSION}.tar.gz
pushd utils
make -f makefiletpmc "-j$(nproc)"
popd
popd
}

build_ibmswtpm () {
wget https://downloads.sourceforge.net/project/ibmswtpm2/ibmtpm${TPM_VERSION}.tar.gz
mkdir -p ibmtpm${TPM_VERSION}
pushd ibmtpm${TPM_VERSION}
tar -xavf ../ibmtpm${TPM_VERSION}.tar.gz
pushd src
make "-j$(nproc)"
popd
popd
}

build_mstpm2 () {
REPODIR=ms-tpm-20-ref
if [ -d $REPODIR ]; then
    pushd $REPODIR
    git pull
    popd
else
    git clone --depth 1 https://github.com/Microsoft/ms-tpm-20-ref.git
fi
pushd $REPODIR/TPMCmd
git reset --hard
git clean -dxf
./bootstrap
./configure
make "-j$(nproc)"
popd
}

build_libtpms () {
REPODIR=libtpms
if [ -d $REPODIR ]; then
    pushd $REPODIR
    git pull
    popd
else
    git clone --depth 1 https://github.com/stefanberger/libtpms.git
fi

pushd $REPODIR
./autogen.sh --with-openssl
sudo make dist
mv debian/source debian/source.old
dpkg-buildpackage -us -uc "-j$(nproc)"
cd ..
sudo dpkg -i libtpms0_0*_amd64.deb libtpms-dev_0*_amd64.deb
popd
}

build_swtpm () {
REPODIR=swtpm
if [ -d $REPODIR ]; then
    pushd $REPODIR
    git pull
    popd
else
    git clone --depth 1 https://github.com/stefanberger/swtpm.git
fi

pushd $REPODIR
./autogen.sh
./configure --prefix=$PREFIXDIR_SWTPM2
make "-j$(nproc)"
make check
make install
popd
}

#install_system
#build_ibmtss
#build_ibmswtpm
#build_mstpm2
#build_libtpms
#build_swtpm
