#!/usr/bin/env bash
set -o nounset
set -o errexit
set -o pipefail

readonly CONSUL_AGENT_NAME="consul-agent-test"
readonly CONSUL_TEMPLATE_NAME="consul-template-test"
readonly CONSUL_NETWORK_NAME="consul-network-test"
readonly CONSUL_TEMPLATE_IMG_NAME="ypr-consul-template"
readonly NETWORK_ADDRESS="10.123.100.76"

help() {
    echo "Usage"
    echo "./launch [start | remove | help]"
    exit 0
}

nextip() {
    local IP=$1
    local IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    local NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    local NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)

    echo "$NEXT_IP"
}

# Build the Docker image for consul-template with dind.
build() {
    docker build -t "${CONSUL_TEMPLATE_IMG_NAME}" .
}

# Remove the stack if needed
remove() {
    docker rm -f "${CONSUL_AGENT_NAME}" "${CONSUL_TEMPLATE_NAME}" || true
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
        -v `pwd`/config:/generated \
        -v /var/run/docker.sock:/var/run/docker.sock \
            "${CONSUL_TEMPLATE_IMG_NAME}" \
                -consul-addr "${FIRST_IP}":8500 \
                -template "/generated/config-dev.tpl:/generated/dev.json:docker ps" \
                -template "/generated/config-prod.tpl:/generated/prod.json" \
                -log-level info
}

# Add example keys into consul
insert_default_keys() {
    curl --request PUT --data http://prod.mycompany.com http://"${FIRST_IP}":8500/v1/kv/api.endpoint.prod
    curl --request PUT --data http://dev.mycompany.com http://"${FIRST_IP}":8500/v1/kv/api.endpoint.dev
}

start() {
    remove
    build
    start_agent
    start_template
    echo "You can visit: http://${FIRST_IP}:8500"
    sleep 5
    insert_default_keys

     #watch -n 1 cat ./config/dev.json ./config/prod.json
}

main() {
    readonly GATEWAY_IP=$(nextip $NETWORK_ADDRESS)
    readonly FIRST_IP=$(nextip $GATEWAY_IP)
    readonly SECOND_IP=$(nextip $FIRST_IP)

    if [ -n "$(type -t $*)" ] && [ "$(type -t $*)" = function ]; then
        "$*"
    else
        help
    fi
}

main $*


