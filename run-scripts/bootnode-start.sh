#!/bin/bash
set -u
set -e

true ${BOOTNODE_PORT:?"!"}
true ${BOOTNODE_KEYHEX:?"!"}

export PATH=$PATH:`pwd`/bin

bootnode \
  --nodekeyhex "$BOOTNODE_KEYHEX" \
  --addr="0.0.0.0:$BOOTNODE_PORT" \
  --verbosity 9 \
;
