#!/bin/bash

# Get the phusion ssh key
# See https://github.com/phusion/baseimage-docker#ssh_keys

curl -o insecure_key -fSL https://github.com/phusion/baseimage-docker/raw/master/image/services/sshd/keys/insecure_key
chmod 600 insecure_key
