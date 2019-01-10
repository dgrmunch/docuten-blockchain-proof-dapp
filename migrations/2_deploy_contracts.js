var ProofOfLife = artifacts.require("./ProofOfLife.sol");
var ProofOfLifeProxy = artifacts.require("./ProofOfLifeProxy.sol");

module.exports = function(deployer) {
  deployer.deploy(ProofOfLife).then(
    function() {
      return deployer.deploy(ProofOfLifeProxy, ProofOfLife.address);
    }
  );
};
