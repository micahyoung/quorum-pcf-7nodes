#!/bin/bash
set -u
set -e

true ${NETID:?"!"}
true ${BOOTNODE_HASH:?"!"}
true ${BOOTNODE_PORT:?"!"}
true ${OTHER_NODE_PORT:?"!"}
true ${PRIVATE_CONFIG_FILE:?"!"}
true ${DATA_DIR:?"!"}
true ${RPC_PORT:?"!"}
true ${LISTEN_PORT:?"!"}
true ${NODE_PORT:?"!"}
true ${VCAP_SERVICES:?"!"}

NODE_IP=$CF_INSTANCE_INTERNAL_IP
BOOTNODE_IP=$(curl -f -s $BOOTNODE_IP_ROUTE)
OTHER_NODE_IP=$(curl -f -s $OTHER_NODE_IP_ROUTE)
echo "NODE_IP=$NODE_IP"
echo "BOOTNODE_IP=$BOOTNODE_IP"
echo "OTHER_NODE_IP=$OTHER_NODE_IP"

sed -ibak "s|url = .*|url = \"http://$NODE_IP:$NODE_PORT/\"|" $PRIVATE_CONFIG_FILE
sed -ibak "s|port = .*|port = $NODE_PORT|" $PRIVATE_CONFIG_FILE
sed -ibak "s|otherNodeUrls = .*|otherNodeUrls = [\"http://$OTHER_NODE_IP:$OTHER_NODE_PORT/\"]|" $PRIVATE_CONFIG_FILE

export PATH=$PATH:`pwd`/bin
export LD_LIBRARY_PATH=`pwd`/bin

constellation-node \
  --verbosity=9 \
  $PRIVATE_CONFIG_FILE \
&

sleep 5

PRIVATE_CONFIG=$PRIVATE_CONFIG_FILE \
  geth \
  --datadir $DATA_DIR \
  --bootnodes enode://$BOOTNODE_HASH@[$BOOTNODE_IP]:$BOOTNODE_PORT \
  --networkid $NETID \
  --rpc \
  --rpcaddr 0.0.0.0 \
  --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum \
  --rpcport $RPC_PORT \
  --port $LISTEN_PORT \
  --verbosity 4 \
&

wait
