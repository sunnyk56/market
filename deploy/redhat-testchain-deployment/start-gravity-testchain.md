# Steps to follow to start a gravity testchain with one validator and one orchestrator
- Use ```init.sh``` file present in ```/deploy/redhat-testchain-deployment/master-validator``` to start the validator node.
```bash
bash init.sh
```
- this will start a testchain with one validator.
- Now we will start a Ethereum testchain with our validator's Ethereum private-key. To start the Ethereum testchain follow this [link](https://github.com/sunnyk56/market/blob/ONET-65/deploy/redhat-testchain-deployment/start-ethereum-testchain.md), copy the ```ETHGensis``` file present in ```~/market/deploy/redhat-testchain-deployment/assests``` in your system to system in which you want to start Ethereum testchain.
- once our Ethereum testchain started we'll deploy the smart contract.
- first we'll open the folder where contracts are placed.
```bash
cd /go/src/onomyprotocol/gravity-bridge/solidity
```
- Now we'll deploy contract and save it in contract file in our root folder.
- You have to change ```COSMOS-RPC```, ```ETH-RPC``` endpoints and your ```ETH_PRIVATE_KEY``` accordingly.
```bash
npx ts-node \
    contract-deployer.ts \
    --cosmos-node="http://139.178.81.235:26657" \
    --eth-node="http://139.178.81.233:8545" \
    --eth-privkey="0xcb40d418b204d1f6bc3264fcfac0db00301650b9d43544b970c6234780d1ee61" \
    --contract=artifacts/contracts/Gravity.sol/Gravity.json \
    --test-mode=true >> /root/contract
```
- you can check the contract information.
```bash
cat ~/contract
```
- save these information safe you'll need them to start the orchestrator.
- Now we'll start the orchestrator.
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
- Now your testchain is up and running with one validator and one orchestrator
