#!/bin/bash
set -u
set -e

true ${NETID:?"!"}
true ${BOOTNODE_HASH:?"!"}
true ${BOOTNODE_PORT:?"!"}
true ${PRIVATE_CONFIG_FILE:?"!"}
true ${DATA_DIR:?"!"}
true ${RPC_PORT:?"!"}
true ${LISTEN_PORT:?"!"}
true ${NODE_PORT:?"!"}
true ${VCAP_SERVICES:?"!"}

while read ENV_PAIR; do export "${ENV_PAIR}"; done \
  < <(echo $VCAP_SERVICES | jq -r '.["user-provided"] | .[].credentials | to_entries[] | "\(.key)=\(.value)"')

true ${BOOTNODE_IP:?"!missing from VCAP_SERVICES"}

NODE_IP=$(hostname --ip-address)
echo "NODE_IP=$NODE_IP"
echo "BOOTNODE_IP=$BOOTNODE_IP"

sed -ibak "s|url = .*|url = \"http://$NODE_IP:$NODE_PORT/\"|" $PRIVATE_CONFIG_FILE
sed -ibak "s|port = .*|port = $NODE_PORT|" $PRIVATE_CONFIG_FILE

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
;
