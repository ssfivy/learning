#!/bin/bash
# Please run this from within the guest VM

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -xe

# Generate unique-ish machine identifier
gen-deviceid () {
    MAC_ADDRESS_NOCOLON=$(cat "/sys/class/net/$(ls -1 /sys/class/net | grep 'enp\|eth' | head -n1)/address" | sed 's/://g')
    echo "$(hostname)-$MAC_ADDRESS_NOCOLON"
}

# Install collectd config
config-collectd () {
sudo install -m 0444 "$SCRIPTDIR/etc/collectd.conf" /etc/collectd/collectd.conf
sudo sed -i "s/.*Hostname .*/Hostname \"$(gen-deviceid)\"/" /etc/collectd/collectd.conf
sudo systemctl restart collectd
}

install-fluentbit () {
# Main instruction: https://docs.fluentbit.io/manual/installation/linux/ubuntu
wget -qO - https://packages.fluentbit.io/fluentbit.key | sudo apt-key add -
SHORT_CODENAME=$(lsb_release --codename --short)
echo "deb https://packages.fluentbit.io/ubuntu/$SHORT_CODENAME $SHORT_CODENAME main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install td-agent-bit
sudo systemctl enable td-agent-bit
}

# Install fluentbit config
config-fluentbit() {
sudo install -m 0444 "$SCRIPTDIR/etc/fluentbit.conf" /etc/td-agent-bit/td-agent-bit.conf
sudo sed -i "s/.*    Record host .*/    Record host $(gen-deviceid)/" /etc/td-agent-bit/td-agent-bit.conf
sudo systemctl restart td-agent-bit
}

#install-fluentbit

config-collectd
config-fluentbit
