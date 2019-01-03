pragma solidity ^0.5.0;


/* @title CredentialsConstrained */
contract CredentialsConstrained {
    
    // State
    mapping(address  => bool) public authorizedUsers;
    address public contractOwner;
    bool public isOpenToEveryUser;
    
    // Events
    event AuthorizedUserAdded(address user);
    event CredentialsRemoved(address user);
    
    // Modifiers
    modifier onlyContractOwner() { 
        require(msg.sender == contractOwner, 
        "E-CC-001 - Only the contract owner add execute this transaction"); 
        _; 
    }

    modifier onlyAuthorizedUsers() { 
        require(authorizedUsers[msg.sender] || isOpenToEveryUser, 
        "E-CC-002 - Only authorized users can execute this transaction"); 
        _; 
    }

    modifier onlyWhenOpenToEveryUser() { 
        require(isOpenToEveryUser, 
        "E-CC-003 - Certification operations are already closed to every user"); 
        _; 
    }

    modifier onlyWhenCloseToEveryUser() { 
        require(!isOpenToEveryUser, 
        "E-CC-004 - Certification operations are already open to every user"); 
        _; 
    }
  
    /* @notice Constructor
    * @dev Initializes contract instance with the sender
    * as both document owner and an authorizedUser.
    */
    constructor() public {    
        contractOwner = msg.sender;
        authorizedUsers[contractOwner] = true;
    }
    
    /* @notice Fallback function
    /* @dev It reverts the transaction for security reasons
    */
    function() external {
        revert();
    }

    /* @notice Add authorized user
    * @dev Includes a new user in the authorized users list
    * @param user - the address you want to authorize
    */
    function addAuthorizedUser(address user) public onlyContractOwner {
        authorizedUsers[user] = true;
        emit AuthorizedUserAdded(user);
    }
    
    /* @notice Remove credentials
    * @dev Remove credentials of an authorized user
    * @param user - the authorized address to be removed
    */
    function removeCredentials(address user) public onlyContractOwner {
        delete authorizedUsers[user];
        emit CredentialsRemoved(user);
    }
    
    /* @notice Open to every user
    * @dev Allows every address to certify documents in the contract
    */
    function openToEveryUser() public onlyContractOwner onlyWhenCloseToEveryUser {
        isOpenToEveryUser = true;
    }
    
    /* @notice Close to authorized users
    * @dev Only allows document certification to authorized users
    */
    function closeToAuthorizedUsers() public onlyContractOwner onlyWhenOpenToEveryUser {
        isOpenToEveryUser = false;
    }

}