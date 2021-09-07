# How to setup a Onomy testchain

## What do I need?

A Linux server with any modern Linux distribution, 16cores, 16gb of ram and at least 320gb of SSD storage.

Onomy chain can be run on Windows and Mac. Binaries are provided on the releases page. But validator instructions are not provided.

I also suggest an open notepad or other document to keep track of the keys you will be generating.

## Bootstrapping steps and commands

Start by logging into your Linux server using ssh. The following commands are intended to be run on that machine

### Download/install Onomy chain binaries
```
To download binary follow these commands
mkdir binaries
cd binaries
wget https://github.com/sunnyk56/market/raw/ONET-65/release/download/v0.0.1/onomyd
wget https://github.com/sunnyk56/market/raw/ONET-65/release/download/v0.0.1/gbt
wget https://github.com/sunnyk56/market/raw/ONET-65/release/download/v0.0.1/geth
cd ..
chmod -R +x binaries
export PATH=$PATH:$HOME/binaries/


or If you have Fedora (Fedora 34) or Redhat (Red Hat Enterprise Linux 8.4 (Ootpa))
 and you want to make binaries yourself, then follow these steps

sudo yum install -y git
git clone -b ONET-65 https://github.com/sunnyk56/market.git
cd market/deploy/onomy-chain
bash bin.sh
```

### Initiate chain

```
git clone -b ONET-65 https://github.com/sunnyk56/market.git
cd market/deploy/onomy-chain
```

### Run the first time bootstrapping playbook and script

This script will run commands to generate keys and also store in files. You will need them later.

```
bash master-validator/init.sh
```

Now it's finally up and start 

### Check the status of the Onomy chain

You should be good to go!
```
curl http://localhost:26657/status
curl http://localhost:8000/
```
### Setup Gravity bridge

You are now validating on the Onomy blockchain. But as a validator you also need to run the Gravity bridge components or you will be slashed and removed from the validator set after about 16 hours.
### Setup Geth on the Rinkeby testnet

We will be using Geth Ethereum light clients for this task. For production Gravity we suggest that you point your Orchestrator at a Geth light client and then configure your light client to peer with full nodes that you control. This provides higher reliability as light clients are very quick to start/stop and resync. Allowing you to for example rebuild an Ethereum full node without having days of Orchestrator downtime.

Geth full nodes do not serve light clients by default, light clients do not trust full nodes, but if there are no full nodes to request proofs from they can not operate. Therefore we are collecting the largest possible
list of Geth full nodes from our community that will serve light clients.

If you have more than 40gb of free storage, an SSD and extra memory/CPU power, please run a full node and share the node url. If you do not, please use the light client instructions

_Please only run one or the other of the below instructions, both will not work_

#### Light client instructions

```
geth --rinkeby --syncmode "light"  --rpc --rpcport "8545"
```

#### Fullnode instructions

```
geth --rinkeby --syncmode "full"  --rpc --rpcport "8545"
```
With the Onomy side faucet fund will be receive using url ``` http://localhost:8000```, now we need some Rinkeby Eth in the Ethereum delegate key

```
https://www.rinkeby.io/#faucet
```
### Deployment of the Gravity contract
Once 66% of the validator set has registered their delegate Ethereum key it is possible to deploy the Gravity Ethereum contract. Once deployed the Gravity contract address on Rinkeby will be saved in the file  `$HOME/contracts`

Basically here gravity directory contains the all code of gravity-bridge repo and solidity directory contain the some ERC20 contracts along with gravity contract. If you have created binary yourself using scripts, then these contracts all complied by default, otherwise you have take checkout and need to compile these smart contracts.
```
For Ubuntu machine install node
apt-get -y install nodejs
For Redhat or Fedora machine install node
dnf -y install nodejs

cd $HOME
git clone https://github.com/onomyprotocol/cosmos-gravity-bridge.git $HOME/gravity
cd $HOME/gravity/solidity
npm ci
chmod -R +x scripts
npm run typechain
```

 ```
cd $HOME/gravity/solidity
    
npx ts-node \
        contract-deployer.ts \
         --cosmos-node="http://localhost:26657" \
         --eth-node="http://localhost:8545" \
         --eth-privkey="$ETH_PRIVATE_KEY" \
         --contract=artifacts/contracts/Gravity.sol/Gravity.json \
         --test-mode=false > $HOME/contracts
```

### Start your Orchestrator

Now that the setup is complete you can start your Orchestrator. Use the Cosmos mnemonic generated in the 'register delegate keys' step and the Ethereum private key also generated in that step. You should setup your Orchestrator in systemd or elsewhere to keep it running and restart it when it crashes.

If your Orchestrator goes down for more than 16 hours during the testnet you will be slashed and booted from the active validator set.

Since you'll be running this a lot I suggest putting the command into a script, like so. The next version of the orchestrator will use a config file for these values and have encrypted key storage.

\*\*If you have set a minimum fee value in your `$HOME/onomy/onomy/config/app.toml` modify the `--fees` parameter to match that value!

```
nano start-orchestrator.sh
```

```
#!/bin/bash
gbt --address-prefix="onomy" orchestrator \
        --cosmos-phrase="<registered delegate consmos phrase>" \
        --cosmos-grpc="http://0.0.0.0:9090" \
        --ethereum-key="<registered delegate ethereum private key>" \
        --ethereum-rpc="http://0.0.0.0:8545" \
        --fees="1nom" \
        --gravity-contract-address="<gravity contract address>"
```

```
bash start-orchestrator.sh
```