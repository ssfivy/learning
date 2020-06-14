#!/bin/bash

# Let's encrypt with acme.sh


# Note the hurricane electric plugin for acme.sh seems to login to the web interface, or at least tries to hit the same API backends that the web interface is hitting.
# These are probably undocumented so may not be broken in the future.

# Note this is just a record of operations I did, these are not meant to be automation-ready.

HE_Username=ssfivy
HE_Password=hunter2 # hohohoho

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

# store certificates
CERT_DIR="$THIS_SCRIPT_DIR/lrn_work/certs"
CERT_KEY="$CERT_DIR/key.pem"
CERT_FILE="$CERT_DIR/cert.pem"

# example nginx confs
WWWROOT="/tmp/www"
BASE_CONF="$THIS_SCRIPT_DIR/nginx-testconf"
TEST_CONF="$THIS_SCRIPT_DIR/lrn_work/nginx-testconf"

cd "$THIS_SCRIPT_DIR"

export HE_Username
export HE_Password

issue_le_cert () {
# Specify our domain
# Specify hurricane electric dns
# I dont know if more things needs to be specified but good enough to start with.
acme.sh  --issue \
    -d rico.home.intra.ssfivy.com \
    --dns dns_he
}
issue_le_cert

# Prepare location to put our certs
# Let's just put them here!
# Horribly insecure, but we are learning!
# Don't copy this! and if you do set your permissions properly!
# Also won't contaminate host system as much.

prep_cert_location () {
    rm -rf   "$CERT_DIR" "$WWWROOT"
    mkdir -p "$CERT_DIR"
    cp -r "$THIS_SCRIPT_DIR/www" "$WWWROOT"
    chmod -R g+rx "$WWWROOT"
    cp "$BASE_CONF" "$TEST_CONF"
    sed -i "s:REPLACE_SSLKEY:$CERT_KEY:"   "$TEST_CONF"
    sed -i "s:REPLACE_SSLCERT:$CERT_FILE:" "$TEST_CONF"
    sed -i "s:REPLACE_WWWROOT:$WWWROOT:"   "$TEST_CONF"
}
prep_cert_location

install_cert_nginx () {
    sudo cp "$TEST_CONF" /etc/nginx/sites-enabled/letsencrypt-nginx-testconf
    acme.sh --install-cert \
        -d rico.home.intra.ssfivy.com \
        --key-file       "$CERT_KEY" \
        --fullchain-file "$CERT_FILE" \
        --reloadcmd     "sudo systemctl restart nginx"
}
install_cert_nginx

#EOF
