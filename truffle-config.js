const path = require("path");
var HDWalletProvider = require("truffle-hdwallet-provider");

//var mnemonic = "CHANGE_ME"; //I don't publish my real mnemonic. Add your own
var mnemonic = "nation airport burger toy vacuum mail neglect panel bundle cushion female illegal"

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
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://ropsten.infura.io/<INFURA_Access_Token>")
      },
      network_id: 3
    }, 
    alastria: {
      host: "34.234.56.789",
      port: 22000,
      gasPrice: 0,
      network_id: "*" //1140
    },
  }
};
