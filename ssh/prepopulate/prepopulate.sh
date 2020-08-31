#!/bin/bash

## WARNING: HArdcoded values here!
USERNAME="johnsmith"
SERVER_ADDRESS="10.1.1.30" # Note: This is needed at keygen time for known_hosts!

heredoc() {
cat <<'EOH'
prepopulate.sh — generate and install a matching pair of ssh keys that will connect without any authorization

Usage:
  prepopulate.sh --generate
  prepopulate.sh --serverinstall # WARNING: Will overwrite ssh server keys!
  prepopulate.sh --clientinstall
  prepopulate.sh --connect
EOH
}

set -e

THIS_SCRIPT_DIR=$(dirname "$(realpath -s "$0")")
TOPDIR=$THIS_SCRIPT_DIR/lrn_build


SERVER_CFGSSH="$TOPDIR/etc/ssh"
SERVER_DOTSSH="$TOPDIR/.ssh_server"
CLIENT_DOTSSH="$TOPDIR/.ssh_client"


generate () {
    rm -r "$TOPDIR"
    mkdir -p "$TOPDIR" "$SERVER_CFGSSH" "$SERVER_DOTSSH" "$CLIENT_DOTSSH"

    # Generated ssh server keys
    # Example https://serverfault.com/a/471346
    ssh-keygen -q -N "" -t rsa -b 2048 -f "$SERVER_CFGSSH/ssh_host_rsa_key"

    # Generate client keys
    #automatic keygen from  https://unix.stackexchange.com/a/69318
    ssh-keygen -b 2048 -t rsa -f "$CLIENT_DOTSSH/tunnelkey" -q -N ""

    # server: prepopulate authorized_keys
    # This doesnt populate things both way since only client -> server is needed
    cat "$CLIENT_DOTSSH/tunnelkey.pub" >> "$SERVER_DOTSSH/authorized_keys"

    # client: Add server to known_hosts
    pubkey=$(cat "$SERVER_CFGSSH/ssh_host_rsa_key.pub")
    echo "$SERVER_ADDRESS $pubkey" >> "$CLIENT_DOTSSH/known_hosts"
}

populate_server () {
    mkdir -p "$HOME/.ssh" "/etc/ssh"
    sudo cp "$SERVER_CFGSSH/ssh_host_rsa_key"       "/etc/ssh/ssh_host_rsa_key"
    sudo cp "$SERVER_CFGSSH/ssh_host_rsa_key.pub"   "/etc/ssh/ssh_host_rsa_key.pub"
    cat "$SERVER_DOTSSH/authorized_keys"    >>      "$HOME/.ssh/authorized_keys"

    # Check permission is correct
    # see https://stackoverflow.com/questions/6377009/adding-a-public-key-to-ssh-authorized-keys-does-not-log-me-in-automatically
    chmod 700   "$HOME/.ssh"
    sudo chmod 600   "/etc/ssh/ssh_host_rsa_key"
    sudo chmod 644   "/etc/ssh/ssh_host_rsa_key.pub"
    chmod 644   "$HOME/.ssh/authorized_keys"
    chmod go-w  "$HOME"
}

populate_client () {
    mkdir -p "$HOME/.ssh"
    cp  "$CLIENT_DOTSSH/tunnelkey"      "$HOME/.ssh/tunnelkey"
    cp  "$CLIENT_DOTSSH/tunnelkey.pub"  "$HOME/.ssh/tunnelkey.pub"
    cat "$CLIENT_DOTSSH/known_hosts" >> "$HOME/.ssh/known_hosts"

    # Check permission is correct
    chmod 700   "$HOME/.ssh"
    chmod 600   "$HOME/.ssh/tunnelkey"
    chmod 644   "$HOME/.ssh/tunnelkey.pub"
    chmod 644   "$HOME/.ssh/known_hosts"
    chmod go-w  "$HOME"
}

tunnel_create () {
    /bin/ssh \
        -i "$HOME/.ssh/tunnelkey" \
        -NT \
        -o ServerAliveInterval=60 \
        -L 2003:localhost:2003 \
        "${USERNAME}@${SERVER_ADDRESS}"
}

# Bonus: Example on how to parse arguments in pure bash
while (( $# )); do
  case "$1" in
    -h|--help)
      heredoc
      exit
      ;;

    --generate)
      generate
      exit
      ;;

    --server)
      populate_server
      exit
      ;;

    --client)
      populate_client
      exit
      ;;

    --connect)
      tunnel_create
      exit
      ;;

    *)
    >&2 printf "%s: unrecognized argument\n" "$1"
    >&2 usage
    exit 1
  esac

  shift
done


#EOF
