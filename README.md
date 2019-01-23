# About this dApp

* Ethereum dApp built on Solidity + React.
* Project developed by Diego Gonzalez (@ Enxendra/Docuten) for ConsenSys Bootcamp 2019 (Twitter: @dgrmunch | Web: xmunch.com)
* To be used for distributed proof-of-existence and proof-of-life experiments (using document hashes + ipfs hashes).


# Video tutorials 

## To run your own

* Check this video to see how to run your own instance of the dApp:

[![How to run the dApp](http://img.youtube.com/vi/U5QU9qvx7fA/0.jpg)](https://www.youtube.com/watch?v=U5QU9qvx7fA "How to run the dApp")

* I have published also some instructions below, just in case you want to go deeper or if something in the video is not clear enough.

## To use an online version

* Check this video to see how the dApp works and how to use it:

[![How to use it](http://img.youtube.com/vi/p14buBTG1kY/0.jpg)](https://www.youtube.com/watch?v=p14buBTG1kY "How to use it")



# How to use a currently deployed instance

## Use directly the dApp:
* Access https://dgrmunch.github.io/docuten-blockchain-proof-dapp
* Connect Metamask to Ropsten

## Use etherscan and interact directly with the proxy contract
* More info about the addresses + ABIs for deployed smart contracts in the file deployed_addresses.txt

# To run it in your own server

## Installation

```
npm install
npm install truffle-hdwallet-provider
npm install --save gh-pages

```

## Running the dApp

### On one shell

Run:

`truffle migrate --network ropsten`

or

`truffle migrate --reset` (for local test)


This will deploy the smart contracts.

### On another shell


```
cd client
npm run start

```
This will run a node dApp. Open [http://localhost:3000](http://localhost:3000) to view it in the browser.

You will need Metamask in your browser to make it work<br>


## Deploying the dApp in Github pages

```
truffle migrate --reset --network ropsten
npm run deploy

```

By default, it will be deployed here: https://dgrmunch.github.io/docuten-blockchain-proof-dapp/
Update the configuration in truffle-config.js in order to adapt it to your needs.

## Test the smart contracts

`truffle test`

## How to get the ABI of the contract to use in MyEtherWallet?

* In deployed_address.txt (updated)
* In the truffle develop shell, typing:

```
const fs = require('fs');
const contract = JSON.parse(fs.readFileSync('client/src/contracts/ProofOfLifeProxy.json', 'utf8'));
console.log(JSON.stringify(contract.abi));

```
