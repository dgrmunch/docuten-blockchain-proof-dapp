var ProofOfLife = artifacts.require("./ProofOfLife.sol");
var ProofOfLifeProxy = artifacts.require("./ProofOfLifeProxy.sol");

var proxy;
var delegate;

module.exports =  function(deployer){
  deployer.deploy(ProofOfLife).then(
     function() {
      return ProofOfLife.deployed();
    }).then(async function(instance){
      delegate = instance;
      console.log('\n\t -- The ProofOfLifeProxy instance will point to the delegate address :')
      console.log('\n\t\t'+ProofOfLife.address);
      console.log('\n\t -- This will allow ProofOfLifeProxy to know where is the delegate contract (ProofOfLife) deployed');
      return deployer.deploy(ProofOfLifeProxy, ProofOfLife.address).then(
        function() {
          return ProofOfLifeProxy.deployed();
        }).then(async function() {
          
          console.log('\n\n\n\t Delegate: '+ProofOfLife.address);
          console.log('\t Proxy: '+ProofOfLifeProxy.address);
      }); 
    }
  );
  
};
