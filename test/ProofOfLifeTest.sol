pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/ProofOfLife.sol";

/* @title Proof of Life tests */
/* @dev Security tests - To verify that implemented security mechanisms
/* work properly withing the delegate smart contract. */
contract ProofOfLifeTest {

    ProofOfLife proofOfLifeContract;
    address account = 0x88d02643596b5D0B20878d03Bb095fa95f00d578;

    /* @notice beforeEach
    /* @dev It is executed before every test
    */
    function beforeEach () public {
        proofOfLifeContract = new ProofOfLife();
    }

    /* In this first test battery we verify specifically credentials-related methods */

    /* @notice testContractOwner
    /* @dev It verifies that contract owner is specified in constructor
    */
    function testContractOwner () public {
        // Check the owner of the contract
        Assert.equal(address(proofOfLifeContract.contractOwner()), address(this), 
        "An owner is different than a deployer");
    }

    /* @notice testContractOpenToEveryUser
    /* @dev It verifies the close/open logic for constrained methods
    */
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

    /* @notice testAuthorizedUsers
    /* @dev It verifies that user verification mechanisms work properly
    */
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

    /* In this second test battery we verify specifically circuit breaker methods */

    /* @notice testLockedStatus
    /* @dev It verifies that circuit breaker works only when it is specified
    */
    function testLockedStatus () public {
         //Check status by default
        Assert.equal(bool(proofOfLifeContract.isLocked()), false, 
        "Contract locked by default");

        //Check if lock method works
        proofOfLifeContract.lock();
        Assert.equal(bool(proofOfLifeContract.isLocked()), true, 
        "Contract not locked by lock() method");

         //Check if unlock method works
        proofOfLifeContract.unlock();
        Assert.equal(bool(proofOfLifeContract.isLocked()), false, 
        "Contract not unlocked by unlock() method");
        
    }

    /* @notice testLockedMethods
    /* @dev It verifies that circuit breaker works in method modifiers
    */
    function testLockedMethods () public {
      
        //Check if unlocked method works
        (bool success, bytes memory data) = address(proofOfLifeContract).call(abi.encodeWithSignature("certifyDocument(string)", "hash1"));
        Assert.equal(success, true, "Exception for locked contract thrown");

        //Lock contract
        proofOfLifeContract.lock();

        //Check if locked method works
        (success, data) = address(proofOfLifeContract).call(abi.encodeWithSignature("certifyDocument(string)", "hash2"));
        Assert.equal(success, false, "Exception for locked contract not thrown");

        //Unlock contract again
        proofOfLifeContract.unlock();

        //Check if locked method works
        (success, data) = address(proofOfLifeContract).call(abi.encodeWithSignature("certifyDocument(string)", "hash2"));
        Assert.equal(success, true, "Exception for locked contract not thrown");

    }

    /* @notice testLockedMethodsForParentContract
    /* @dev It verifies that circuit breaker modifiers work in main certification functions
    */
    function testLockedMethodsForParentContract () public {

        //Check if another method works when unlocked
        (bool success, bytes memory data) = address(proofOfLifeContract).call(abi.encodeWithSignature(
        "certifyDocumentCreationWithIPFSHash(string,string,string)", "hash4", "ipfsHash1", ""));
        Assert.equal(success, true, "Exception for locked contract not thrown");

         //Lock contract
        proofOfLifeContract.lock();

        //Check if locked method works
        (success, data) = address(proofOfLifeContract).call(abi.encodeWithSignature(
        "certifyDocumentCreationWithIPFSHash(string,string,string)", "hash5", "ipfsHash1", "19-12-2018"));
        Assert.equal(success, false, "Exception for locked contract not thrown");

    }
}