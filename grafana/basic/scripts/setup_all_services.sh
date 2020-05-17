#!/bin/bash


export SUDO=sudo

SCRIPTDIR="$( dirname $( realpath $BASH_SOURCE ) )"
REPO_TOPDIR=$(realpath "$SCRIPTDIR/../")

system_setup() {
    $SUDO apt update -y
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
}

install_docker() {
    # copypasted docker install instructions from the official docs

    $SUDO apt-get update

    $SUDO apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | $SUDO apt-key add -

    $SUDO apt-key fingerprint 0EBFCD88

    $SUDO add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) \
        stable"

    # update is automatically done after add-apt-repository
    #$SUDO apt-get update

    $SUDO apt-get install -y docker-ce docker-ce-cli containerd.io

    $SUDO docker run hello-world

}

configure_docker () {
    # Set up bridge between docker containers
    $SUDO docker network create -d bridge grafana-net
}

setup_collectd () {
    $SUDO apt-get install -y collectd

    $SUDO cp -v $REPO_TOPDIR/rootfs/etc/collectd/collectd-server.conf /etc/collectd/collectd.conf
    $SUDO systemctl restart collectd
}

install_revproxy () {
    # start the reverse proxy container
    # TODO Migrate to docker compose
    sudo docker run --detach \
        --name nginx-proxy \
        --network grafana-net \
        --publish 80:80 \
        --publish 443:443 \
        --volume /etc/nginx/certs \
        --volume /etc/nginx/vhost.d \
        --volume /usr/share/nginx/html \
        --volume /var/run/docker.sock:/tmp/docker.sock:ro \
        jwilder/nginx-proxy
}

install_revproxy_ssl () {
    # start the letsencrypt companion
    # TODO Migrate to docker compose
    sudo docker run --detach \
        --name nginx-proxy-letsencrypt \
        --network grafana-net \
        --volumes-from nginx-proxy \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --env "DEFAULT_EMAIL=$EMAIL" \
        jrcs/letsencrypt-nginx-proxy-companion
}

run_graphite () {
    # TODO Migrate to docker compose
    #https://graphite.readthedocs.io/en/latest/install.html
    $SUDO docker run -d \
        --name graphite \
        --restart=always \
        --network grafana-net \
        -p 127.0.0.1:8880:80 \
        -p 2003-2004:2003-2004 \
        graphiteapp/graphite-statsd
        #-p 8880:80 \
        #-p 2023-2024:2023-2024 \
        #-p 8125:8125/udp \
        #-p 8126:8126 \
    $SUDO docker exec -it $($SUDO docker ps -aqf "name=^graphite$") \
        ip a
    $SUDO docker exec -it $($SUDO docker ps -aqf "name=^graphite$") \
        netstat -tunapl
}

setup_grafana() {
    $SUDO apt-get install -y apt-transport-https
    $SUDO apt-get install -y software-properties-common wget
    wget -q -O - https://packages.grafana.com/gpg.key | $SUDO apt-key add -
    $SUDO add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"

    $SUDO apt-get install grafana
    $SUDO systemctl daemon-reload
    $SUDO systemctl enable grafana-server.service
    $SUDO systemctl start grafana-server
    $SUDO systemctl status grafana-server
    sleep 1
    $SUDO grafana-cli admin reset-admin-password $GRAFANA_ADMIN_PASSWORD
}


run_grafana_docker() {
    # TODO Migrate to docker compose
    # https://grafana.com/docs/grafana/latest/installation/docker/

    # TODO: Persistent storage?
    $SUDO docker volume create grafana-storage

    #TODO: Why is this not connecting to graphite???!!!!
    #https://github.com/baverman/grafana-stack
    #https://www.linode.com/docs/uptime/monitoring/install-graphite-and-grafana/

    $SUDO docker run -d \
        --name grafana \
        --network grafana-net \
        -p 3000:3000 \
        -v grafana-storage:/var/lib/grafana \
        --env "VIRTUAL_HOST=$DOMAIN" \
        --env "LETSENCRYPT_HOST=$DOMAIN" \
        grafana/grafana

    # Reset admin password
    sleep 1 # may be needed?

    $SUDO docker exec -it $($SUDO docker ps -aqf "name=^grafana$") \
        grafana-cli admin reset-admin-password $GRAFANA_ADMIN_PASSWORD
    $SUDO docker exec -it $($SUDO docker ps -aqf "name=^grafana$") \
        ip a
}

prune_docker () {
    $SUDO docker container rm -f graphite grafana
    $SUDO docker volume prune
}


#Configurable stuff starts here
###############################

export DOMAIN="grafana-ls.ssfivy.com"
export EMAIL="me@$DOMAIN"
export GRAFANA_ADMIN_PASSWORD="the-sacred-texts"

#system_setup
#install_docker
#configure_docker
setup_collectd
#install_revproxy
#install_revproxy_ssl
#setup_grafana
run_graphite
run_grafana_docker


#prune_docker
