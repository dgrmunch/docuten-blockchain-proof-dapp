pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/ProofOfLife.sol";
import "../contracts/ProofOfLifeProxy.sol";

/* @title Proof of Life Proxy tests */
/* @dev Security tests - To verify that implemented security mechanisms
/* can not be called from the proxy smart contract for non-owners
/* In this test battery we verify specifically circuit breaker methods */
contract ProofOfLifeProxyTest {

    ProofOfLifeProxy proofOfLifeProxyContract;

    /* @notice beforeEach
    /* @dev It is executed before every test
    */
    function beforeEach () public {
        ProofOfLife proofOfLifeContract  = ProofOfLife(DeployedAddresses.ProofOfLife());
        proofOfLifeProxyContract = ProofOfLifeProxy(DeployedAddresses.ProofOfLifeProxy());
    }

    /* @notice testContractOwner
    /* @dev It verifies that contract owner is specified in constructor
    */
    function testContractOwner () public {
        // Check the owner of the contract
        Assert.equal(address(proofOfLifeProxyContract.contractOwner()) == address(this), false,
        "Executor and owner are the same account!");
    }

    /* @notice testContractOpenToEveryUser
    /* @dev It verifies that public method is not constrained in proxy
    */
    function testContractOpenToEveryUser () public {
        (bool success, bytes memory data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("isOpenToEveryUser()"));
        Assert.equal(success, true, "Public method without owner constraints has been triggered");   
    }

    /* @notice testAuthorizedUsers
    /* @dev It verifies that user verification mechanisms are protected
    */
    function testAuthorizedUsers () public {
        
        (bool success, bytes memory data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("authorizedUsers(address)", address(this)));
        Assert.equal(success, true, "authorizedUsers: Non authorized user looks like authorized");   

        ( success, data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("addAuthorizedUser(address)", address(this)));
        Assert.equal(success, false, "addAuthorizedUser: Non authorized user could execute a constrained function");   

        ( success, data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("removeCredentials(address)", address(this)));
        Assert.equal(success, false, "removeCredentials: Non authorized user could execute a constrained function");   

    }

    /* @notice testLockMethods
    /* @dev It verifies that circuit breaker methods are protected
    */
    function testLockMethods () public {
     
        (bool success, bytes memory data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("lock()"));
        Assert.equal(success, false, "lock: Non authorized user could execute a constrained function");   

        (success, data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("unlock()"));
        Assert.equal(success, false, "unlock: Non authorized user could execute a constrained function");   

    }

    /* @notice testCertificationMethods
    /* @dev It verifies that proxy protects main certification functions
    */
    function testCertificationMethods () public {

        (bool success, bytes memory data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature(
        "certifyDocumentCreationWithIPFSHash(string,string,string)", "hash4", "ipfsHash1", ""));
        Assert.equal(success, false, "certifyDocumentCreationWithIPFSHash: Non authorized user could execute a constrained function");   
         
        (success, data) = address(proofOfLifeProxyContract).call(abi.encodeWithSignature("certifyDocument(string)", "hash1"));
        Assert.equal(success, false, "certifyDocument: Non authorized user could execute a constrained function");   

    }
}