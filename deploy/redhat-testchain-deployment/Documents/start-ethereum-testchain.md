# Steps to follow to start a Ethereum testchain
- You'll need the ```ETHGenesis.json``` file to start the testchain.
- Now run the following command to initialize the genesis block from where to start mining.
```bash
geth --identity "GravityEthereum" \
    --nodiscover \
    --networkid 15 init ETHGenesis.json
```
- Now we'll start the chain.
- Please add your ```ETH-ADRESS``` (this address can also be found in your ETHGenesis.json file) at place of ethereum address.
```bash
geth --identity "GravityEthereum" --nodiscover \
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
                               --miner.etherbase="$ETHEREUM_ADDRESS"
```
- Now your ethereum testchain is up and running.

# To add any node as a peer-node in this network
- this node will be our admin node so we'll add peers to this node
- attach the ```geth.ipc``` 
```bash
geth attach ~/.ethereum/geth.ipc
```
- Use the ```enode``` to add any node as peer-node, update ```enode``` and ```ip``` accordingly.
```bash
admin.addPeer("enode://26f7b8...92e@[$ip]:30303?discport=0")
```
--- 
# Steps to follow to start a Ethereum testchain full-node
- Use the same ```ETHGenesis.json``` file which you have used to start the testchain.
- Now run the following command to initialize the genesis block from where to start mining.
```bash
geth --identity "GravityEthereum" --networkid 15 init ETHGenesis.json
```
- Start the testchain and save logs to a file.
```bash
geth --rpc --rpcport "8545" --networkid 15 console 2>> myEth2.log
```
- Now we have to attach the ```geth.ipc```.
```bash
geth attach ~/.ethereum/geth.ipc
```
- Now view the enode info with following command.
```bash
admin.nodeInfo.enode
```
- Send this ```enode``` and your ```MACHINE_PUBLIC_IP``` to the master so that this node can be added as a peernode.
- check whether you are added as peer-node or not in the testchain by running the following command in ```geth.ipc```.
```bash
admin.peers
```
- once this is done revert to the remaining [join-testchain-as-a-validator steps](https://github.com/sunnyk56/market/blob/ONET-65/deploy/redhat-testchain-deployment/Documents/join-testchain-as-a-validator.md#start-orchestrator).
