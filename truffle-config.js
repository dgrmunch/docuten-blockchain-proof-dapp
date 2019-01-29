const path = require("path");
var HDWalletProvider = require("truffle-hdwallet-provider");

var mnemonic = "CHANGE_ME"; //I don't publish my real mnemonic. Add your own

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    alastria: {
      host: "5.57.225.79",
      port: 22000,
      network_id: "*", // Match Alastria network id
      gas: 6721975,
      gasPrice: 0
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/<INFURA_Access_Token>")
      },
      network_id: 3
    }
  }
};
