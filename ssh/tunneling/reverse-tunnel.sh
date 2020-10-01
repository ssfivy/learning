#!/bin/bash

# SSH Tunneling
# Experiments with SSH Forward and Reverse Tunneling feature to work easily through firewalls etc

# Better explanation: https://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work


# run this from inside the appserver

# Set up reverse tunnel
ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -F 2222:10.1.1.20:22 \
    bastion1user@10.1.1.25

# now go run the reverse-access.sh script from the client
