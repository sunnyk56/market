# How to run a Onomy testnet full node

A Onomy chain full node is just like any other Cosmos chain full node and unlike the validator flow requires no external software

## What do I need?

A Linux server with any modern Linux distribution, 4cores, 8gb of ram and at least 20gb of SSD storage.

In theory, Onomy chain can be run on Windows and Mac. Binaries will be provided on the releases page and currently, scripts files are provided to make binaries.
I also suggest an open notepad or other document to keep track of the keys you will be generating.

## Bootstrapping steps and commands

Start by logging into your Linux server using ssh. The following commands are intended to be run on that machine

### Download Onomy chain and the Gravity tools
For Fedora (Fedora 34) or Redhat (Red Hat Enterprise Linux 8.4 (Ootpa))

```
sudo yum install -y git
git clone -b ONET-65 https://github.com/sunnyk56/market.git
cd market/deploy/onomy-chain
bash bin.sh
```

### Initiate chain

```
cd market/deploy/onomy-chain
```

### Run the first time bootstrapping playbook and script

This script will run commands to generate keys and also store in files. You will need them later.

```
bash peer-validator/init.sh
```

Now it's finally up and start the sycing block

### Check the status of the Onomy chain

You should be good to go! You can check the status of the three
Onomy chain by running.
```
curl http://localhost:26657/status
```
if catching_up is false means your node is fully synced

