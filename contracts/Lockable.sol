pragma solidity ^0.5.0;

import "./CredentialsConstrained.sol";


/* @title Lockable */
contract Lockable is CredentialsConstrained {
  
    // State
    bool public isLocked;
  
    // Events
    event ContractLocked();
    event ContractUnlocked();
    
    /* Modifiers */
    modifier onlyWhenUnlocked() { require(!isLocked, "E-LOCK-001 - Contract temporary locked."); _; }
    modifier onlyWhenLocked() { require(isLocked, "E-LOCK-002  - This contract is already unlocked."); _; }

    /* @notice Fallback function
    /* @dev It reverts the transaction for security reasons
    */
    function() external {
        revert();
    }

    /* @notice Lock contract
    * @dev Maintenance and security circuit locker
    */
    function lock() public onlyWhenUnlocked onlyContractOwner{
        isLocked = true;
        emit ContractLocked();
    }
    
    /* @notice Unlock contract
    * @dev Maintenance and security circuit unlocker
    */
    function unlock() public onlyWhenLocked onlyContractOwner{
        isLocked = false;
        emit ContractUnlocked();
    }
    
    /* @notice Add authorized user (overrided function with new modifier)
    * @dev Includes a new user in the authorized users list
    * @param user - the address you want to authorize
    */
    function addAuthorizedUser(address user) public onlyWhenUnlocked onlyContractOwner {
        authorizedUsers[user] = true;
        emit AuthorizedUserAdded(user);
    }
    
    /* @notice Remove credentials (overrided function with new modifier)
    * @dev Remove credentials of an authorized user
    * @param user - the authorized address to be removed
    */
    function removeCredentials(address user) public onlyWhenUnlocked onlyContractOwner {
        delete authorizedUsers[user];
        emit CredentialsRemoved(user);
    }
      
    /* @notice Open to every user  (overrided function with new modifier)
    * @dev Allows every address to certify documents in the contract
    */
    function openToEveryUser() public onlyWhenUnlocked onlyContractOwner onlyWhenCloseToEveryUser {
        isOpenToEveryUser = true;
    }
    
    /* @notice Close to authorized users  (overrided function with new modifier)
    * @dev Only allows document certification to authorized users
    */
    function closeToAuthorizedUsers() public onlyWhenUnlocked onlyContractOwner onlyWhenOpenToEveryUser {
        isOpenToEveryUser = false;
    }
  
}