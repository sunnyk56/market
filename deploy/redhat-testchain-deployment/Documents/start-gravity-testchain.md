# Steps to follow to start a gravity testchain with one validator and one orchestrator
- Use ```init.sh``` file present in ```/deploy/redhat-testchain-deployment/master-validator``` to start the validator node.
    ```bash
        bash init.sh
    ```
    - this will start a testchain with one validator.
- Now next step is run Ethereum node. So there is two way 
    - Launch eth node with rinkeby network
        -  Open new terminal, use either screen command  like screen -S etherum-node
        -  Run this command `geth --rinkeby --syncmode "light"  --rpc --rpcport "8545"` 
        -  wait 2-4 min it will syncing of block
    - Launch your own etherum network, to do this follow these steps 
        - Now we will start a Ethereum testchain with our validator's Ethereum private-key. To start the Ethereum testchain follow this [link](https://github.com/sunnyk56/market/blob/ONET-65/deploy/redhat-testchain-deployment/start-ethereum-testchain.md), copy the ```ETHGensis``` file present in ```$HOME/market/deploy/redhat-testchain-deployment/assests``` in your machine to machine in which you want to start Ethereum testchain.
- Next step is deploy the smart contract.
    - first we'll open the folder where contracts are placed.
    ```bash
    cd $HOME/gravity/solidity
    ```
    - Firstly need to change the path of ERC20 artifact contracts in the `contract-deployer.ts`, there is default path is set                                           `/gravity/solidity/artifacts/contracts/TestERC20A.sol/TestERC20A.json`. So if you have add your Home directry path at the starting for example my Home           director is root then path will look like `/root/gravity/solidity/artifacts/contracts/TestERC20A.sol/TestERC20A.json`. update same for TestERC20B and             TestERC20C also.
    - Now we'll deploy contract and save it in contract file in our home directory.
    - You have to change ```COSMOS-RPC``` ```ex: http://localhost:26657``` , ```ETH-RPC``` ```ex: http://"Your-eth-testchain-IP":8545``` endpoints and your             ```ETH_PRIVATE_KEY``` accordingly.
      ```bash
      npx ts-node \
        contract-deployer.ts \
         --cosmos-node="$COSMOS-RPC" \
         --eth-node="$ETH-RPC" \
         --eth-privkey="$ETH_PRIVATE_KEY" \
         --contract=artifacts/contracts/Gravity.sol/Gravity.json \
         --test-mode=true >> $HOME/contracts
        ```
    - you can check the contract information.
        ```bash
        cat $HOME/contracts
        ```
    - save these information safe you'll need them to start the orchestrator.
- Now we'll start the orchestrator.
    - You have to edit the ```cosoms-phrase```, ```COSMOS-GRPC ex: http://localhost:9090```, ```ETH-RPC ex: http://"Your-eth-testchain-IP":8545```, ```ethereum-     key and gravity-contract-address``` accordingly.
    - Make sure this ethereum account have some ether.
    ```bash
        gbt orchestrator \
             --cosmos-phrase="YOUR_ORCHESTRATOR_MNEMONIC" \
             --cosmos-grpc="$cosmos-grpc" \
             --ethereum-key="$ethereum-key" \
             --ethereum-rpc="$ethereum-rpc" \
             --fees="1stake" \
             --gravity-contract-address="0x330122273ffF8A31E8B5EAF2099cbFF881c9eEB7"
     ```
- Now your testchain is up and running with one validator, orchestrator and etherum node

---
### Important Note
- Your Gravity directory will be named as per your testchain name.
- You can find  all required information regarding validator, orchestrator and ethereum inside that folder.
- Folder structure is ```~/"YOUR-TESTCHAIN-NAME"/gravity```
- You have to pass some basic information to the other validators so that they can join your testchain.
  - Testchain Name
  - Your ```node-id```. You can get using this command `gravity $GRAVITY_HOME_FLAG tendermint show-node-id`
  - Your orchestrator ```mnemonic``` (We are passing this mnemonic so that the next validator can have some token from us to start testing, this can be changed in future by using faucet to provide tokens)
  - Your machine ```public ip``` on which testchain is hosted.
  - Deployed ```Gravity-contract address```
  - If you have your own etherum testnet then ```ETHGenesis.json``` file and ```machine-public-ip``` which you have used to start the ethereum testchain network
  - Ethereum-RPC address
  - Make sure following port open `26657/tcp 26656/tcp 9090/tcp 1317/tcp 8545/tcp 30303/tcp 30303/udp`

---
- GRAVITY-RPC : http://"YOUR_MACHINE_PUBLIC_IP":26657
- GRVAITY_GRPC : http://"YOUR_MACHINE_PUBLIC_IP":9090
- ETHEREUM_RPC : http://"YOUR_MACHINE_PUBLIC_IP":8545
