# Quorum on Pivotal Cloud Foundry - 7nodes example

[JPMC Quorum](https://www.jpmorgan.com/quorum) running on [Pivotal Cloud Foundry](https://pivotal.io/platform). Based on the Quorum 7-node demo:

https://github.com/jpmorganchase/quorum-examples

## Pre-requisites

* Cloud Foundry CLI https://github.com/cloudfoundry/cli
* Account on Cloud Foundry environment with [Container-to-Container networking](https://docs.pivotal.io/pivotalcf/1-10/concepts/understand-cf-networking.html) enabled
  * Recommended: [Pivotal Web Services](https://run.pivotal.io/) 
    * [Sign up for free account](https://account.run.pivotal.io/z/uaa/sign-up)
  * Also supported on [Pivotal Cloud Foundry 1.10](https://docs.pivotal.io/pivotalcf/1-10/pcf-release-notes/index.html) and higher
* Log in and target an org and space with at least 5GB memory
   ```bash
   cf login -a https://api.run.pivotal.io
   ```
* CF CLI network-policy plugin
   ```bash
   cf install-plugin network-policy
   ```

## Automatic deployment

1. Clone this repo and go into directory
   ```bash
   git clone https://github.com/micahyoung/quorum-pcf-7nodes
   cd quorum-pcf-7nodes
   ```
   
1. Run `./up.sh`
   * *Note: this will take several minutes to complete*

1. Run a test transaction using instructions from [**Verify Deployment**](#verify-deployment)

## Manual Deployment

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

   Download `bootnode`, `constellation-node`, `geth`, `solc` and save to `deploy/bin`
   
   https://github.com/micahyoung/quorum-pcf-pipeline/releases/

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

1. Push all apps, unstarted
   ```bash
   cf push bootnode -p deploy/ -f quorum-pcf-7nodes/manifests/bootnode-manifest.yml --no-start
   cf push node-1   -p deploy/ -f quorum-pcf-7nodes/manifests/node-1-manifest.yml    --no-start
   cf push node-2   -p deploy/ -f quorum-pcf-7nodes/manifests/node-2-manifest.yml    --no-start
   cf push node-3   -p deploy/ -f quorum-pcf-7nodes/manifests/node-3-manifest.yml    --no-start
   cf push node-4   -p deploy/ -f quorum-pcf-7nodes/manifests/node-4-manifest.yml    --no-start
   cf push node-5   -p deploy/ -f quorum-pcf-7nodes/manifests/node-5-manifest.yml    --no-start
   cf push node-6   -p deploy/ -f quorum-pcf-7nodes/manifests/node-6-manifest.yml    --no-start
   cf push node-7   -p deploy/ -f quorum-pcf-7nodes/manifests/node-7-manifest.yml    --no-start
   ```

1. Update all apps with bootnode and othernode randomly generated routes
   ```bash
   BOOTNODE_IP_ROUTE=$(cf app bootnode | grep routes: | awk '{print $2}')
   OTHER_NODE_IP_ROUTE=$(cf app node-1 | grep routes: | awk '{print $2}')
   cf set-env node-1  BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env node-2  BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env node-3  BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env node-4  BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env node-5  BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env node-6  BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env node-7  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-1  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-2  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-3  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-4  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-5  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-6  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
   cf set-env node-7  OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
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
   
   # verify 
   cf list-access --app node-1   | wc -l #=> 56
   cf list-access --app node-7   | wc -l #=> 56
   cf list-access --app bootnode | wc -l #=> 32
   ```

1. Start all apps
   ```bash
   cf start bootnode
   cf start node-1
   cf start node-2
   cf start node-3
   cf start node-4
   cf start node-5
   cf start node-6
   cf start node-7
   ```

1. Run a test transaction using instructions from [**Verify Deployment**](#verify-deployment)
 
## Verify Deployment

1. Confirm that everything ran correcting 
1. SSH into node-1 to run the `script1.js`
   * on your command line:
      ```bash
      cf ssh node-1
      ```

   * ... within the container:
      ```sh
      cd app
      export PATH=$PATH:`pwd`/bin
      geth attach qdata/dd1/geth.ipc
      ```

   * ... in the solc interpreter:
      ```js
      loadScript('script1.js')
      ```

   * ... you should see the output if successful
      ```js
      Contract transaction send: TransactionHash: 0x541da6399119e66687fe5edada5162d586c56271800d626e33cf9e7ae811d8f6 waiting to be mined...
      true
      > Contract mined! Address: 0x064f860b6683223b03b38252853d5d2c210cce19
      [object Object]
      ```
   * Now we can check the details of the transaction
      ```js
      var address = "0x1932c48b2bf8102ba33b4a6b545c32236e342f34";
      var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"type":"constructor"}];
      var private = eth.contract(abi).at(address);
      
      private.get(); // should be 42
      ```
    
   * ... and confirm the same on node-7
      ```bash
      cf ssh node-7
      ```
      
      ```sh
      app/bin/geth attach app/qdata/dd7/geth.ipc
      ```

      ```js
      var address = "0x1932c48b2bf8102ba33b4a6b545c32236e342f34";
      var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"type":"constructor"}];
      var private = eth.contract(abi).at(address);
      
      private.get(); // should be 42
      ```
   * ... and no other node should have the details
      ```bash
      cf ssh node-2
      ```
      
      ```sh
      app/bin/geth attach app/qdata/dd2/geth.ipc
      ```

      ```js
      var address = "0x1932c48b2bf8102ba33b4a6b545c32236e342f34";
      var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"type":"constructor"}];
      var private = eth.contract(abi).at(address);
      
      private.get(); // should be 0
      ```
