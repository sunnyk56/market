#!/bin/bash
set -eux
# your gaiad binary name
BIN=gravity

CHAIN_ID="gravity-test"

NODES=$1

ALLOCATION="10000000000stake,10000000000footoken"

ETH_MINER_PRIVATE_KEY="0xb1bab011e03a9862664706fc3bbaa1b16651528e5f0e7fbfcbfdd8be302a13e7"
ETH_MINER_PUBLIC_KEY="0xBf660843528035a5A4921534E156a27e64B231fE"

# first we start a genesis.json with validator 1
# validator 1 will also collect the gentx's once gnerated
STARTING_VALIDATOR=1
STARTING_VALIDATOR_HOME="--home /root/testchain/gravity"

# Config file for gravity node
GRAVITY_NODE_CONFIG="/root/testchain/gravity/config/config.toml"
# App config file for gravity node
GRAVITY_APP_CONFIG="/root/testchain/gravity/config/app.toml"
# todo add git hash to chain name
$BIN init $STARTING_VALIDATOR_HOME --chain-id=$CHAIN_ID validator1


## Modify generated genesis.json to our liking by editing fields using jq
## we could keep a hardcoded genesis file around but that would prevent us from
## testing the generated one with the default values provided by the module.

# add in denom metadata for both native tokens
jq '.app_state.bank.denom_metadata += [{"base": "footoken", display: "mfootoken", "description": "A non-staking test token", "denom_units": [{"denom": "footoken", "exponent": 0}, {"denom": "mfootoken", "exponent": 6}]}, {"base": "stake", display: "mstake", "description": "A staking test token", "denom_units": [{"denom": "stake", "exponent": 0}, {"denom": "mstake", "exponent": 6}]}]' /root/testchain/gravity/config/genesis.json > /metadata-genesis.json

# a 60 second voting period to allow us to pass governance proposals in the tests
jq '.app_state.gov.voting_params.voting_period = "60s"' /metadata-genesis.json > /edited-genesis.json

mv /edited-genesis.json /genesis.json


# Sets up an arbitrary number of validators on a single machine by manipulating
# the --home parameter on gaiad
for i in $(seq 1 $NODES);
do
GAIA_HOME="--home /root/testchain/gravity"
GENTX_HOME="--home-client /root/testchain/gravity"
ARGS="$GAIA_HOME --keyring-backend test"

# Generate a validator key, orchestrator key, and eth key for each validator
$BIN keys add $ARGS validator$i 2>> /validator-phrases
$BIN keys add $ARGS orchestrator$i 2>> /orchestrator-phrases
$BIN eth_keys add >> /validator-eth-keys

VALIDATOR_KEY=$($BIN keys show validator$i -a $ARGS)
ORCHESTRATOR_KEY=$($BIN keys show orchestrator$i -a $ARGS)
# move the genesis in
mkdir -p /root/testchain/gravity/config/
mv /genesis.json /root/testchain/gravity/config/genesis.json
$BIN add-genesis-account $ARGS $VALIDATOR_KEY $ALLOCATION
$BIN add-genesis-account $ARGS $ORCHESTRATOR_KEY $ALLOCATION
# move the genesis back out
mv /root/testchain/gravity/config/genesis.json /genesis.json
done


for i in $(seq 1 $NODES);
do
cp /genesis.json /root/testchain/gravity/config/genesis.json
GAIA_HOME="--home /root/testchain/gravity"
ARGS="$GAIA_HOME --keyring-backend test"
ORCHESTRATOR_KEY=$($BIN keys show orchestrator$i -a $ARGS)
ETHEREUM_KEY=$(grep address /validator-eth-keys | sed -n "$i"p | sed 's/.*://')
# the /8 containing 7.7.7.7 is assigned to the DOD and never routable on the public internet
# we're using it in private to prevent gaia from blacklisting it as unroutable
# and allow local pex
$BIN gentx $ARGS $GAIA_HOME --moniker validator$i --chain-id=$CHAIN_ID --ip 0.0.0.0 validator$i 500000000stake $ETHEREUM_KEY $ORCHESTRATOR_KEY
# obviously we don't need to copy validator1's gentx to itself
if [ $i -gt 1 ]; then
cp /validator$i/config/gentx/* /root/testchain/gravity/config/gentx/
fi
done


$BIN collect-gentxs $STARTING_VALIDATOR_HOME
GENTXS=$(ls /root/testchain/gravity/config/gentx | wc -l)
cp /root/testchain/gravity/config/genesis.json /genesis.json
echo "Collected $GENTXS gentx"

# put the now final genesis.json into the correct folders
for i in $(seq 1 $NODES);
do
cp /genesis.json /root/testchain/gravity/config/genesis.json
done


echo "Adding initial ethereum value for miner"
jq ".alloc |= . + {\"$ETH_MINER_PUBLIC_KEY\" : {\"balance\": \"0x1337000000000000000000\"}}" assets/ETHGenesis.json | sponge assets/ETHGenesis.json
# Switch sed command in the case of linux
fsed() {
  if [ `uname` = 'Linux' ]; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}
fsed "s#\"tcp://127.0.0.1:26656\"#\"tcp://0.0.0.0:26656\"#g" $GRAVITY_NODE_CONFIG
fsed "s#\"tcp://127.0.0.1:26657\"#\"tcp://0.0.0.0:26657\"#g" $GRAVITY_NODE_CONFIG
fsed 's#addr_book_strict = true#addr_book_strict = false#g' $GRAVITY_NODE_CONFIG
fsed 's#external_address = ""#external_address = "tcp://0.0.0.0:26656"#g' $GRAVITY_NODE_CONFIG
fsed 's#enable = false#enable = true#g' $GRAVITY_APP_CONFIG
fsed 's#swagger = false#swagger = true#g' $GRAVITY_APP_CONFIG