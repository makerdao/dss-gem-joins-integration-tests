#!/usr/bin/env bash
set -e

[[ "$ETH_RPC_URL" && "$(cast chain)" == "ethlive" ]] || { echo "Please set a mainnet ETH_RPC_URL"; exit 1; }

if [[ -z "$1" ]]; then
  forge test --use 0.6.12 --rpc-url="$ETH_RPC_URL" -vvv
else
  forge test --use 0.6.12 --rpc-url="$ETH_RPC_URL" --match "$1" -vvv
fi
