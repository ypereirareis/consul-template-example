#!/usr/bin/env bash
set -eu

CONSUL_AGENT_NAME="consul-agent-test"
CONSUL_TEMPLATE_NAME="consul-template-test"
CONSUL_NETWORK_NAME="consul-network-test"

NETWORK_ADDRESS="10.123.100.76"
FIRST_IP=""
SECOND_IP=""

# Remove the stack
remove() {
    docker rm -f "${CONSUL_AGENT_NAME}" || true
    docker rm -f "${CONSUL_TEMPLATE_NAME}" || true
    docker network rm "${CONSUL_NETWORK_NAME}" || true
    docker network create --subnet="${NETWORK_ADDRESS}/24" "${CONSUL_NETWORK_NAME}"
}

# Run consul agent
start_agent() {
    docker run -d --net="${CONSUL_NETWORK_NAME}" \
        --ip="${FIRST_IP}" \
        --name="${CONSUL_AGENT_NAME}" \
        -p 8400:8400 -p 8500:8500 -p 54:8600/udp \
        -h node-1 \
            progrium/consul \
                -server -client 0.0.0.0 -bootstrap
}

# Run consul template
start_template() {
    docker run -d --net="${CONSUL_NETWORK_NAME}" \
        --ip="${SECOND_IP}" \
        --name="${CONSUL_TEMPLATE_NAME}" \
        -v `pwd`/config:/tmp \
            hashicorp/consul-template:alpine \
                -consul-addr "${FIRST_IP}":8500 \
                -template "/tmp/config-dev.tpl:/tmp/dev.json" \
                -template "/tmp/config-prod.tpl:/tmp/prod.json" \
                -log-level info
}

# Add example keys into consul
insert_default_keys() {
    curl --request PUT --data http://prod.mycompany.com http://"${FIRST_IP}":8500/v1/kv/api.endpoint.prod
    curl --request PUT --data http://dev.mycompany.com http://"${FIRST_IP}":8500/v1/kv/api.endpoint.dev
}

start() {
    remove
    start_agent
    start_template
    echo "You can visit: http://${FIRST_IP}:8500"
    sleep 5
    insert_default_keys

     watch -n 1 cat ./config/dev.json ./config/prod.json
}

help() {
    echo "Usage"
    echo "./launch [start | remove | help]"
    exit 0
}

nextip() {
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}


GATEWAY_IP=$(nextip $NETWORK_ADDRESS)
FIRST_IP=$(nextip $GATEWAY_IP)
SECOND_IP=$(nextip $FIRST_IP)


[[ "" ==  "$*" ]] && help || "$*"






