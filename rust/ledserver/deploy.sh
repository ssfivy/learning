#!/bin/bash

# deploy code to raspi and execute it
# assuems ssh is available and ssh using keys is alreasy setup;
# if not, run ssh-copy-id pi@IPADDR

IPADDR=192.168.89.102
USER=pi

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))

cargo build --target=arm-unknown-linux-gnueabi

ssh $USER@$IPADDR mkdir -p /home/$USER/ledserver
scp -r $THIS_SCRIPT_DIR/target/arm-unknown-linux-gnueabi/debug/ledserver $USER@$IPADDR:/home/$USER/ledserver
ssh $USER@$IPADDR sudo /home/$USER/ledserver/ledserver
