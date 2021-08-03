#!/bin/bash
set -eux
# your gaiad binary name
BIN=gravity

ETH_MINER_PRIVATE_KEY="0xb1bab011e03a9862664706fc3bbaa1b16651528e5f0e7fbfcbfdd8be302a13e7"
ETH_MINER_PUBLIC_KEY="0xBf660843528035a5A4921534E156a27e64B231fE"

NODES=$1
set +u
TEST_TYPE=$2
ALCHEMY_ID=$3
set -u

for i in $(seq 1 $NODES);
do
# add this ip for loopback dialing
ip addr add 0.0.0.0/32 dev eth0 || true # allowed to fail

GAIA_HOME="--home /root/testchain/gravity"
# this implicitly caps us at ~6000 nodes for this sim
# note that we start on 26656 the idea here is that the first
# node (node 1) is at the expected contact address from the gentx
# faciliating automated peer exchange
if [[ "$i" -eq 1 ]]; then
# node one gets localhost so we can easily shunt these ports
# to the docker host
RPC_ADDRESS="--rpc.laddr tcp://0.0.0.0:26657"
GRPC_ADDRESS="--grpc.address 0.0.0.0:9090"
else
# move these to another port and address, not becuase they will
# be used there, but instead to prevent them from causing problems
# you also can't duplicate the port selection against localhost
# for reasons that are not clear to me right now.
RPC_ADDRESS="--rpc.laddr tcp://0.0.0.0:26658"
GRPC_ADDRESS="--grpc.address 0.0.0.0:9091"
fi
LISTEN_ADDRESS="--address tcp://0.0.0.0:26655"
P2P_ADDRESS="--p2p.laddr tcp://0.0.0.0:26656"
LOG_LEVEL="--log_level error"

ARGS="--home /root/testchain/gravity"
$BIN $ARGS start > /root/testchain/gravity/logs &
done

# let the cosmos chain settle before starting eth as it
# consumes a lot of processing power
sleep 10
#if [[ $TEST_TYPE == *"ARBITRARY_LOGIC"* ]]; then
#bash /gravity/tests/container-scripts/run-eth-fork.sh $ALCHEMY_ID &
#elif [[ $TEST_TYPE == *"LONDON"* ]]; then
#bash /gravity/tests/container-scripts/run-eth-london.sh &
#else
#bash /gravity/tests/container-scripts/run-eth.sh &
#fi
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

sleep 10
