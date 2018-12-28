# About this dApp

* Ethereum dApp built on Solidity + React.
* Project developed by Diego Gonzalez (@ Enxendra/Docuten) for ConsenSys Bootcamp 2019.
* To be used for distributed proof-of-existence and proof-of-life experiments (using document hashes + ipfs hashes).

# Use a currently deployed instance

* Access https://dgrmunch.github.io/docuten-blockchain-proof-dapp"
* Connect Metamask to Ropsten
* More info about the addresses + ABIs for deployed smart contracts in the file deployed_addresses.txt

# To run it in your own server

## Installation

npm install
npm install truffle-hdwallet-provider
npm install --save gh-pages


## Running the dApp

### On one shell

Run:

`truffle migrate --network ropsten`

or

`truffle migrate --reset` (for local test)


This will deploy the smart contracts.

### On another shell

`cd client`
`npm run start`

This will run a node dApp. Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

You will need Metamask in your browser to make it work<br>


## Deploy the dApp

`truffle migrate --reset --network ropsten`
`npm run deploy`

It will be deployed here: https://dgrmunch.github.io/docuten-blockchain-proof-dapp/


## Test the smart contracts

`truffle test`


## Get the ABI of a contract to use in MyEtherWallet

const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('client/src/contracts/ProofOfLife.json', 'utf8'));
console.log(JSON.stringify(contract.abi));