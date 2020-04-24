#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))

# list options
openssl help speed

# list ciphers
openssl help

# Benchmark a specific cipher
openssl speed aes-128-cbc aes-256-cbc

# list engines
#openssl engine

# benchmark a specific engine
#openssl speed -engine aes-128-cbc
