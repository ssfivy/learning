#!/bin/bash

# SSH Tunneling
# Experiments with SSH Forward and Reverse Tunneling feature to work easily through firewalls etc

# Better explanation: https://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work

# Forward tunneling:
# Created by the appserver performing an ssh call to bastion1.
# After successful call tunnel works like this:
#
#    Appserver                      bastion1             client
#    10.1.1.30                     10.1.1.25            10.1.1.20
#   tunnel entry ---|firewall|---> tunnel exit
#    port 2222                     redirected to -------> port 22
#
# Once setup, anything in appserver that gets sent to port 2222
# will magically appear at client on port 22.
# So in appserver you can ssh clientuser@localhost -p 2222 and it is basically
# doing the same as ssh clientuser @10.1.1.20 from anywhere else.

# Run this script from appserver

# Set up forward tunnel
ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -F 2222:10.1.1.20:22 \
    bastion1user@10.1.1.25

# Run ssh through tunnel
ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -p 2222 \
    clientuser@localhost \
    " whoami; uname -a ; ip a"
