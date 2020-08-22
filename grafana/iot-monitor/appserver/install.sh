#!/bin/bash
# Please run this from within the guest VM

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Install fluentd
fluentd-install () {
# Note: For our small scale install we skip all recommendations here: https://docs.fluentd.org/installation/before-install
# Follow those when doing production installs!
curl -L https://toolbelt.treasuredata.com/sh/install-ubuntu-bionic-td-agent4.sh | sh
}

# Install fluentd config
fluentd-config () {
sudo install -m 644 "$SCRIPTDIR/etc/fluentd.conf" /etc/td-agent/td-agent.conf
sudo systemctl restart td-agent.service
}

#fluentd-install
fluentd-config
