pragma solidity ^0.5.0;

import "./HasAuditRegistry.sol";


/* @title Proof of Life Proxy with delegateCall */
contract ProofOfLifeProxy is HasAuditRegistry {
 
    // State
    address public delegateCallAddress;
    address public contractOwner;

    // Data (updated by updgradable delegate contract)
    bool public isLocked; //Todo: borrar eso. solo para prueba

    // Local functions
    /* @notice Proxy constructor
    * @dev It creates a proxy instance
    * @param _existingContractAddress - the new delegated contract address
    */
    constructor (address existingContractAddress) public {
        delegateCallAddress = existingContractAddress;
        contractOwner = msg.sender;
    }

    /* @notice Update Delegate Call Address
    * @dev It allows the owner to update the address of the delegate contract
    * @param _existingContractAddress - the new delegated contract address
    */
    function updateDelegateCallAddress(address existingContractAddress) public {
        require(msg.sender == contractOwner, "E-POLP-001 - Only the contract owner add execute this transaction"); 
        delegateCallAddress = existingContractAddress;
    }

    /* @notice Lock contract
    * @dev Maintenance and security circuit locker
    */
    function lock() public {
        uint256256 val = 100;
        delegatedContractAddress.delegatecall(address(proofOfLifeContract).delegatecall(abi.encodeWithSignature("certifyDocumentCreationWithIPFSHash()"));
        // delegatedContractAddress.delegatecall(address(proofOfLifeContract).delegatecall(abi.encodeWithSignature(
        //"certifyDocumentCreationWithIPFSHash(string,string,string)", "hash4", "ipfsHash1", ""));
    }


    // Functions with delegateCall
    //certifyDocumentCreationWithIPFSHash
    //appendAuditRegistry
    //getDocumentDetailsByHash
    //countAuditRegistriesByDocumentHash
    //getAuditRegistryByDocumentHash
    //getDocumentsByOwner
    //getDocumentDetailsById


      
}