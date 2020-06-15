#!/bin/bash

# installs mermaid-cli

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath -s $0))

cd "$THIS_SCRIPT_DIR"

install_yarn() {
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt update && sudo apt install yarn
}

if command -v yarn; then
    :
else
    install_yarn
fi

yarn add @mermaid-js/mermaid-cli


#EOF
