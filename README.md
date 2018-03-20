# Consul Template Example

[![Build Status](https://travis-ci.org/ypereirareis/consul-template-example.svg?branch=master)](https://travis-ci.org/ypereirareis/consul-template-example)

An example configuration to manage configuration files parameters, with consul and consul template.

* We use the key/value store feature of consul to create/update/delete configurations.
* We use consul-template to generate configuration files from templates and key/values items saved.

**This project is a demo, DO NOT use it directly in production.**

## Start the project

```bash
git clone git@github.com:ypereirareis/consul-template-example.git && cd consul-template-example
chmod +x launch.sh && ./launch.sh start
```

If you want help:

```bash
./launch.sh help
```

## What this script is doing

The `launch.sh` script is doing many things in this order:

* Try to clean up the stack if needed (already started before)
* Create a custom network with specific subnet ip range.
* Build a custom dind image with consul-template inside.
* Start a container running consul.
* Start a container running consul-template.
* Add two keys in consul for the demo.

The consul GUI is accessible at (by default): [http://10.123.100.78:8500](http://10.123.100.78:8500)  
Go to the key/value menu item [http://10.123.100.78:8500/ui/#/dc1/kv/](http://10.123.100.78:8500/ui/#/dc1/kv/) and update key values.

Then have a look at your configuration files (by default):

* ./config/dev.json
* ./config/prod.json

In the script you can configure your own:

* consul container name => `CONSUL_AGENT_NAME`
* consul-template container name => `CONSUL_TEMPLATE_NAME`
* custom consul-template image name => `CONSUL_TEMPLATE_IMG_NAME`
* network name for this docker project => `CONSUL_NETWORK_NAME`
* network ip address/range for this docker project => `CONSUL_NETWORK_ADDRESS`

**Of course, feel free to change anything else at your own risks.**

## Remove the stack

```bash
./launch.sh remove
```

## Tests

```bash
chmod +x tests.sh && ./tests.sh
```

# LICENSE

MIT License

Copyright (c) 2018 Yannick Pereira-Reis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.