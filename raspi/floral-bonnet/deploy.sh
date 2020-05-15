#!/bin/bash

# deploy code to raspi and execute it
# assuems ssh is available and ssh using keys is alreasy setup;
# if not, run ssh-copy-id pi@IPADDR


IPADDR=192.168.89.102
USER=pi

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))

ssh $USER@$IPADDR mkdir -p /home/$USER/floral-bonnet
scp -r $THIS_SCRIPT_DIR/* $USER@$IPADDR:/home/$USER/floral-bonnet
ssh $USER@$IPADDR /home/$USER/floral-bonnet/main.py
