pragma solidity ^0.5.0;

import "./ProofOfExistence.sol";
import "./HasAuditRegistry.sol";


/* @title Proof of Life */
contract ProofOfLife  is ProofOfExistence, HasAuditRegistry {
    
    // State
    mapping(uint256 => AuditRegistry[]) public auditRegistryByDocumentId;

    // Events
    event DocumentCreation (uint256 id, string description, string timestamp, uint256 blockTimestamp);
    event NewAuditRegistry (uint256 id, string description, string timestamp, uint256 blockTimestamp);
      
    /* @notice Fallback function
    /* @dev It reverts the transaction for security reasons
    */
    function() external {
        revert();
    }
    
    /* @notice Certify document creation with hash and timestamp
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - Hash of the document (it should have 32 bytes)
    * @return id - returns certified document id
    */
    function certifyDocumentCreation(string memory _documentHash, string memory _timestamp) 
    public onlyAuthorizedUsers onlyWhenUnlocked returns(uint256) {
        return certifyDocumentCreation(_documentHash, "", _timestamp);
    }
    
    /* @notice Certify document creation with hash and timestamp
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - Hash of the document (it should have 32 bytes)
    * @param _ipfsHash - IPFS Hash, if it exists 
    * @return id - returns certified document id
    */
    function certifyDocumentCreationWithIPFSHash(string memory _documentHash, string memory _ipfsHash,
    string memory _timestamp) public onlyAuthorizedUsers onlyWhenUnlocked returns(uint256) {
        return certifyDocumentCreation(_documentHash, _ipfsHash, _timestamp);
    }

    /* @notice Certify document creation
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - MD5 Hash of the document (it should have 32 bytes)
    * @param _ipfsHash - IPFS Hash, if it exists 
    * @return _id - returns certified document id
    */
    function certifyDocumentCreation(string memory _documentHash, string memory _ipfsHash,
    string memory _timestamp) public onlyAuthorizedUsers onlyWhenUnlocked returns(uint256) {
        
        uint256 _id = certifyDocument(_documentHash, _ipfsHash);
        
        //Create an AuditRegistry with a description.
        AuditRegistry memory creationRegistry = AuditRegistry(
                                              { timestamp: _timestamp, 
                                                blockTimestamp: block.timestamp, 
                                                description: "{statusChange: 'CERTIFIED'}" }
        );

        auditRegistryByDocumentId[_id].push(creationRegistry);
        
        emit DocumentCreation(_id, creationRegistry.description, 
        creationRegistry.timestamp, creationRegistry.blockTimestamp);
        
        return _id;
    }  
    
    /* @notice Append Audit Registry
    * @dev A document owner can use this function to append audit information to it
    * @param _id - Id of the document
    * @param _description - Content of the audit registry (status change, extra information, etc...)
    * @param _timestamp - Local timestamp (UNIX Epoch format) from the external
    * system or the UI which executes the contract
    */
    function appendAuditRegistry(uint256 _id, string memory _description, string memory _timestamp) 
    public onlyAuthorizedUsers onlyWhenUnlocked {
        
        require(_id != 0, "E-POL-001- There is not a certified document with that identifier");

        require(ownerByDocumentId[_id] == msg.sender, 
        "E-POL-003 - Only the document owner can append audit registry transactions");
        
        AuditRegistry memory auditRegistry = AuditRegistry(
                                                        { timestamp: _timestamp,
                                                          blockTimestamp: now,
                                                          description: _description }
        );
                                                    
        auditRegistryByDocumentId[_id].push(auditRegistry);
        emit NewAuditRegistry(_id, auditRegistry.description, auditRegistry.timestamp, auditRegistry.blockTimestamp);
        
    }

    /* @notice Get auditRegistry by documentHash
    * @dev Retrieves the audit registry of a document
    * @param _documentHash - Hash of the document
    * @param _index - Position of the auditRegistry in the list
    * @return string description, string timestamp, uint256 blockTimestamp
    */
    function getAuditRegistryByDocumentHash(string memory _documentHash, uint256 _index) public view
    returns (string memory, string memory, uint256) {
        uint256 _id = getId(_documentHash);
        return getAuditRegistryByDocumentId(_id, _index);
    }
      
    /* @notice Get auditRegistry by documentId
    * @dev Retrieves the audit registry of a document
    * @param _id - Id of the document
    * @param _index - Position of the auditRegistry in the list
    * @return string description, string timestamp, uint256 blockTimestamp
    */
    function getAuditRegistryByDocumentId(uint256 _id, uint256 _index) public view
    returns (string memory, string memory, uint256) {
        return (auditRegistryByDocumentId[_id][_index].description,
        auditRegistryByDocumentId[_id][_index].timestamp, auditRegistryByDocumentId[_id][_index].blockTimestamp);
    }
      
    /* @notice CountAuditRegistries by hash
    * @dev Count the number of audit registries of a document
    * @param _documentHash - Hash of the document
    * @return uint256 number of elements
    */
    function countAuditRegistriesByDocumentHash(string memory _documentHash) public view returns(uint256) {
        uint256 _id = getId(_documentHash);
        return auditRegistryByDocumentId[_id].length;
    }

    /* @notice CountAuditRegistries by id
    * @dev Count the number of audit registries of a document
    * @param _id - Id of the document
    * @return uint256 number of elements
    */
    function countAuditRegistriesByDocumentId(uint256 _id) public view returns(uint256) {
        return auditRegistryByDocumentId[_id].length;
    }

}
