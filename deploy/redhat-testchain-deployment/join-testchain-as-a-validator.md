# Steps to follow to join a gravity testchain with one validator and one orchestrator
- First we have to join the testchain as a full node.
- Run the following .sh file to start a full node.
- To run this script you require ```node-id``` and ```ip``` of any validator of the chain to add it as a seed to connect to.
```bash
bash init.sh
```
- Now we have a full node connected to testchain and syncing, but still this node is not a validator node.
```bash
bash init.sh
```
- To make this node a validator node we have to perform a create-validator transaction.
- Run the ```makeValidator.sh``` shell script present at ```/deploy/redhat-testchain-deployment/peer-validators``` to make this node a validator
- To run this script you need a ```moniker``` of any orchestrator from the chain so that some tokens can be transffered to your validator.
```bash
bash makeValidator.sh
```
- If everything goes well you will see the orchestrator key as output as well as the transactions. Then it will ask you to confirm the create-validator transaction and as soon as you confirm it a transaction log is generated and your full node will become a validator in chain.
- Now we have to start an orchestrator 
- first we have to generate some delegator keys
```bash
gbt keys register-orchestrator-address --validator-phrase "$YOUR_VALIDATOR_PHRASE" --fees=1footoken
```
- It will generate a cosmos address and ethereum address as your delegator keys
- Now you have to fund some tokens to you delegator for that run the following command.
```bash
gravity --home /root/testchain/gravity tx bank send $(gravity --home /root/testchain/gravity keys show -a orch1 --keyring-backend test) $YOUR_DELEGATOR_COSMOS_ADDRESS 1000000footoken --chain-id testchain --keyring-backend test -y
```
- Now you have to start a ethereum full node for the running ethereum testchain, to start it follow this [link]() then only move to next step.
- You also have to fund some tokens to the generated Eth-account, you can use metamask for this purpose.
- Now run the following command to start orchestrator.
- You have to edit the ```cosoms-phrase, cosmos-grpc, ethereum-rpc, ethereum-key and gravity-contract-address``` accordingly.
```bash
gbt orchestrator \
        --cosmos-phrase="steel demand crouch dwarf vast current erosion print kiwi educate ridge world spirit live wine topic soap dash connect innocent virtual patrol into carry" \
        --cosmos-grpc="http://145.40.102.9:9090/" \
        --ethereum-key="0x931564541290f17ed6338616293c1d77a106e771203f82dd3e67bcb8a60ab381" \
        --ethereum-rpc="http://139.178.81.233:8545" \
        --fees="1stake" \
        --gravity-contract-address="0x330122273ffF8A31E8B5EAF2099cbFF881c9eEB7"
```
