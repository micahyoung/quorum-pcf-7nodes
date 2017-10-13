#!/bin/bash
set -u
set -e

trap 'kill -- -$$' EXIT #tear down process group exiting or after wait failure

true ${BOOTNODE_PORT:?"!"}
true ${BOOTNODE_KEYHEX:?"!"}

export PATH=$PATH:`pwd`/bin

BOOTNODE_PUBKEY=$(bootnode --writeaddress --nodekey <(echo $BOOTNODE_KEYHEX))

# log data for broker
while true; do
  echo BOOTNODE=$BOOTNODE_PUBKEY@$CF_INSTANCE_INTERNAL_IP:$BOOTNODE_PORT
  sleep 5
done &

bootnode \
  --nodekeyhex "$BOOTNODE_KEYHEX" \
  --addr="$CF_INSTANCE_INTERNAL_IP:$BOOTNODE_PORT" \
  --verbosity 9 \
&

wait -n
