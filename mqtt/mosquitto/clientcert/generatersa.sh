#!/bin/bash

# we want to do plenty of array expansion to arguments
#shellcheck disable=SC2068

SERVER_URI=test.mosquitto.org
SERVER_PORT=8883

CA_FOLDER=ca-rsa

rm -rf $CA_FOLDER
mkdir -p $CA_FOLDER

# Get CA certificate
pushd $CA_FOLDER
wget -c http://test.mosquitto.org/ssl/mosquitto.org.crt
popd


# Test publishing through TLS but no client cert
PARAMS=(
--cafile $CA_FOLDER/mosquitto.org.crt
-d #enable debug messages
-h $SERVER_URI # host to connect to
-p $SERVER_PORT # port to connect to
-q 1 # qos 1
-t learning/clientcert
-m "hellothere_"
)
mosquitto_pub  ${PARAMS[@]}
