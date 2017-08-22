#!/bin/bash
set -u
set -e

trap 'kill -- -$$' EXIT #tear down process group exiting

true ${NETID:?"!"}
true ${BOOTNODE_HASH:?"!"}
true ${BOOTNODE_PORT:?"!"}
true ${BOOTNODE_IP_ROUTE:?"!"}
true ${PRIVATE_CONFIG_FILE:?"!"}
true ${DATA_DIR:?"!"}
true ${RPC_PORT:?"!"}
true ${LISTEN_PORT:?"!"}
true ${NODE_PORT:?"!"}

NODE_IP=$CF_INSTANCE_INTERNAL_IP
BOOTNODE_IP=$(curl -f -s $BOOTNODE_IP_ROUTE)
echo "NODE_IP=$NODE_IP"
echo "BOOTNODE_IP=$BOOTNODE_IP"

while true; do
  nc -l $PORT < <(echo -e "HTTP/1.1 200 OK\n\n$NODE_IP") > /dev/null
done &

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
  --bootnodes enode://$BOOTNODE_HASH@[$BOOTNODE_IP]:$BOOTNODE_PORT \
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
