#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

TMP_DIR=/var/folders/yy/12k_6xh97wxdn7sd49990n140000gn/T/tmp.lUD4OarD #$(mktemp -d)
QUORUM_RELEASE="0.0.14"

if grep "Not logged in" <(cf api); then
  exit 1
fi

pushd $TMP_DIR

  echo Gathering binary artifacts
  mkdir -p deploy/bin
  for file in bootnode constellation-node geth solc; do
    #curl -L https://github.com/micahyoung/quorum-pcf-pipeline/releases/download/$QUORUM_RELEASE/$file > deploy/bin/$file
    chmod +x deploy/bin/$file
  done

#  echo Gathering 7nodes artifacts
#  git clone https://github.com/jpmorganchase/quorum-examples
#  cp -r quorum-examples/examples/7nodes/* deploy/

#  echo Gathering PCF artifacts
#  git clone https://github.com/micahyoung/quorum-pcf-7nodes.git
#  cp -r quorum-pcf-7nodes/run-scripts/* deploy/

  echo Pushing bootnode
  cf push bootnode -p deploy/ -f quorum-pcf-7nodes/manifests/bootnode-manifest.yml --no-start

  echo Pushing nodes
  for node_num in {1..7}; do
     cf push node-${node_num} -p deploy/ -f quorum-pcf-7nodes/manifests/node-${node_num}-manifest.yml    --no-start
  done

#  echo "Setting C2C rules bootnode-to-node"
#  for node_num in {1..7}; do
#    declare -i dest_portsuffix=$node_num-1
#
#    cf allow-access bootnode node-${node_num} --protocol tcp --port 2100${dest_portsuffix}
#    cf allow-access bootnode node-${node_num} --protocol tcp --port 2200${dest_portsuffix}
#    cf allow-access bootnode node-${node_num} --protocol udp --port 2100${dest_portsuffix}
#    cf allow-access node-${node_num} bootnode --protocol udp --port 33445
#  done
#
#  echo Setting C2C rules node-to-node
#  for source_node_num in {1..7}; do
#    for dest_node_num in {1..7}; do
#      [[ $source_node_num -eq $dest_node_num ]] && continue
#
#      declare -i dest_portsuffix=$dest_node_num-1
#
#      cf allow-access node-${source_node_num} node-${dest_node_num} --protocol tcp --port 2100${dest_portsuffix}
#      cf allow-access node-${source_node_num} node-${dest_node_num} --protocol tcp --port 2200${dest_portsuffix}
#      cf allow-access node-${source_node_num} node-${dest_node_num} --protocol tcp --port 900${dest_portsuffix}
#      cf allow-access node-${source_node_num} node-${dest_node_num} --protocol udp --port 2100${dest_portsuffix}
#    done
#  done

  echo Starting bootnode
  cf start bootnode

  echo Starting nodes
  for node_num in {1..7}; do
    cf start node-${node_num}
  done
popd

