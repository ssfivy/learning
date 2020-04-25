#!/bin/bash

# Experiments with clevis to encrypt/decrypt things using tpm2 backend
# Too bad I don't have a second machine with tpm2 so we can test that the binary cannot be decrypted in a separate machine.
# Unless I can successfully emulate one....

# dependency: clevis clevis-tpm2
# and a pc with tpm2 hardware

set -xe

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))
WORKDIR=$THIS_SCRIPT_DIR/lrn_work


# Start with a clean slate
rm -rf $WORKDIR
mkdir -p $WORKDIR

# Generate random plaintext
dd if=/dev/urandom of=$WORKDIR/plaintext.1M bs=1M count=4

PLAINTEXT_CKSUM=$(sha256sum $WORKDIR/plaintext.1M)

# encrypt using clevis
clevis encrypt tpm2 '{}' < $WORKDIR/plaintext.1M > $WORKDIR/encrypted.1M

# clean original plaintext
rm $WORKDIR/plaintext.*

# Check that ciphertext is actually different
sha256sum $WORKDIR/encrypted.1M
file $WORKDIR/encrypted.1M

# decrypt using clevis
clevis decrypt < $WORKDIR/encrypted.1M > $WORKDIR/plaintext.1M

# Validate same with original
DECRYPTED_CKSUM=$(sha256sum $WORKDIR/plaintext.1M)

if [[ $PLAINTEXT_CKSUM == $DECRYPTED_CKSUM ]]; then
    echo "Success! Plaintext identical!"
else
    echo "Failure: Plaintext different!"
    exit 1
fi
