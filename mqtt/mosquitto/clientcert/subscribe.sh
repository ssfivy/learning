#!/bin/bash

# we want to do plenty of array expansion to arguments
# shellcheck disable=SC2068

# subscribe to test server to see if our messages got through

SERVER_URI=test.mosquitto.org
SERVER_PORT=1883

PARAMS=(
-d # enable debug messages
-h $SERVER_URI # host to connect to
-p $SERVER_PORT # port to connect to
-q 1 # qos 1
-t learning/clientcert
-v
)
mosquitto_sub  ${PARAMS[@]}
