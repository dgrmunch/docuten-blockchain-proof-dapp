pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/ProofOfLife.sol";


contract ProofOfLifeCredentialsTest {

    ProofOfLife proofOfLifeContract;
    address account = 0x88d02643596b5D0B20878d03Bb095fa95f00d578;

    function beforeEach () public {
        proofOfLifeContract = new ProofOfLife();
    }

    function testContractOwner () public {
        // Check the owner of the contract
        Assert.equal(address(proofOfLifeContract.contractOwner()), address(this), 
        "An owner is different than a deployer");
    }

    function testContractOpenToEveryUser () public {
        //Check status by default
        Assert.equal(bool(proofOfLifeContract.isOpenToEveryUser()), false, 
        "Open to every user by default");

        //Check status after opening to every user
        proofOfLifeContract.openToEveryUser();
        Assert.equal(bool(proofOfLifeContract.isOpenToEveryUser()), true, 
        "Closed to every user after opening it it");

        //Check status after closing to authorized users
        proofOfLifeContract.closeToAuthorizedUsers();
        Assert.equal(bool(proofOfLifeContract.isOpenToEveryUser()), false, 
        "Open to every user after closing it");
        
    }

    function testAuthorizedUsers () public {
        
        //Check if a the contract owner account is authorized
        Assert.equal(bool(proofOfLifeContract.authorizedUsers(address(this))), true, 
        "Contract owner user is not authorized");

        //Check if a random example account is authorized
        Assert.equal(bool(proofOfLifeContract.authorizedUsers(account)), false, 
        "Non authorized user is allowed");

        //Authorize example account
        proofOfLifeContract.addAuthorizedUser(account);
        Assert.equal(bool(proofOfLifeContract.authorizedUsers(account)), true, 
        "Authorized user has not been added");

        proofOfLifeContract.removeCredentials(account);
        Assert.equal(bool(proofOfLifeContract.authorizedUsers(account)), false, 
        "Non authorized user is allowed");
    }
}