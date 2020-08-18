#!/bin/bash

# Install build dependencies

sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo -E apt-get install -y \
    autoconf \
    autoconf-archive \
    automake \
    build-essential \
    doxygen \
    gcc \
    git \
    iproute2 \
    libcmocka-dev \
    libcmocka0 \
    libcurl4-openssl-dev \
    libgcrypt20-dev \
    libini-config-dev \
    libjson-c-dev \
    libltdl-dev \
    libssl-dev \
    libtool \
    pkg-config \
    procps \
    uthash-dev \
    uuid-dev
