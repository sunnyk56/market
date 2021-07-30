#!/bin/bash
set -eu

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
GRAVITY_HOME="$CURRENT_WORKING_DIR/$CHAINID/$GRAVITY_NODE_NAME"
# Home flag for home folder
GRAVITY_HOME_FLAG="--home $GRAVITY_HOME"
# Prefix of cosmos addresses
GRAVITY_ADDRESS_PREFIX=cosmos
# Gravity chain demons
STAKE_DENOM="stake"

ETH_MINER_PRIVATE_KEY="0xb1bab011e03a9862664706fc3bbaa1b16651528e5f0e7fbfcbfdd8be302a13e7"
ETH_MINER_PUBLIC_KEY="0xBf660843528035a5A4921534E156a27e64B231fE"
#ETH_MINER_PRIVATE_KEY="c80c8a1a8da0bb6cf08dc95dd9e70682bac967ec341557e2b946b0a670c291dd"
#ETH_MINER_PUBLIC_KEY="0x90Dba8eD66c33508285Bc5ADB411356b577079A2"
# The host of ethereum node
ETH_HOST="0.0.0.0"

# ------------------ Run gravity ------------------

echo "Starting $GRAVITY_NODE_NAME"
$GRAVITY $GRAVITY_HOME_FLAG start --pruning=nothing &>/dev/null
sleep 10
#-------------------- Run ethereum (geth) --------------------
echo "Running ethereum node"

geth --identity "GravityTestnet" \
    --nodiscover \
    --networkid 15 init assets/ETHGenesis.json

geth --identity "GravityTestnet" --nodiscover \
                               --networkid 15 \
                               --mine \
                               --http \
                               --http.port "8545" \
                               --http.addr "$ETH_HOST" \
                               --http.corsdomain "*" \
                               --http.vhosts "*" \
                               --miner.threads=1 \
                               --nousb \
                               --verbosity=5 \
                               --miner.etherbase="$ETH_MINER_PUBLIC_KEY" \
                               &>/dev/null
sleep 10

echo "deploying contract"

npx ts-node \
    contract-deployer.ts \
    --cosmos-node="http://$GRAVITY_HOST:26657" \
    --eth-node="http://$ETH_HOST:8545" \
    --eth-privkey="$ETH_MINER_PRIVATE_KEY" \
    --contract=artifacts/contracts/Gravity.sol/Gravity.json \
    --test-mode=true >> /contracts


grep "Gravity deployed at Address" /contracts | grep -Eow '0x[0-9a-fA-F]{40}' >> /root/testchain/gravity/eth_contract_address

CONTRACT_ADDRESS=$(cat /root/testchain/gravity/eth_contract_address)
echo "Contract address: $CONTRACT_ADDRESS"
#-------------------- Run orchestrator --------------------


echo "Gathering keys for orchestrator"
COSMOS_GRPC="http://$GRAVITY_HOST:9090/"
COSMOS_PHRASE=$(jq -r .mnemonic $GRAVITY_HOME/orchestrator_key.json)
ETH_RPC=http://$ETH_HOST:8545
ETH_PRIVATE_KEY=$(jq -r .private_key $GRAVITY_HOME/eth_key.json)
echo "Run orchestrator"

gbt orchestrator --cosmos-phrase="$COSMOS_PHRASE" \
             --ethereum-key="$ETH_PRIVATE_KEY" \
             --cosmos-grpc="$COSMOS_GRPC" \
             --ethereum-rpc="$ETH_RPC" \
             --fees="1$STAKE_DENOM" \
             --gravity-contract-address="$CONTRACT_ADDRESS"