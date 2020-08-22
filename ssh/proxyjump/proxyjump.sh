#!/bin/bash

# SSH ProxyJump
# Experiments with SSH Proxyjump feature to work easily through bastion host
# Based on https://www.redhat.com/sysadmin/ssh-proxy-bastion-proxyjump

# Diagram of ssh:
#
# client -> bastion1 -> bastion2 -> appserver
#
#

ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -J regularbloke@10.1.1.20,importantbloke@10.1.1.25 \
    bigwig@10.1.1.30
