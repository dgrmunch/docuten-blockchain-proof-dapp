pragma solidity ^0.5.0;

import "./HasAuditRegistry.sol";


/* @title Proof of Life Proxy with delegateCall */
contract ProofOfLifeProxy is HasAuditRegistry {
 
    // State variables (to be updated by delegateCalls)
    mapping(address  => bool) public authorizedUsers;
    address public contractOwner; //used to override the delegate contractOwner value with the proxy contract's address
    bool public isOpenToEveryUser;
    bool public isLocked;
    uint256 private lastId = 0;
    mapping(bytes32  => uint256) public idByDocumentHash;
    mapping(uint256  => address) public ownerByDocumentId;
    mapping(uint256  => string) public ipfsHashByDocumentId;
    mapping(uint256  => string) public hashByDocumentId;
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
    
    // ------ Local functions -------
    
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

    
    /* @notice Update contractOwner
    * @dev It forces the update of all credentials with the proxy address
    */
    function addProxyAsAuthorizedUser() public onlyContractOwner {
         (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodePacked(bytes4(keccak256("addAuthorizedUser(address)")), address(this)));
         emit DelegateCallEvent("addAuthorizedUser", success);
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

    /* @notice Certify document creation with hash and timestamp
    * @dev It registers in the blockchain the proof-of-existence of an external document
    * @param _documentHash - Hash of the document (it should have 32 bytes)
    * @param _ipfsHash - IPFS Hash, if it exists 
    * @return id - returns certified document id
    */
    function certifyDocumentCreationWithIPFSHash(string memory _documentHash, string memory _ipfsHash,
    string memory _timestamp) public onlyContractOwner returns(uint256) {
        (bool success, bytes memory data)  = delegateCallAddress.delegatecall(abi.encodePacked(bytes4(keccak256("test(string,string)")), "a","b"));
        emit DelegateCallEvent("certifyDocument", success);
    }


 /* @notice Get documents owned by proxy
    * @dev Retrieves a list with all the documents hashes of the proxy address
    * @return bytes32[] documentsByOwnerAddress
    */
    function getDocumentsOwnedByProxy() public view 
    returns(uint256[] memory) {
        return documentsByOwnerAddress[address(this)];
    }
    
    //certifyDocumentCreationWithIPFSHash
    //appendAuditRegistry
    //getDocumentDetailsByHash
    //countAuditRegistriesByDocumentHash
    //getAuditRegistryByDocumentHash
    //getId
    //getDocumentDetailsById


      
}