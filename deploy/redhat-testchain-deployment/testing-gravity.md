# Testing Gravity

Now that we've made it this far it's time to actually play around with the bridge

- This first command will send some ERC20 tokens to an address of your choice on the Gravity testchain.
- Notice that the Ethereum key is pre-filled. This address has both some test ETH and
a large balance of ERC20 tokens from the contracts listed here.

```
0xB1b8E75893d22BC2b05b0C976FF06b4569B4a687 - ERC20A
0x63c8eA8431ED11c0c5c4bD5BBb312bA76b07EF46 - ERC20B
0x6c3A3437fe6966973901Db5429d7FD520f99F13a - ERC20C
```

- Note that the 'amount' field for this command is now in whole coins rather than wei like the previous testnets

```bash
gbt client eth-to-cosmos \
        --ethereum-key "0xb1bab011e03a9862664706fc3bbaa1b16651528e5f0e7fbfcbfdd8be302a13e7" \
        --gravity-contract-address "0xFA2f45c5C8AcddFfbA0E5228bDf7E8B8f4fD2E84" \
        --token-contract-address "any of the three values above" \
        --amount=100 \
        --destination "any Cosmos address, I suggest your delegate Cosmos address"
        --ethereum-rpc "http://"Your-eth-testchain-IP":8545"
```

- You should see a message like this on your Orchestrator. The details of course will be different but it means that your Orchestrator has observed the event on Ethereum and sent the details into the Cosmos chain!

```bash
[2021-08-17T06:13:37Z INFO  orchestrator::ethereum_event_watcher] Oracle observed batch with nonce 1, contract 0xB1b8E75893d22BC2b05b0C976FF06b4569B4a687, and event nonce 3
```

- Once the event has been observed we can check our balance on the Cosmos side. We will see some peggy<ERC20 address> tokens in our balance. We have a good bit of code in flight right now so the module renaming from 'Peggy' to 'Gravity' has been put on hold until we're feature complete.

```bash
althea query bank balances <any cosmos address>
```

Now that we have some tokens on the Althea chain we can try sending them back to Ethereum. Remember to use the Cosmos phrase for the address you actually sent the tokens to. Alternately you can send Cosmos native tokens with this command.

The denom of a bridged token will be

```
gravity0xB1b8E75893d22BC2b05b0C976FF06b4569B4a687
```

```bash
gbt client cosmos-to-eth \
         --cosmos-phrase "the phrase containing the Gravity bridged tokens (delegate keys mnemonic)" 
         --amount 5000000000000gravity0xB1b8E75893d22BC2b05b0C976FF06b4569B4a687 
         --fees 100footoken 
         --eth-destination "any eth address, try your delegate eth address"
```

- You should see a message like this on your Orchestrator. The details of course will be different but it means that your Orchestrator has observed the event on Ethereum and sent the details into the Cosmos chain!
```bash
[2021-08-17T07:28:09Z INFO  orchestrator::ethereum_event_watcher] Oracle observed deposit with sender 0xBf660843528035a5A4921534E156a27e64B231fE, destination cosmos1w049un5qc6c7466lxllf89mhpfnzkl3d2l9epm, amount 100000000000000000000, and event nonce 4
```
