# Quorum PCF 7nodes example

## Pre-requisites

* Cloud Foundry CLI https://github.com/cloudfoundry/cli
* Account on Cloud Foundry environment with [Container-to-Container networking](https://docs.pivotal.io/pivotalcf/1-10/concepts/understand-cf-networking.html) enabled
  * Recommended: Pivotal Web Services (you may need to [request C2C networking](mailto:support@run.pivotal.io?subject=Access%20to%20Container%20Networking%20on%20PWS&body=Can%20I%20please%20get%20access%20to%20Container%20Networking%20stack%20on%20PWS%3F%20Thank%20you.)
  * Supported on [Pivotal Cloud Foundry 1.10](https://docs.pivotal.io/pivotalcf/1-10/pcf-release-notes/index.html) and higher
* Log in and target an org and space with at least 5GB memory

## Deployment

1. Create a new empty directory and `cd` into it
```bash
mkdir my-cluster
cd my-cluster
```

1. Make a directory called `deploy` with a subdirectory called `bin` inside the empty directory
```bash
mkdir -p deploy/bin
```

1. Download the latest release binaries and libraries from quorum pipeline to `deploy/bin`

https://github.com/micahyoung/quorum-pipeline/releases/

Download `bootnode`, `constellation-node`, `geth`, `libsodium.*` and save to `deploy/bin`

1. Change all binaries to executable
```bash
chmod +x deploy/bin/*
```

1. Clone 7nodes examples
```bash
git clone https://github.com/jpmorganchase/quorum-examples
```

1. Copy 7nodes contents to `deploy`
```bash
cp -r quorum-examples/examples/7nodes/* deploy/
```

1. Clone this repo
```bash
git clone https://github.com/micahyoung/quorum-pcf-7nodes.git
```

1. Copy `run-scripts` contents to `deploy`
```bash
cp -r quorum-pcf-7nodes/run-scripts/* deploy/
```

1. Create an empty user-provided-service for the apps
```bash
cf create-user-provided-service ip-service -p '{}'
```

1. Deploy the bootnode
```bash
cf push -p deploy/ -f pipelines/manifests/bootnode-manifest.yml
```

1. Update the service with the bootnode's IP
```bash
BOOTNODE_IP=$(cf ssh bootnode -c "hostname --ip-address")

cf update-user-provided-service ip-service -p "{
  \"BOOTNODE_IP\": \"$BOOTNODE_IP\"
}"
```

1. Deploy node-1
```
cf push -p deploy/ -f pipelines/manifests/node1-manifest.yml
```

1. Update the service with the bootnode's and node-1's IPs
```bash
BOOTNODE_IP=$(cf ssh bootnode -c "hostname --ip-address")
OTHER_NODE_IP=$(cf ssh node-1 -c "hostname --ip-address")

cf update-user-provided-service ip-service -p "{
  \"BOOTNODE_IP\": \"$BOOTNODE_IP\",
  \"OTHER_NODE_IP\": \"$OTHER_NODE_IP\"
}"
```

1. Push the remaining apps
```bash
cf push -p deploy/ -f pipelines/manifests/node2-manifest.yml
cf push -p deploy/ -f pipelines/manifests/node3-manifest.yml
cf push -p deploy/ -f pipelines/manifests/node4-manifest.yml
cf push -p deploy/ -f pipelines/manifests/node5-manifest.yml
cf push -p deploy/ -f pipelines/manifests/node6-manifest.yml
cf push -p deploy/ -f pipelines/manifests/node7-manifest.yml
```

1. Add all the container to container networking rules (copy, paste, wait...)
```bash
cf allow-access node-2   node-1   --protocol tcp --port 9000
cf allow-access node-3   node-1   --protocol tcp --port 9000
cf allow-access node-4   node-1   --protocol tcp --port 9000
cf allow-access node-5   node-1   --protocol tcp --port 9000
cf allow-access node-6   node-1   --protocol tcp --port 9000
cf allow-access node-7   node-1   --protocol tcp --port 9000
cf allow-access bootnode node-1   --protocol udp --port 21000
cf allow-access node-2   node-1   --protocol udp --port 21000
cf allow-access node-3   node-1   --protocol udp --port 21000
cf allow-access node-4   node-1   --protocol udp --port 21000
cf allow-access node-5   node-1   --protocol udp --port 21000
cf allow-access node-6   node-1   --protocol udp --port 21000
cf allow-access node-7   node-1   --protocol udp --port 21000
cf allow-access bootnode node-1   --protocol tcp --port 21000
cf allow-access node-2   node-1   --protocol tcp --port 21000
cf allow-access node-3   node-1   --protocol tcp --port 21000
cf allow-access node-4   node-1   --protocol tcp --port 21000
cf allow-access node-5   node-1   --protocol tcp --port 21000
cf allow-access node-6   node-1   --protocol tcp --port 21000
cf allow-access node-7   node-1   --protocol tcp --port 21000
cf allow-access bootnode node-1   --protocol tcp --port 22000
cf allow-access node-2   node-1   --protocol tcp --port 22000
cf allow-access node-3   node-1   --protocol tcp --port 22000
cf allow-access node-4   node-1   --protocol tcp --port 22000
cf allow-access node-5   node-1   --protocol tcp --port 22000
cf allow-access node-6   node-1   --protocol tcp --port 22000
cf allow-access node-7   node-1   --protocol tcp --port 22000

cf allow-access node-1   node-2   --protocol tcp --port 9001
cf allow-access node-3   node-2   --protocol tcp --port 9001
cf allow-access node-4   node-2   --protocol tcp --port 9001
cf allow-access node-5   node-2   --protocol tcp --port 9001
cf allow-access node-6   node-2   --protocol tcp --port 9001
cf allow-access node-7   node-2   --protocol tcp --port 9001
cf allow-access bootnode node-2   --protocol udp --port 21001
cf allow-access node-1   node-2   --protocol udp --port 21001
cf allow-access node-3   node-2   --protocol udp --port 21001
cf allow-access node-4   node-2   --protocol udp --port 21001
cf allow-access node-5   node-2   --protocol udp --port 21001
cf allow-access node-6   node-2   --protocol udp --port 21001
cf allow-access node-7   node-2   --protocol udp --port 21001
cf allow-access bootnode node-2   --protocol tcp --port 21001
cf allow-access node-1   node-2   --protocol tcp --port 21001
cf allow-access node-3   node-2   --protocol tcp --port 21001
cf allow-access node-4   node-2   --protocol tcp --port 21001
cf allow-access node-5   node-2   --protocol tcp --port 21001
cf allow-access node-6   node-2   --protocol tcp --port 21001
cf allow-access node-7   node-2   --protocol tcp --port 21001
cf allow-access bootnode node-2   --protocol tcp --port 22001
cf allow-access node-1   node-2   --protocol tcp --port 22001
cf allow-access node-3   node-2   --protocol tcp --port 22001
cf allow-access node-4   node-2   --protocol tcp --port 22001
cf allow-access node-5   node-2   --protocol tcp --port 22001
cf allow-access node-6   node-2   --protocol tcp --port 22001
cf allow-access node-7   node-2   --protocol tcp --port 22001

cf allow-access node-1   node-3   --protocol tcp --port 9002
cf allow-access node-2   node-3   --protocol tcp --port 9002
cf allow-access node-4   node-3   --protocol tcp --port 9002
cf allow-access node-5   node-3   --protocol tcp --port 9002
cf allow-access node-6   node-3   --protocol tcp --port 9002
cf allow-access node-7   node-3   --protocol tcp --port 9002
cf allow-access bootnode node-3   --protocol udp --port 21002
cf allow-access node-1   node-3   --protocol udp --port 21002
cf allow-access node-2   node-3   --protocol udp --port 21002
cf allow-access node-4   node-3   --protocol udp --port 21002
cf allow-access node-5   node-3   --protocol udp --port 21002
cf allow-access node-6   node-3   --protocol udp --port 21002
cf allow-access node-7   node-3   --protocol udp --port 21002
cf allow-access bootnode node-3   --protocol tcp --port 21002
cf allow-access node-1   node-3   --protocol tcp --port 21002
cf allow-access node-2   node-3   --protocol tcp --port 21002
cf allow-access node-4   node-3   --protocol tcp --port 21002
cf allow-access node-5   node-3   --protocol tcp --port 21002
cf allow-access node-6   node-3   --protocol tcp --port 21002
cf allow-access node-7   node-3   --protocol tcp --port 21002
cf allow-access bootnode node-3   --protocol tcp --port 22002
cf allow-access node-1   node-3   --protocol tcp --port 22002
cf allow-access node-2   node-3   --protocol tcp --port 22002
cf allow-access node-4   node-3   --protocol tcp --port 22002
cf allow-access node-5   node-3   --protocol tcp --port 22002
cf allow-access node-6   node-3   --protocol tcp --port 22002
cf allow-access node-7   node-3   --protocol tcp --port 22002

cf allow-access node-1   node-4   --protocol tcp --port 9003
cf allow-access node-2   node-4   --protocol tcp --port 9003
cf allow-access node-3   node-4   --protocol tcp --port 9003
cf allow-access node-5   node-4   --protocol tcp --port 9003
cf allow-access node-6   node-4   --protocol tcp --port 9003
cf allow-access node-7   node-4   --protocol tcp --port 9003
cf allow-access bootnode node-4   --protocol udp --port 21003
cf allow-access node-1   node-4   --protocol udp --port 21003
cf allow-access node-2   node-4   --protocol udp --port 21003
cf allow-access node-3   node-4   --protocol udp --port 21003
cf allow-access node-5   node-4   --protocol udp --port 21003
cf allow-access node-6   node-4   --protocol udp --port 21003
cf allow-access node-7   node-4   --protocol udp --port 21003
cf allow-access bootnode node-4   --protocol tcp --port 21003
cf allow-access node-1   node-4   --protocol tcp --port 21003
cf allow-access node-2   node-4   --protocol tcp --port 21003
cf allow-access node-3   node-4   --protocol tcp --port 21003
cf allow-access node-5   node-4   --protocol tcp --port 21003
cf allow-access node-6   node-4   --protocol tcp --port 21003
cf allow-access node-7   node-4   --protocol tcp --port 21003
cf allow-access bootnode node-4   --protocol tcp --port 22003
cf allow-access node-1   node-4   --protocol tcp --port 22003
cf allow-access node-2   node-4   --protocol tcp --port 22003
cf allow-access node-3   node-4   --protocol tcp --port 22003
cf allow-access node-5   node-4   --protocol tcp --port 22003
cf allow-access node-6   node-4   --protocol tcp --port 22003
cf allow-access node-7   node-4   --protocol tcp --port 22003

cf allow-access node-1   node-5   --protocol tcp --port 9004
cf allow-access node-2   node-5   --protocol tcp --port 9004
cf allow-access node-3   node-5   --protocol tcp --port 9004
cf allow-access node-4   node-5   --protocol tcp --port 9004
cf allow-access node-6   node-5   --protocol tcp --port 9004
cf allow-access node-7   node-5   --protocol tcp --port 9004
cf allow-access bootnode node-5   --protocol udp --port 21004
cf allow-access node-1   node-5   --protocol udp --port 21004
cf allow-access node-2   node-5   --protocol udp --port 21004
cf allow-access node-3   node-5   --protocol udp --port 21004
cf allow-access node-4   node-5   --protocol udp --port 21004
cf allow-access node-6   node-5   --protocol udp --port 21004
cf allow-access node-7   node-5   --protocol udp --port 21004
cf allow-access bootnode node-5   --protocol tcp --port 21004
cf allow-access node-1   node-5   --protocol tcp --port 21004
cf allow-access node-2   node-5   --protocol tcp --port 21004
cf allow-access node-3   node-5   --protocol tcp --port 21004
cf allow-access node-4   node-5   --protocol tcp --port 21004
cf allow-access node-6   node-5   --protocol tcp --port 21004
cf allow-access node-7   node-5   --protocol tcp --port 21004
cf allow-access bootnode node-5   --protocol tcp --port 22004
cf allow-access node-1   node-5   --protocol tcp --port 22004
cf allow-access node-2   node-5   --protocol tcp --port 22004
cf allow-access node-3   node-5   --protocol tcp --port 22004
cf allow-access node-4   node-5   --protocol tcp --port 22004
cf allow-access node-6   node-5   --protocol tcp --port 22004
cf allow-access node-7   node-5   --protocol tcp --port 22004

cf allow-access node-1   node-6   --protocol tcp --port 9005
cf allow-access node-2   node-6   --protocol tcp --port 9005
cf allow-access node-3   node-6   --protocol tcp --port 9005
cf allow-access node-4   node-6   --protocol tcp --port 9005
cf allow-access node-5   node-6   --protocol tcp --port 9005
cf allow-access node-7   node-6   --protocol tcp --port 9005
cf allow-access bootnode node-6   --protocol udp --port 21005
cf allow-access node-1   node-6   --protocol udp --port 21005
cf allow-access node-2   node-6   --protocol udp --port 21005
cf allow-access node-3   node-6   --protocol udp --port 21005
cf allow-access node-4   node-6   --protocol udp --port 21005
cf allow-access node-5   node-6   --protocol udp --port 21005
cf allow-access node-7   node-6   --protocol udp --port 21005
cf allow-access bootnode node-6   --protocol tcp --port 21005
cf allow-access node-1   node-6   --protocol tcp --port 21005
cf allow-access node-2   node-6   --protocol tcp --port 21005
cf allow-access node-3   node-6   --protocol tcp --port 21005
cf allow-access node-4   node-6   --protocol tcp --port 21005
cf allow-access node-5   node-6   --protocol tcp --port 21005
cf allow-access node-7   node-6   --protocol tcp --port 21005
cf allow-access bootnode node-6   --protocol tcp --port 22005
cf allow-access node-1   node-6   --protocol tcp --port 22005
cf allow-access node-2   node-6   --protocol tcp --port 22005
cf allow-access node-3   node-6   --protocol tcp --port 22005
cf allow-access node-4   node-6   --protocol tcp --port 22005
cf allow-access node-5   node-6   --protocol tcp --port 22005
cf allow-access node-7   node-6   --protocol tcp --port 22005

cf allow-access node-1   node-7   --protocol tcp --port 9006
cf allow-access node-2   node-7   --protocol tcp --port 9006
cf allow-access node-3   node-7   --protocol tcp --port 9006
cf allow-access node-4   node-7   --protocol tcp --port 9006
cf allow-access node-5   node-7   --protocol tcp --port 9006
cf allow-access node-6   node-7   --protocol tcp --port 9006
cf allow-access bootnode node-7   --protocol udp --port 21006
cf allow-access node-1   node-7   --protocol udp --port 21006
cf allow-access node-2   node-7   --protocol udp --port 21006
cf allow-access node-3   node-7   --protocol udp --port 21006
cf allow-access node-4   node-7   --protocol udp --port 21006
cf allow-access node-5   node-7   --protocol udp --port 21006
cf allow-access node-6   node-7   --protocol udp --port 21006
cf allow-access bootnode node-7   --protocol tcp --port 21006
cf allow-access node-1   node-7   --protocol tcp --port 21006
cf allow-access node-2   node-7   --protocol tcp --port 21006
cf allow-access node-3   node-7   --protocol tcp --port 21006
cf allow-access node-4   node-7   --protocol tcp --port 21006
cf allow-access node-5   node-7   --protocol tcp --port 21006
cf allow-access node-6   node-7   --protocol tcp --port 21006
cf allow-access bootnode node-7   --protocol tcp --port 22006
cf allow-access node-1   node-7   --protocol tcp --port 22006
cf allow-access node-2   node-7   --protocol tcp --port 22006
cf allow-access node-3   node-7   --protocol tcp --port 22006
cf allow-access node-4   node-7   --protocol tcp --port 22006
cf allow-access node-5   node-7   --protocol tcp --port 22006
cf allow-access node-6   node-7   --protocol tcp --port 22006

cf allow-access node-1   bootnode --protocol udp --port 33445
cf allow-access node-2   bootnode --protocol udp --port 33445
cf allow-access node-3   bootnode --protocol udp --port 33445
cf allow-access node-4   bootnode --protocol udp --port 33445
cf allow-access node-5   bootnode --protocol udp --port 33445
cf allow-access node-6   bootnode --protocol udp --port 33445
cf allow-access node-7   bootnode --protocol udp --port 33445
```

1. SSH into node-1 to run the `script1.js`
```bash
→ cf ssh node-1
$ cd app
$ export PATH=$PATH:`pwd`/bin
$ geth attach qdata/dd1/geth.ipc
> loadScript('script1.js')
```
