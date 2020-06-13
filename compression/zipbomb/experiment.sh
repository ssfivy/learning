#!/bin/bash

# Experiment creating basic zip bomb and compression ratios
# Not for malicious porposes - just want to see what happend when you use regular tools this way

set -e

# use ram for speed
WORKDIR=$XDG_RUNTIME_DIR/lrn_work

echo "Cleaning work directory"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

cleanup () {
echo "cleaning up"
rm -rf "$WORKDIR"
}
trap cleanup EXIT

echo "Create a 1GB file with completely identical content"
yes | dd of=./corefile bs=1M count=1024 iflag=fullblock

# Let's run some gzip tests!

compress_file () {
    # compress
    gzip < "$1" > "$2"
    # Record the size
    ls -lh "$2"
}

# Probably can make number of files variable
# but can't be bothered looking up syntax right now
compress_file_5fold () {
    # compress (in practice these files will be hard to separate but we dont care about that)
    cat "$1" "$1" "$1" "$1" "$1" | gzip > "$2"
    # Record the size
    ls -lh "$2"
}

test_file () {
    echo "Compressing file recursively"
    compress_file corefile     corefile1.gz
    compress_file corefile1.gz corefile2.gz
    compress_file corefile2.gz corefile3.gz
    compress_file corefile3.gz corefile4.gz
}
time test_file

test_5file () {
    echo "Compressing 5 files  recursively"
    compress_file_5fold corefile      5corefile1.gz
    compress_file_5fold 5corefile1.gz 5corefile2.gz
    compress_file_5fold 5corefile2.gz 5corefile3.gz
    compress_file_5fold 5corefile3.gz 5corefile4.gz
}
time test_5file

# Let's run some zip tests!
zip_file () {
    zip --quiet "$2" "$1"
    # Record the size
    ls -lh "$2"
}
zip_file_5fold () {
    # Add file, then revane the file inside the archive, then add again, repeat 5x
    zip --quiet "$2" "$1"
    printf "@ %s\n@=%s\n" "$1" "$1-1" | zipnote -w "$2"
    zip --quiet "$2" "$1"
    printf "@ %s\n@=%s\n" "$1" "$1-2" | zipnote -w "$2"
    zip --quiet "$2" "$1"
    printf "@ %s\n@=%s\n" "$1" "$1-3" | zipnote -w "$2"
    zip --quiet "$2" "$1"
    printf "@ %s\n@=%s\n" "$1" "$1-4" | zipnote -w "$2"
    zip --quiet "$2" "$1"
    printf "@ %s\n@=%s\n" "$1" "$1-5" | zipnote -w "$2"
    # Record the size
    ls -lh "$2"
}

test_zipfile () {
    echo "Zipping file recursively"
    zip_file corefile      corefile1.zip
    zip_file corefile1.zip corefile2.zip
    zip_file corefile2.zip corefile3.zip
    zip_file corefile3.zip corefile4.zip
}
time test_zipfile

test_zip5file () {
    echo "Zipping 5 files recursively"
    zip_file_5fold corefile       5corefile1.zip
    zip_file_5fold 5corefile1.zip 5corefile2.zip
    zip_file_5fold 5corefile2.zip 5corefile3.zip
}
time test_zip5file


# workdir will be cleaned up by exit trap

#EOF
