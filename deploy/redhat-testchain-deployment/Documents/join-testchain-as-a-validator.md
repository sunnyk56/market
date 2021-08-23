# Steps to follow to join a gravity testchain with one validator and one orchestrator
## Step to start a full node
- First we have to join the testchain as a full node.
- Run the following .sh file to start a full node.
- To run this script you require ```node-id``` and ```ip``` of any validator of the chain to add it as a seed to connect to.
```bash
bash init.sh
```
- Now we have a full node connected to testchain and syncing, but still this node is not a validator node. If you want to make it a vaidator wait for it to get completely synced with the chain then follow below steps.
## Steps to make full node a validator node
- To make this node a validator node we have to perform a create-validator transaction.
- Run the ```makeValidator.sh``` shell script present at ```/deploy/redhat-testchain-deployment/peer-validators``` to make this node a validator
- To run this script you need a ```mnemonic``` of any orchestrator from the chain so that some tokens can be transffered to your validator.
```bash
bash makeValidator.sh
```
- If everything goes well you will see the orchestrator key as output as well as the transactions. Then it will ask you to confirm the create-validator transaction and as soon as you confirm it a transaction log is generated and your full node will become a validator in chain.
- To confirm whether you have joined the testchain as a validator or not go the ```"GRAVITY-RPC"/validators``` on any browser and you can find your validator-address in the validtor-set.
## Start orchestrator
- Now we have to start an orchestrator 
- first we have to generate some delegator keys
```bash
gbt init
gbt keys register-orchestrator-address --validator-phrase "$YOUR_VALIDATOR_MNEMONIC" --fees=1footoken 
```
- It will generate a ```cosmos address, mnemonic, an ethereum address and it's private key```. Please save these information safe because we are going to use these in future as our delegator.
- Now you have to fund some tokens to you delegator for that run the following command.
```bash
gravity --home YOUR_GRAVITY_DATA_DIR tx bank send $(gravity --home YOUR_GRAVITY_DATA_DIR keys show -a orch --keyring-backend test) $YOUR_DELEGATOR_COSMOS_ADDRESS 1000000stake --chain-id testchain --keyring-backend test -y

gravity --home YOUR_GRAVITY_DATA_DIR tx bank send $(gravity --home YOUR_GRAVITY_DATA_DIR keys show -a orch --keyring-backend test) $YOUR_DELEGATOR_COSMOS_ADDRESS 1000000footoken --chain-id testchain --keyring-backend test -y
```
- Now you have to start a ethereum full node for the running ethereum testchain, if you want to go with rinkeby `geth --rinkeby --syncmode "light"  --rpc --rpcport "8545"` or to start with your own etherum testchain follow this [link](https://github.com/sunnyk56/market/blob/ONET-65/deploy/redhat-testchain-deployment/start-ethereum-testchain.md#steps-to-follow-to-start-a-ethereum-testchain-full-node) then only move to next step.
- You also have to fund some tokens to the generated Eth-account, you can use metamask for this purpose.
- Now run the following command to start orchestrator.
- You have to edit the ```cosoms-phrase, cosmos-grpc ex: http://localhost:9090, ethereum-rpc ex: http://"Your-eth-testchain-IP":8545, ethereum-key and gravity-contract-address``` accordingly.
```bash
gbt orchestrator \
        --cosmos-phrase="the-mnemonic-of-delegator-which-you-have-saved" \
        --cosmos-grpc="$cosmos-grpc" \
        --ethereum-key="private-key-of-the-delegator-which-you-have-saved" \
        --ethereum-rpc="$ethereum-rpc" \
        --fees="1stake" \
        --gravity-contract-address="0x330122273ffF8A31E8B5EAF2099cbFF881c9eEB7"
```
---
### Note
- Your Gravity directory will be named as per your testchain name.
- You can find  all required information regarding validator, orchestrator and ethereum inside that folder.
- This is "YOUR_GRAVITY_DATA_DIR" ```~/"YOUR-TESTCHAIN-NAME"/gravity```
---
- GRAVITY-RPC : http://"YOUR_MACHINE_PUBLIC_IP":26657
- GRVAITY_GRPC : http://"YOUR_MACHINE_PUBLIC_IP":9090
- ETHEREUM_RPC : http://"YOUR_MACHINE_PUBLIC_IP":8545
