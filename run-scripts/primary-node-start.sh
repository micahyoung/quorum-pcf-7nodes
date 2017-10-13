#!/bin/bash
set -u
set -e

trap 'kill -- -$$' EXIT #tear down process group exiting

true ${NETID:?"!"}
true ${PRIVATE_CONFIG_FILE:?"!"}
true ${DATA_DIR:?"!"}
true ${RPC_PORT:?"!"}
true ${LISTEN_PORT:?"!"}
true ${NODE_PORT:?"!"}

NODE_IP=$CF_INSTANCE_INTERNAL_IP
BOOTNODE=$(jq -r '.["ethereum-service"][0].credentials.bootnode' <(echo $VCAP_SERVICES))
echo "NODE_IP=$NODE_IP"
echo "BOOTNODE=$BOOTNODE"

sed -ibak "s|url = .*|url = \"http://$NODE_IP:$NODE_PORT/\"|" $PRIVATE_CONFIG_FILE
sed -ibak "s|port = .*|port = $NODE_PORT|" $PRIVATE_CONFIG_FILE


export PATH=$PATH:`pwd`/bin
export LD_LIBRARY_PATH=`pwd`/bin

./init.sh

constellation-node \
  --verbosity=9 \
  $PRIVATE_CONFIG_FILE \
&

sleep 5

PRIVATE_CONFIG=$PRIVATE_CONFIG_FILE \
  geth \
  --datadir $DATA_DIR \
  --bootnodes enode://$BOOTNODE \
  --networkid $NETID \
  --rpc \
  --rpcaddr 0.0.0.0 \
  --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum \
  --rpcport $RPC_PORT \
  --port $LISTEN_PORT \
  --unlock 0 \
  --password passwords.txt \
  --verbosity 4 \
&

wait -n
