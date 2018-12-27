var ProofOfLife = artifacts.require("./ProofOfLife.sol");

module.exports = function(deployer) {
  deployer.deploy(ProofOfLife);
};
