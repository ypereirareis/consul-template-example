#!/usr/bin/env bash
set -eu

CONSUL_AGENT_NAME="consul-agent-test"
CONSUL_TEMPLATE_NAME="consul-template-test"
CONSUL_NETWORK_NAME="consul-network-test"

# Remove the stack
remove() {
    docker rm -f "${CONSUL_AGENT_NAME}" || true
    docker rm -f "${CONSUL_TEMPLATE_NAME}" || true
    docker network rm "${CONSUL_NETWORK_NAME}" || true
    docker network create --subnet=10.1.10.50/29 "${CONSUL_NETWORK_NAME}"
}

# Run consul agent
start_agent() {
    docker run -d --net="${CONSUL_NETWORK_NAME}" \
        --ip=10.1.10.52 \
        --name="${CONSUL_AGENT_NAME}" \
        -p 8400:8400 -p 8500:8500 -p 54:8600/udp \
        -h node-1 \
            progrium/consul \
                -server -client 0.0.0.0 -bootstrap
}

# Run consul template
start_template() {
    docker run -d --net="${CONSUL_NETWORK_NAME}" \
        --ip=10.1.10.53 \
        --name="${CONSUL_TEMPLATE_NAME}" \
        -v `pwd`/config:/tmp \
            hashicorp/consul-template:alpine \
                -consul-addr 10.1.10.52:8500 \
                -template "/tmp/config-dev.tpl:/tmp/dev.json" \
                -template "/tmp/config-prod.tpl:/tmp/prod.json" \
                -log-level info
}

# Add example keys into consul
insert_default_keys() {
    curl --request PUT --data http://prod.mycompany.com http://10.1.10.52:8500/v1/kv/api.endpoint.prod
    curl --request PUT --data http://dev.mycompany.com http://10.1.10.52:8500/v1/kv/api.endpoint.dev
}

start() {
    remove
    start_agent
    start_template
    echo "You can visit: http://10.1.10.52:8500"
    sleep 5
    insert_default_keys

    # watch -n 1 cat ./config/dev.json ./config/prod.json
}

help() {
    echo "Usage"
    echo "./launch [start | remove | help]"
    exit 0
}

[[ "" ==  "$*" ]] && help || "$*"






