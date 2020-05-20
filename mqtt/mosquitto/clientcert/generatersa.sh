#!/bin/bash

# we want to do plenty of array expansion to arguments
#shellcheck disable=SC2068

CA_FOLDER=ca-rsa
CLIENT_FOLDER=client-rsa
SERVER_FOLDER=server-rsa

rm -rf $CA_FOLDER $CLIENT_FOLDER $SERVER_FOLDER
mkdir -p $CA_FOLDER $CLIENT_FOLDER $SERVER_FOLDER

# Genrate client and server certificates
BOLD=$(tput bold)
CLEAR=$(tput sgr0)

# CA side
#########
pushd $CA_FOLDER

echo -e "${BOLD}Generating RSA AES-256 Private Key for Root Certificate Authority${CLEAR}"
PARAMS=(
    genrsa                          # Generate RSA private key
    -out CA.Root.key    # output key to this file
    4096                            # generate this number of bits
)
openssl ${PARAMS[@]}

echo -e "${BOLD}Generating Certificate for Root Certificate Authority${CLEAR}"
PARAMS=(
    req                 #create selfsigned certificate as root CA
    -x509               # Create selfsigned cert instead of a CSR
    -new                # Generate new cert request
    -nodes              # if private key created, do not encrypt it
    -key CA.Root.key    # Read private key from this file
    -sha256             #?????
    -days 1825          # number of days to certify the certs
    -out CA.Root.pem    # output filename
    # prefill subject information
    -subj "/C=US/ST=NewYork/L=Manhattan/O=JoestarHoldings/OU=Hamon/CN=Nanii/emailAddress=jojo@joestar.com"
)
openssl ${PARAMS[@]}
popd

# Server side
#############
pushd $SERVER_FOLDER
echo -e "${BOLD}Generating RSA Private Key for Server Certificate${CLEAR}"
PARAMS=(
    genrsa                      # Generate RSA private key
    -out server.key # output key to this file
    4096                        # generate this number of bits
)
openssl ${PARAMS[@]}


echo -e "${BOLD}Generating Certificate Signing Request for Server Certificate${CLEAR}"
PARAMS=(
    req                         # create CSR
    -new                        # Generate new cert request
    -key server.key # Read private key from this file
    -out server.csr # output filename
    # prefill subject information
    -subj "/C=US/ST=NewYork/L=Manhattan/O=JoestarHoldings/OU=Stand/CN=localhost/emailAddress=jojo@joestar.com"
)
openssl ${PARAMS[@]}

echo -e "${BOLD}Generating Certificate for Server Certificate${CLEAR}"
PARAMS=(
    x509                                    # certificate display and signing utility
    -req
    -in server.csr
    -CA ../$CA_FOLDER/CA.Root.pem
    -CAkey ../$CA_FOLDER/CA.Root.key
    -CAcreateserial
    -out server.crt
    -days 1825
    -sha256
    #-extfile server.ext
)
openssl ${PARAMS[@]}

popd

# Client side
#############
pushd $CLIENT_FOLDER
echo -e "${BOLD}Generating RSA Private Key for Client Certificate${CLEAR}"
PARAMS=(
    genrsa
    -out client.key
    4096
)
openssl ${PARAMS[@]}

echo -e "${BOLD}Generating Certificate Signing Request for Client Certificate${CLEAR}"
PARAMS=(
    req
    -new
    -key client.key
    -out client.csr
    -subj "/C=US/ST=NewYork/L=Manhattan/O=JoestarHoldings/OU=Stand/CN=reroRero/emailAddress=kakyoin@joestar.com"
)
openssl ${PARAMS[@]}

echo -e "${BOLD}Generating Certificate for Client Certificate${CLEAR}"
PARAMS=(
    x509
    -req
    -in client.csr
    -CA ../$CA_FOLDER/CA.Root.pem
    -CAkey ../$CA_FOLDER/CA.Root.key
    -CAcreateserial
    -out client.crt
    -days 1825
    -sha256
)
openssl ${PARAMS[@]}

popd
