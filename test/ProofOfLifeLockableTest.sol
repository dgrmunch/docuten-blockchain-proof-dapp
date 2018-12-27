pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/ProofOfLife.sol";


contract ProofOfLifeLockableTest {

    ProofOfLife proofOfLifeContract;

    function beforeEach () public {
        proofOfLifeContract = new ProofOfLife();
    }

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