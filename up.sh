#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

QUORUM_PCF_RELEASE="0.0.16"

if grep "Not logged in" <(cf api); then
  exit 1
fi

ORG_NAME=$(cf target | grep org | awk '{print $2}')
ORG_QUOTA_NAME=$(cf org $ORG_NAME | grep quota | awk '{print $2}')
ORG_MEMORY=$(cf quota $ORG_QUOTA_NAME | grep "Total Memory" | awk '{print $3}')

echo Your org \'$ORG_NAME\' has $ORG_MEMORY RAM total

declare -i ORG_MEMORY_GB=${ORG_MEMORY/G/}
if [ $ORG_MEMORY_GB -ge 3 ]; then
  INSTANCES=({1..7})
  echo Deploying all nodes
elif [ $ORG_MEMORY_GB -ge 2 ]; then
  INSTANCES=(1 2 4 7)
  echo Only deploying nodes ${INSTANCES[@]}.
else
  echo Must have at least 2GB or RAM.
  exit 1
fi

NODE_NAMES=$(printf "node-%s " "${INSTANCES[@]}")
NODE_IDS="${INSTANCES[@]}"

# clean up previous directories
rm -rf deploy
rm -rf quorum-examples

echo Gathering binary artifacts
mkdir -p deploy/bin
for file in bootnode constellation-node geth solc libsodium.so.18; do
  curl -L https://github.com/micahyoung/quorum-pcf-pipeline/releases/download/$QUORUM_PCF_RELEASE/$file > deploy/bin/$file
  chmod +x deploy/bin/$file
done

echo Gathering 7nodes artifacts
git clone https://github.com/jpmorganchase/quorum-examples quorum-examples
cp -r quorum-examples/examples/7nodes/* deploy/

echo Gathering PCF artifacts
cp -r run-scripts/* deploy/

echo Pushing nodes
for node in bootnode $NODE_NAMES; do
  cf push $node -p deploy/ -f manifests/$node-manifest.yml --no-start
done

echo Set routes env vars for each node
BOOTNODE_IP_ROUTE=$(cf app bootnode | grep routes: | awk '{print $2}')
OTHER_NODE_IP_ROUTE=$(cf app node-1 | grep routes: | awk '{print $2}')
for node in $NODE_NAMES; do
   cf set-env $node BOOTNODE_IP_ROUTE $BOOTNODE_IP_ROUTE
   cf set-env $node OTHER_NODE_IP_ROUTE $OTHER_NODE_IP_ROUTE
done

echo "Setting C2C rules bootnode-to-node"
for node_num in $NODE_IDS; do
  declare -i dest_portsuffix=$node_num-1

  cf allow-access bootnode node-${node_num} --protocol tcp --port 2100${dest_portsuffix}
  cf allow-access bootnode node-${node_num} --protocol tcp --port 2200${dest_portsuffix}
  cf allow-access bootnode node-${node_num} --protocol udp --port 2100${dest_portsuffix}
  cf allow-access node-${node_num} bootnode --protocol udp --port 33445
done

echo Setting C2C rules node-to-node
for source_node_num in $NODE_IDS; do
  for dest_node_num in $NODE_IDS; do
    [[ $source_node_num -eq $dest_node_num ]] && continue

    declare -i dest_portsuffix=$dest_node_num-1

    cf allow-access node-${source_node_num} node-${dest_node_num} --protocol tcp --port 2100${dest_portsuffix}
    cf allow-access node-${source_node_num} node-${dest_node_num} --protocol tcp --port 2200${dest_portsuffix}
    cf allow-access node-${source_node_num} node-${dest_node_num} --protocol tcp --port 900${dest_portsuffix}
    cf allow-access node-${source_node_num} node-${dest_node_num} --protocol udp --port 2100${dest_portsuffix}
  done
done

echo Starting nodes
for node in bootnode $NODE_NAMES; do
  cf start $node
done

