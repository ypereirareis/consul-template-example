#!/usr/bin/env bash
set -eux

./launch.sh start

# Give time to consult-template to generate files
sleep 2

# Check that files were generated after consul-template has started
cat ./config/dev.json | grep "http://dev.mycompany.com"
cat ./config/prod.json | grep "http://prod.mycompany.com"

curl --request PUT --data PROD http://10.123.100.78:8500/v1/kv/api.endpoint.prod
curl --request PUT --data DEV http://10.123.100.78:8500/v1/kv/api.endpoint.dev

# Give time to consult-template to generate files
sleep 2

# Check that files were updated after we update keys
cat ./config/dev.json | grep "DEV"
cat ./config/prod.json | grep "PROD"

# Remove the stack
./launch.sh remove