pragma solidity ^0.5.0;

import "./HasAuditRegistry.sol";


/* @title Proof of Life Proxy with delegateCall */
contract ProofOfLifeProxy is HasAuditRegistry {
 
    // State variables
    mapping(address  => bool) public authorizedUsers;
    address public contractOwner;
    bool public isOpenToEveryUser;
    bool public isLocked;
    uint256 public lastId = 0;
    mapping(bytes32  => uint256) public idByDocumentHash;
    mapping(uint256  => address) public ownerByDocumentId;
    mapping(uint256  => string) public ipfsHashByDocumentId;
    mapping(uint256  => bytes32) public hashByDocumentId;
    mapping(address  => uint256[]) public documentsByOwnerAddress;
    mapping(uint256 => AuditRegistry[]) public auditRegistryByDocumentId;
    
    // Delegate call address 
    address public delegateCallAddress;
    
    // Events
    event DelegateCallEvent (string call, bool result);

    // Modifiers
    modifier onlyContractOwner(){
        require(msg.sender == contractOwner, "E-POLP-001 - Only the proxy contract owner add execute this transaction"); 
        _; 
    }
    
    // ------ Local functions to update proxy configuration -------
    
    /* @notice Proxy constructor
    * @dev It creates a proxy instance
    * @param _existingContractAddress - the new delegated contract address
    */
    constructor (address existingContractAddress) public {
        delegateCallAddress = existingContractAddress;
        contractOwner = msg.sender;
        authorizedUsers[contractOwner] = true;
    }

    /* @notice Update Delegate Call Address
    * @dev It allows the owner to update the address of the delegate contract
    * @param _existingContractAddress - the new delegated contract address
    */
    function updateDelegateCallAddress(address existingContractAddress) public onlyContractOwner {
        delegateCallAddress = existingContractAddress;
    }


    //  ---- Functions with delegateCall -----

    /* @notice Lock contract
    * @dev Maintenance and security circuit locker
    */
    function lock() public onlyContractOwner {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodePacked(bytes4(keccak256("lock()"))));
        emit DelegateCallEvent("lock", success);
    }
    
    /* @notice Unlock contract
    * @dev Maintenance and security circuit locker
    */
    function unlock() public onlyContractOwner {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodePacked(bytes4(keccak256("unlock()"))));
        emit DelegateCallEvent("unlock", success);
    }

    /* @notice Add authorized user
    * @dev Includes a new user in the authorized users list
    * @param user - the address you want to authorize
    */
    function addAuthorizedUser(address user) public onlyContractOwner {
      
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodeWithSignature("addAuthorizedUser(address)", user));
        
        if (success) {
            emit DelegateCallEvent("addAuthorizedUser", success);
        } else {
            revert();
        }
    }
    
    /* @notice Remove credentials
    * @dev Remove credentials of an authorized user
    * @param user - the authorized address to be removed
    */
    function removeCredentials(address user) public onlyContractOwner {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodeWithSignature("removeCredentials(address)", user));
        
        if (success) {
            emit DelegateCallEvent("removeCredentials", success);
        } else {
            revert();
        }
    }
    
    /* @notice Open to every user
    * @dev Allows every address to certify documents in the contract
    */
    function openToEveryUser() public onlyContractOwner {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodeWithSignature("openToEveryUser()"));
        
        if (success) {
            emit DelegateCallEvent("openToEveryUser", success);
        } else {
            revert();
        }
    }
    
    /* @notice Close to authorized users
    * @dev Only allows document certification to authorized users
    */
    function closeToAuthorizedUsers() public onlyContractOwner {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodeWithSignature("closeToAuthorizedUsers()"));
        
        if (success) {
            emit DelegateCallEvent("closeToAuthorizedUsers", success);
        } else {
            revert();
        }
    }

    /* @notice Certify document creation with hash and timestamp
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - Hash of the document (it should have 32 bytes)
    * @param _ipfsHash - IPFS Hash, if it exists 
    * @return id - returns certified document id
    */
    function certifyDocumentCreationWithIPFSHash(bytes32 _documentHash, string memory _ipfsHash,
    string memory _timestamp) public {
       
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodeWithSignature("certifyDocumentCreationWithIPFSHash(bytes32,string,string)", _documentHash, _ipfsHash, _timestamp));
        
        if (success) {
            emit DelegateCallEvent("certifyDocumentCreationWithIPFSHash", success);
        } else {
            revert();
        }
    }

     /* @notice Append Audit Registry
    * @dev A document owner can use this function to append audit information to it
    * @param _id - Id of the document
    * @param _description - Content of the audit registry (status change, extra information, etc...)
    * @param _timestamp - Local timestamp (UNIX Epoch format) from the external
    * system or the UI which executes the contract
    */
    function appendAuditRegistry(uint256 _id, string memory _description, string memory _timestamp) 
    public {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodeWithSignature("appendAuditRegistry(uint256,string,string)", _id, _description, _timestamp));
        
        if (success) {
            emit DelegateCallEvent("appendAuditRegistry", success);
        } else {
            revert();
        }
    }
    
    // ------ Query functions to request information about the contract state -------
    
    /* @notice Get documents by owner
    * @dev Retrieves a list with all the documents ids of one owner
    * @return bytes32[] documentsByOwnerAddress
    */
    function getDocumentsByOwner(address owner) public view 
    returns(uint256[] memory) {
        return documentsByOwnerAddress[owner];
    }
    
     /* @notice Get Document Details
    * @dev Retrieves all the information of a document
    * @param _documentHash - Hash of the document
    * @return uint256 id, string docHash, string ipfsHash, address documentOwner
    */
    function getDocumentDetailsByHash(bytes32 _documentHash) public view
    returns (uint256, bytes32, string memory, address) {

        uint256 _id = getId(_documentHash);
        return (_id, hashByDocumentId[_id], ipfsHashByDocumentId[_id], ownerByDocumentId[_id]);
    }
    
    /* @notice Get auditRegistry by documentHash
    * @dev Retrieves the audit registry of a document
    * @param _documentHash - Hash of the document
    * @param _index - Position of the auditRegistry in the list
    * @return string description, string timestamp, uint256 blockTimestamp
    */
    function getAuditRegistryByDocumentHash(bytes32 _documentHash, uint256 _index) public view
    returns (string memory, string memory, uint256) {
        uint256 _id = getId(_documentHash);
        return getAuditRegistryByDocumentId(_id, _index);
    }
      
    /* @notice CountAuditRegistries by hash
    * @dev Count the number of audit registries of a document
    * @param _documentHash - Hash of the document
    * @return uint256 number of elements
    */
    function countAuditRegistriesByDocumentHash(bytes32 _documentHash) public view returns(uint256) {
        uint256 _id = getId(_documentHash);
        return auditRegistryByDocumentId[_id].length;
    }
  
    /* @notice Get Document Details
    * @dev Retrieves all the information of a document
    * @param _id - Id of the document
    * @return uint256 id, string docHash, address documentOwner
    */
    function getDocumentDetailsById(uint256 _id) public view
    returns (uint256, bytes32, string memory, address) {
        return (_id, hashByDocumentId[_id], ipfsHashByDocumentId[_id], ownerByDocumentId[_id]);
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
    
    /* @notice Get document id from hash
    * @dev Retrieves a document id from a string with the hash
    * @param _documentHash - Hash of the document
    * @return uint256
    */
    function getId(bytes32 _documentHash) public view 
    returns(uint256) { 
        return idByDocumentHash[_documentHash];
    }
}