# How to run a Onomy testnet full node

A Onomy chain full node is just like any other Cosmos chain full node and unlike the validator flow requires no external software

## What do I need?

A Linux server with any modern Linux distribution, 2gb of ram and at least 20gb storage. Requirements are very minimal.

### Download Onomy chain binaries

```
sudo yum install -y git
git clone -b ONET-65 https://github.com/sunnyk56/market.git
cd market/deploy/onomy-chain
bash bin.sh
```

### Init the config files

```
cd $HOME
onomyd --home $HOME/onomy/onomy init mymoniker --chain-id onomy
```

### Copy the genesis file

```
rm $HOME/onomy/onomy/config/genesis.json
wget http://147.182.128.38:26657/genesis? -O $HOME/raw.json
jq .result.genesis $HOME/raw.json >> $HOME/onomy/onomy/config/genesis.json
rm -rf $HOME/raw.json
```

### Add seed node

Change the seed field in $HOME/onomy/onomy/config/config.toml to contain the following:

```

seeds = "1302d0ed290d74d6f061fb8506e0e34f3f67f7ff@147.182.128.38:26656"
enable = true
external_address = "tcp://0.0.0.0:26656"
addr_book_strict = false

```

### Start your full node and wait for it to sync

Ask what the current blockheight is in the chat

```
onomyd --home $HOME/onomy/onomy start
```
