#!/bin/bash

set -xe

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")

mkdir -p $HOME/.config/systemd/user

ln -s -f -T $THIS_SCRIPT_DIR/hello.service $HOME/.config/systemd/user/hello.service
ln -s -f -T $THIS_SCRIPT_DIR/hello.timer   $HOME/.config/systemd/user/hello.timer
systemctl --user daemon-reload
systemctl --user enable hello.timer
systemctl --user start  hello.timer
systemctl --user --no-pager status hello.timer
systemctl --user list-timers

# We don't clean up here, but it should be obvious what to do.


#EOF
