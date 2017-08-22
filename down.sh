#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

read -p "This will delete all existing nodes. Are you sure? " -n 1 -r
echo
[[ $REPLY =~ ^[Yy]$ ]] || exit 1

if grep "Not logged in" <(cf api); then
  exit 1
fi

for node in bootnode node-{1..7}; do
  cf d -f $node
done
