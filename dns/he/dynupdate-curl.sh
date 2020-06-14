#!/bin/bash

# Uses curl to update hurricane electric dynamic dns records

set -e

HE_DOMAIN_NAME=$1

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

cd "$THIS_SCRIPT_DIR"

# Try to autodetect physical interface & our IP address.
# This is rather iffy and probably will fail in more complex systems
# in which case if I'm serious about trying to making this client work I should rewrite this

# Generate list of all network interfaces, then detect the real one (the one that has MAC)
# Then query the ip address of that interface
# https://unix.stackexchange.com/a/420721
# https://unix.stackexchange.com/a/87470
for i in $(ip -o link show | awk -F': ' '{print $2}'); do \
    mac=$(ethtool -P "$i" | cut -d' ' -f 3)
    if [[ $mac != "00:00:00:00:00:00" ]]; then
        CURRENT_IPV4_ADDRESS="$(ip -f inet  addr show "$i" | grep -Po 'inet \K[\d.]+')" || true
        CURRENT_IPV6_ADDRESS="$(ip -f inet6 addr show "$i" | grep -Po 'inet \K[\d.]+')" || true
    fi
done

echo "Detected IPv4 address: $CURRENT_IPV4_ADDRESS"
echo "Detected IPv6 address: $CURRENT_IPV6_ADDRESS"

if   [[ "_$HE_DOMAIN_NAME" == "_" ]]; then
    echo "Missing argument: (sub)domain name "
    exit 1
elif [[ "_$HE_DYNDNS_PASSWORD" == "_" ]]; then
    echo "Missing environment variable HE_DYNDNS_PASSWORD"
    exit 1
fi

if [[ "_$CURRENT_IPV4_ADDRESS" != "_" ]]; then
curl "https://dyn.dns.he.net/nic/update" \
    -d "hostname=$HE_DOMAIN_NAME" \
    -d "password=$HE_DYNDNS_PASSWORD" \
    -d "myip=$CURRENT_IPV4_ADDRESS"
fi
if [[ "_$CURRENT_IPV6_ADDRESS" != "_" ]]; then
curl "https://dyn.dns.he.net/nic/update" \
    -d "hostname=$HE_DOMAIN_NAME" \
    -d "password=$HE_DYNDNS_PASSWORD" \
    -d "myip=$CURRENT_IPV6_ADDRESS"
fi
