#!/bin/bash
set -u
set -e

trap 'kill -- -$$' EXIT #tear down process group exiting or after wait failure

true ${NETID:?"!"}
true ${OTHER_NODE_PORT:?"!"}
true ${PRIVATE_CONFIG_FILE:?"!"}
true ${DATA_DIR:?"!"}
true ${RPC_PORT:?"!"}
true ${LISTEN_PORT:?"!"}
true ${NODE_PORT:?"!"}
true ${VCAP_SERVICES:?"!"}

NODE_IP=$CF_INSTANCE_INTERNAL_IP
echo "NODE_IP=$NODE_IP"
BOOTNODE=$(jq -r '.["ethereum-service"][0].credentials.bootnode' <(echo $VCAP_SERVICES))
echo "BOOTNODE=$BOOTNODE"
OTHER_NODES_JSON=$(jq -r '.["ethereum-service"][0].credentials.nodes' <(echo $VCAP_SERVICES))
echo "OTHER_NODES_JSON=$OTHER_NODES_JSON"
#TODO: try to map every IP to 9100
OTHER_NODES=$(
  jq --compact-output \
    ". | map(select(.geth_port==\"21000\")) | map(\"http://\(.ip):$OTHER_NODE_PORT/\")" \
    <(echo $OTHER_NODES_JSON)
)
echo "OTHER_NODES=$OTHER_NODES"

sed -ibak "s|url = .*|url = \"http://$NODE_IP:$NODE_PORT/\"|" $PRIVATE_CONFIG_FILE
sed -ibak "s|port = .*|port = $NODE_PORT|" $PRIVATE_CONFIG_FILE
sed -ibak "s|otherNodeUrls = .*|otherNodeUrls = $OTHER_NODES|" $PRIVATE_CONFIG_FILE

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
  --voteaccount $VOTE_ACCOUNT \
  --votepassword "" \
  --blockmakeraccount $BLOCKMAKER_ACCOUNT \
  --blockmakerpassword "" \
  --singleblockmaker \
  --minblocktime 2 \
  --maxblocktime 5 \
  --verbosity 4 \
&

wait -n
