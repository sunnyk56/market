#!/bin/bash
set -eu

echo "building environment"
# Initial dir
CURRENT_WORKING_DIR=$HOME

# Name of the network to bootstrap
echo "Enter chain-id"
read chainid
CHAINID=$chainid
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
# Config directories for gravity node
GRAVITY_HOME_CONFIG="$GRAVITY_HOME/config"
# Config file for gravity node
GRAVITY_NODE_CONFIG="$GRAVITY_HOME_CONFIG/config.toml"
# App config file for gravity node
GRAVITY_APP_CONFIG="$GRAVITY_HOME_CONFIG/app.toml"
# Keyring flag
GRAVITY_KEYRING_FLAG="--keyring-backend test"
# Chain ID flag
GRAVITY_CHAINID_FLAG="--chain-id $CHAINID"
# The name of the gravity validator
echo "Enter validator name"
read validator
GRAVITY_VALIDATOR_NAME=$validator
# The name of the gravity orchestrator/validator
GRAVITY_ORCHESTRATOR_NAME=orch
# Gravity chain demons
STAKE_DENOM="stake"
#NORMAL_DENOM="samoleans"
NORMAL_DENOM="footoken"

# The host of ethereum node
ETH_HOST="0.0.0.0"
echo '{
        "validator_name": "",
        "chain_id": "",
        "orchestrator_name": ""
}' > $HOME/val_info.json

# ------------------ Init gravity ------------------

echo "Creating $GRAVITY_NODE_NAME validator with chain-id=$CHAINID..."
echo "Initializing genesis files"
# Build genesis file incl account for passed address
GRAVITY_GENESIS_COINS="100000000000$STAKE_DENOM,100000000000$NORMAL_DENOM"

# Initialize the home directory and add some keys
echo "Init test chain"
$GRAVITY $GRAVITY_HOME_FLAG $GRAVITY_CHAINID_FLAG init $GRAVITY_NODE_NAME


# add in denom metadata for both native tokens
jq '.app_state.bank.denom_metadata += [{"base": "footoken", display: "mfootoken", "description": "A non-staking test token", "denom_units": [{"denom": "footoken", "exponent": 0}, {"denom": "mfootoken", "exponent": 6}]}, {"base": "stake", display: "mstake", "description": "A staking test token", "denom_units": [{"denom": "stake", "exponent": 0}, {"denom": "mstake", "exponent": 6}]}]' $GRAVITY_HOME_CONFIG/genesis.json > $HOME/metadata-genesis.json

# a 60 second voting period to allow us to pass governance proposals in the tests
jq '.app_state.gov.voting_params.voting_period = "60s"' $HOME/metadata-genesis.json > $HOME/edited-genesis.json
mv $HOME/edited-genesis.json $HOME/genesis.json
mv $HOME/genesis.json $GRAVITY_HOME_CONFIG/genesis.json

echo "Add validator key"
$GRAVITY $GRAVITY_HOME_FLAG keys add $GRAVITY_VALIDATOR_NAME $GRAVITY_KEYRING_FLAG --output json | jq . >> $GRAVITY_HOME/validator_key.json
jq .mnemonic $GRAVITY_HOME/validator_key.json | sed 's#\"##g' >> $HOME/validator-phrases

echo "Generating orchestrator keys"
$GRAVITY $GRAVITY_HOME_FLAG keys add --output=json $GRAVITY_ORCHESTRATOR_NAME $GRAVITY_KEYRING_FLAG | jq . >> $GRAVITY_HOME/orchestrator_key.json
jq .mnemonic $GRAVITY_HOME/orchestrator_key.json | sed 's#\"##g' >> $HOME/orchestrator-phrases

echo "Adding validator addresses to genesis files"
$GRAVITY $GRAVITY_HOME_FLAG add-genesis-account "$($GRAVITY $GRAVITY_HOME_FLAG keys show $GRAVITY_VALIDATOR_NAME -a $GRAVITY_KEYRING_FLAG)" $GRAVITY_GENESIS_COINS
echo "Adding orchestrator addresses to genesis files"
$GRAVITY $GRAVITY_HOME_FLAG add-genesis-account "$($GRAVITY $GRAVITY_HOME_FLAG keys show $GRAVITY_ORCHESTRATOR_NAME -a $GRAVITY_KEYRING_FLAG)" $GRAVITY_GENESIS_COINS

