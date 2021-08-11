
# Steps to follow to start the testchain
- clone this repository first.
```bash
git clone -b ONET-65 https://github.com/sunnyk56/market.git
```

Follow this step only when starting the testchain with one validator.
## 1. First we'll install all the dependencies

- Use the ```bin.sh``` present in ```/deploy/redhat-testchain-deployment``` file to install all the dependencies.
```bash
bash bin.sh
```
---
## 2. Follow this step when starting a validator that will join the chain.
### Now we'll start our testchain with one validator node
- Follow this step only when starting a validator that will join the chain.
- Use ```init.sh``` file present in ```/deploy/redhat-testchain-deployment/master-validator``` to start the validator node.
```bash
bash init.sh
```
---
## 3. Follow this step when starting a validator that will join the chain.
### Follow these steps to add validators in running testchain
- Use ```init.sh``` file present in ```/deploy/redhat-testchain-deployment/peer-validators``` to start the validator node.
- To run this script you require ```node-id``` and ```ip``` of any validator of the chain to add it as a seed to connect to.
```bash
bash init.sh
```
- Now we have a full node connected to testchain and syncing, but still this node is not a validator node.
- To make this node a validator node we have to perform a create validator transaction.
- Run the ```makeValidator.sh``` file present in ```/deploy/redhat-testchain-deployment/peer-validators``` shell script to make this node a validator
- To run this script you need a ```Moniker``` of any orchestrator from the chain so that some tokens can be transffered to your validator.
```bash
bash makeValidator.sh
```
- If everything goes well you will see the orchestrator key as output as well as the transactions. Then it will ask you to confirm the create-validator transaction and as soon as you confirm it a transaction log is generated and your full node will become a validator in chain.
