# Steps to follow to start a gravity testchain with one validator and one orchestrator
1. To start first validator, run ```/deploy/redhat-testchain-deployment/master-validator/init.sh``` file
    ```bash
        bash init.sh
    ```
	- this will start a testchain with one validator.

2. Launch an Ethereum node. You can either use [Rinkeby](https://www.rinkeby.io/) or launch your own chain
    - Using Rinkeby
        -  Open new terminal
        -  Run `geth --rinkeby --syncmode "light"  --rpc --rpcport "8545"` 
        -  wait untill blockchain is synchronized
    - Launch your own etherum network, to do this follow these steps 
        - To start the Ethereum testchain follow this [link](https://github.com/sunnyk56/market/blob/ONET-65/deploy/redhat-testchain-deployment/Documents/start-ethereum-testchain.md), copy the ```ETHGensis``` file present in ```$HOME/market/deploy/redhat-testchain-deployment/assests``` in your machine to machine in which you want to start Ethereum testchain.

3. Next step is deploy the smart contract.
    - First go to the folder where contracts are placed.
    ```bash
    cd $HOME/gravity/solidity
    ```
    - Deploy gravity contract and save it. Here, we will save it ```$HOME/contracts```.
    - You have to change ```COSMOS-RPC``` ```ex: http://localhost:26657``` , ```ETH-RPC``` ```ex: http://"Your-eth-testchain-IP":8545``` endpoints and your             ```ETH_PRIVATE_KEY``` accordingly.
      ```bash
      npx ts-node contract-deployer.ts --cosmos-node="{COSMOS_RPC}" --eth-node="{ETH_RPC}" --eth-privkey="{ETH_PRIVATE_KEY}" --contract=artifacts/contracts/Gravity.sol/Gravity.json --test-mode=false > $HOME/contracts
        ```
    - you can check the contract information from the saved file:
        ```bash
        cat $HOME/contracts
        ```
    - This information will be needed to start the orchastrator.
4. Now let's start the orchestrator.
    - You have to edit the ```cosoms-phrase```, ```COSMOS-GRPC ex: http://localhost:9090```, ```ETH-RPC ex: http://"Your-eth-testchain-IP":8545```, ```ethereum-     key and gravity-contract-address``` accordingly.
    - Make sure this ethereum account have some ether.
    ```bash
        gbt orchestrator --cosmos-phrase="{ORCHESTRATOR_MNEMONIC}" --cosmos-grpc="{COSMOS_GRPC}" --ethereum-key="{ETH_PRIVATE_KEY}" --ethereum-rpc="{ETHEREUM_RPC}" --fees="1stake" --gravity-contract-address="{GRAVITY_CONTRACT_ADDRESS}"
     ```
- Now testchain is up and running with one validator, orchestrator and etherum node

---
### Important Note
- Gravity directory will have same name as chain name.
- You can find  all required information regarding validator, orchestrator and ethereum inside $HOME/{CHAIN_NAME}.
- You have to pass some basic information to the other validators so that they can join your testchain.
- In order to have other validators join the chain, information outlined below will be necessary:
  - Testchain Name
  - node-id: You can get using this command ```gravity $GRAVITY_HOME_FLAG tendermint show-node-id```
  - Orchestrator ```mnemonic``` (We are passing this mnemonic so that the next validator can have some token from us to start testing, this can be changed in future by using faucet to provide tokens)
  -  Public IP of the machine where chain is hosted.
  - Deployed Gravity contract address.
  - If you have your own etherum testnet then `ETHGenesis.json` file and public ip address of the ethereum testnet.
  - Ethereum-RPC address
  - Make sure to open these ports on the firewall:  `26657/tcp 26656/tcp 9090/tcp 1317/tcp 8545/tcp 30303/tcp 30303/udp`

---
- GRAVITY-RPC : http://"YOUR_MACHINE_PUBLIC_IP":26657
- GRVAITY_GRPC : http://"YOUR_MACHINE_PUBLIC_IP":9090
- ETHEREUM_RPC : http://"YOUR_MACHINE_PUBLIC_IP":8545