#echo "Adding orchestrator keys to genesis"
#GRAVITY_ORCHESTRATOR_KEY="$(jq .address $GRAVITY_HOME/orchestrator_key.json)"

#jq ".app_state.auth.accounts += [{\"@type\": \"/cosmos.auth.v1beta1.BaseAccount\",\"address\": $GRAVITY_ORCHESTRATOR_KEY,\"pub_key\": null,\"account_number\": \"0\",\"sequence\": \"0\"}]" $GRAVITY_HOME_CONFIG/genesis.json | sponge $GRAVITY_HOME_CONFIG/genesis.json
#jq ".app_state.bank.balances += [{\"address\": $GRAVITY_ORCHESTRATOR_KEY,\"coins\": [{\"denom\": \"$NORMAL_DENOM\",\"amount\": \"100000000000\"},{\"denom\": \"$STAKE_DENOM\",\"amount\": \"100000000000\"}]}]" $GRAVITY_HOME_CONFIG/genesis.json | sponge $GRAVITY_HOME_CONFIG/genesis.json

echo "Generating ethereum keys"
$GRAVITY $GRAVITY_HOME_FLAG eth_keys add --output=json | jq . >> $GRAVITY_HOME/eth_key.json
echo "private: $(jq .private_key $GRAVITY_HOME/eth_key.json | sed 's#\"##g')" > $HOME/validator-eth-keys
echo "public: $(jq .public_key $GRAVITY_HOME/eth_key.json | sed 's#\"##g')" >> $HOME/validator-eth-keys
echo "address: $(jq .address $GRAVITY_HOME/eth_key.json | sed 's#\"##g')" >> $HOME/validator-eth-keys

echo "Creating gentxs"
$GRAVITY $GRAVITY_HOME_FLAG gentx --ip $GRAVITY_HOST $GRAVITY_VALIDATOR_NAME 100000000000$STAKE_DENOM "$(jq -r .address $GRAVITY_HOME/eth_key.json)" "$(jq -r .address $GRAVITY_HOME/orchestrator_key.json)" $GRAVITY_KEYRING_FLAG $GRAVITY_CHAINID_FLAG

echo "Collecting gentxs in $GRAVITY_NODE_NAME"
$GRAVITY $GRAVITY_HOME_FLAG collect-gentxs

echo "Exposing ports and APIs of the $GRAVITY_NODE_NAME"
# Switch sed command in the case of linux
fsed() {
  if [ `uname` = 'Linux' ]; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

# Change ports
fsed "s#\"tcp://127.0.0.1:26656\"#\"tcp://$GRAVITY_HOST:26656\"#g" $GRAVITY_NODE_CONFIG
fsed "s#\"tcp://127.0.0.1:26657\"#\"tcp://$GRAVITY_HOST:26657\"#g" $GRAVITY_NODE_CONFIG
fsed 's#addr_book_strict = true#addr_book_strict = false#g' $GRAVITY_NODE_CONFIG
fsed 's#external_address = ""#external_address = "tcp://'$GRAVITY_HOST:26656'"#g' $GRAVITY_NODE_CONFIG
fsed 's#enable = false#enable = true#g' $GRAVITY_APP_CONFIG
fsed 's#swagger = false#swagger = true#g' $GRAVITY_APP_CONFIG

# Save validator-info
fsed 's#"validator_name": ""#"validator_name": "'$GRAVITY_VALIDATOR_NAME'"#g'  $HOME/val_info.json
fsed 's#"chain_id": ""#"chain_id": "'$CHAINID'"#g'  $HOME/val_info.json

echo "Please save this node-id to connect other validators to the chain"
echo $($GRAVITY $GRAVITY_HOME_FLAG tendermint show-node-id)
sleep 10

#echo "Adding initial ethereum value for gravity validator"
#jq ".alloc |= . + {$(jq .address $GRAVITY_HOME/eth_key.json) : {\"balance\": \"0x1337000000000000000000\"}}" $HOME/market/deploy/redhat-testchain-deployment/assets/ETHGenesis.json | sponge $HOME/market/deploy/redhat-testchain-deployment/assets/ETHGenesis.json

$GRAVITY $GRAVITY_HOME_FLAG start
