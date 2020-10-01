#!/bin/bash

# SSH Tunneling
# Experiments with SSH Forward and Reverse Tunneling feature to work easily through firewalls etc

# Better explanation: https://unix.stackexchange.com/questions/46235/how-does-reverse-ssh-tunneling-work

# Reverse tunneling:
# Created by the appserver performing an ssh call to bastion1.
# After successful call tunnel works like this:
#
#    Appserver                      bastion1             client
#    10.1.1.30                     10.1.1.25            10.1.1.20
#   tunnel exit <---|firewall|--- tunnel entry
#    port 22                       port 2222  <--------- accessing tunnel
#
# Once setup, anything in bastion1 that gets sent to port 2222
# will magically show up at appserver on port 22,
# so anything in appserver that listens on port 22 receives the packet.
# So in client you can ssh appserveruser@localhost -p 2222 and it is basically
# doing the same as ssh appserveruser@10.1.1.30 from within the firewall


# Create the tunnel beforehand, then
# run this from inside the client

ssh \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -p 2222 \
    appserveruser@localhost \
    " whoami; uname -a ; ip a"
