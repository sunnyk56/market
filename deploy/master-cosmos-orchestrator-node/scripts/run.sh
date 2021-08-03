#!/bin/bash
set -eux

echo "running gravity-bridge"

# Initial dir
CURRENT_WORKING_DIR=$(pwd)
# Name of the network to bootstrap
CHAINID="testchain"
# Name of the gravity artifact
GRAVITY=gravity
# The name of the gravity node
GRAVITY_NODE_NAME="gravity"
# The address to run gravity node
GRAVITY_HOST="0.0.0.0"
# Home folder for gravity config
GRAVITY_HOME="/root/$CHAINID/$GRAVITY_NODE_NAME"
# Home flag for home folder
GRAVITY_HOME_FLAG="--home $GRAVITY_HOME"

ETH_MINER_PRIVATE_KEY="0xb1bab011e03a9862664706fc3bbaa1b16651528e5f0e7fbfcbfdd8be302a13e7"
ETH_MINER_PUBLIC_KEY="0xBf660843528035a5A4921534E156a27e64B231fE"

$GRAVITY $GRAVITY_HOME_FLAG start > /root/testchain/gravity/logs &

sleep 10

geth --identity "GravityTestnet" \
    --nodiscover \
    --networkid 15 init /root/assets/ETHGenesis.json

geth --identity "GravityTestnet" --nodiscover \
                               --networkid 15 \
                               --mine \
                               --http \
                               --http.port "8545" \
                               --http.addr "0.0.0.0" \
                               --http.corsdomain "*" \
                               --http.vhosts "*" \
                               --miner.threads=1 \
                               --nousb \
                               --verbosity=5 \
                               --miner.etherbase="$ETH_MINER_PUBLIC_KEY" \
                               &> /geth.log

# deploy the ethereum contracts
pushd /gravity/orchestrator/test_runner
DEPLOY_CONTRACTS=1 RUST_BACKTRACE=full TEST_TYPE="" NO_GAS_OPT=1 RUST_LOG="INFO,relayer=DEBUG,orchestrator=DEBUG" PATH=$PATH:$HOME/.cargo/bin cargo run --release --bin test-runner

# This keeps the script open to prevent Docker from stopping the container
# immediately if the nodes are killed by a different process
read -p "Press Return to Close..."