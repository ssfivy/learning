#!/bin/bash

# Run this from within vagrant VM to install configs

# mosquitto config
sudo cp /vagrant/learning.conf /etc/mosquitto/conf.d

# CA certs
sudo cp /vagrant/ca-rsa/* /etc/mosquitto/ca_certificates

# server side TLS keys
sudo cp /vagrant/server-rsa/server.crt /etc/mosquitto/server.crt
sudo cp /vagrant/server-rsa/server.key /etc/mosquitto/server.key

# restart daemon
sudo systemctl restart mosquitto
