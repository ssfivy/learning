#!/bin/bash

# Uses lexicon to query hurricane electric dns records
# install lexicon beforehand: pip3 install "dns-lexicon[henet]"
# Note lexicon he provider works by querying the web api and parsing the resulting web pages,
# so it may or may not be the most reliable way of updating things.

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

cd "$THIS_SCRIPT_DIR"

lexicon --delegated intra.ssfivy.com henet \
    --auth-username ssfivy \
    --auth-password "$HE_LOGIN_PASSWORD" \
    list \
    intra.ssfivy.com \
    A
