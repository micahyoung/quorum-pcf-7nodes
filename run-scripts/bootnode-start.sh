#!/bin/bash
set -u
set -e

true ${BOOTNODE_PORT:?"!"}
true ${BOOTNODE_KEYHEX:?"!"}

NODE_IP=$CF_INSTANCE_INTERNAL_IP
echo "NODE_IP=$NODE_IP"

export PATH=$PATH:`pwd`/bin

while true; do
  nc -l $PORT < <(echo -e "HTTP/1.1 200 OK\n\n$NODE_IP") > /dev/null
done &

bootnode \
  --nodekeyhex "$BOOTNODE_KEYHEX" \
  --addr="0.0.0.0:$BOOTNODE_PORT" \
  --verbosity 9 \
&

wait
