#!/bin/bash

# we want to do plenty of array expansion to arguments
#shellcheck disable=SC2068

SERVER_URI='localhost'
SERVER_PORT=8883

CA_FOLDER=ca-rsa
CLIENT_FOLDER=client-rsa
SERVER_FOLDER=server-rsa


# Test publishing through TLS but no client cert
PARAMS=(
--cafile $CA_FOLDER/CA.Root.pem
-d #enable debug messages
-h $SERVER_URI # host to connect to
-p $SERVER_PORT # port to connect to
-q 1 # qos 1
-t learning/clientcert
-m "hellothere_tls"
)
mosquitto_pub  ${PARAMS[@]}

# Test publishing through TLS with client cert
PARAMS=(
--cafile $CA_FOLDER/CA.Root.pem
--cert $CLIENT_FOLDER/client.crt
--key $CLIENT_FOLDER/client.key
-d #enable debug messages
-h $SERVER_URI # host to connect to
-p $SERVER_PORT # port to connect to
-q 1 # qos 1
-t learning/clientcert
-m "hellothere_tls_clientcert"
)
mosquitto_pub  ${PARAMS[@]}
