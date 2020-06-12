#!/bin/bash

# The one definitely correct way to merge a bbunch of jpg files (e.g. from scanning) to a single PDF file without major quality loss.
# A lot of instructions out there uses imagemagick convert which works, but will do recompressing of the image.
# IF you just want to combine the jpeg files, you use the following mogrify + pdftk

# Requires imagemagick installed and security policy changed.
# Requires pdftk

set -xe

if [[ ! -d $1 ]]; then
    echo "Need 1 argument: directory containing jpeg files"
    exit 1
fi

cd "$1"

# ensure existing output file does not get repacked into the pdf
echo "Cleaning all PDF files in directory"
rm -f ./*.pdf

echo "Packing all jpeg files in directory $1"

# repack jpg into pdf using mogrify
mogrify -format pdf -- *.jpg

# Combine all the pdfs using pdftk
pdftk ./*.pdf cat output merged.pdf
