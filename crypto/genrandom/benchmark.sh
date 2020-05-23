#!/bin/bash

# Test how fast different mechanisms generate random data
# Taken from these sources:
# https://superuser.com/questions/792427/creating-a-large-file-of-random-bytes-quickly/792505

set -e

# for those that can work with /dev/null
OUTFILE=/dev/null

# alternate target file (should be in tmpfs) - in case anything doesnt like /dev/null
OUTFILEREAL=/run/user/$(id -u)/outfile
touch "$OUTFILEREAL"
cleanup () {
    rm -f "$OUTFILEREAL"
}
trap cleanup EXIT

# Time how fast these commands create a 1 GiB file

# Athlete 1: /dev/urandom
dev_urandom () {
dd if=/dev/urandom of="$OUTFILE" bs=1G count=1 iflag=fullblock
}
echo
echo Testing /dev/urandom
echo ====================
time dev_urandom
time dev_urandom
time dev_urandom

# Athlete 2: openssl random
openssl_random () {
    SIZE_BYTES=$(echo "scale=2; 1024 ^ 3;" | bc)
    openssl rand -out "$OUTFILE" "$SIZE_BYTES"
}
echo
echo Testing openssl rand
echo ====================
time openssl_random
time openssl_random
time openssl_random

# Athlete 3: openssl enc with seed from /dev/urandom
openssl_enc () {
    # the initial dd is to limit the amount of generated data to 100MiB
    # (instead of cutting it at output since that giver error message like this: https://unix.stackexchange.com/questions/248235/always-error-writing-output-file-in-openssl)
    # openssl then encrypts using aes128 (faster than aes256) and a randomly generated password
    # nosalt is probably to speed up things a bit?
    # 2>/dev/null at the end is to get rid of erro messages warning of insecure kdf - we don't care, input is already random
    # openssl writes to file
    dd bs=1G count=1 iflag=fullblock if=/dev/zero | \
        openssl enc -aes-128-ctr -pass pass:"$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64)" -nosalt -out "$OUTFILE" 2>/dev/null
}
echo
echo Testing openssl enc
echo ===================
time openssl_enc
time openssl_enc
time openssl_enc

# Athlete 4: shred
use_shred () {
    touch "$OUTFILE"
    shred -n 1 -s 1G "$OUTFILE"
}
echo
echo Testing shred
echo =============
time use_shred
time use_shred
time use_shred

#EOF
