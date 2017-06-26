#!/bin/bash
set -u
set -e

true ${BOOTNODE_PORT:?"!"}
true ${BOOTNODE_KEYHEX:?"!"}

bootnode \
  --nodekeyhex "$BOOTNODE_KEYHEX" \
  --addr="0.0.0.0:$BOOTNODE_PORT" \
  --verbosity 9 \
;
