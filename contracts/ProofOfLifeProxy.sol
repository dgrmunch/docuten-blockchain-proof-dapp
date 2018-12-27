pragma solidity ^0.5.0;

import "./HasAuditRegistry.sol";

/* @title Proof of Life Proxy with delegateCall */
contract ProofOfLifeProxy is HasAuditRegistry {
 
  // State
  address public delegatedContractAddress;
  address public contractOwner;
  bool public isOpenToEveryUser;
  uint256 private lastId = 0;
  bool public isLocked;
  mapping(bytes32  => uint256) public idByDocumentHash;
  mapping(uint256  => address) public ownerByDocumentId;
  mapping(uint256  => string) private ipfsHashByDocumentId;
  mapping(uint256  => string) private hashByDocumentId;
  mapping(address  => uint256[]) private documentsByOwnerAddress;
  mapping(uint256 => AuditRegistry[]) public auditRegistryByDocumentId;
  mapping(address  => bool) public authorizedUsers;
  
  
  /* @notice Lock contract
   * @dev Maintenance and security circuit locker
   */
  function lock() public{
  /*   uint256256 val = 100;
      delegatedContractAddress.delegatecall(abi.encodeWithSignature("foo(uint256256,uint256256)")), val, val);
    delegatedContractAddress.delegatecall(bytes4(keccak256("storeValue(uint256256)")), val);
    bytes memory delegateBytes = bytes4(keccak256("lock()"));
    contractAddress.delegatecall(delegateBytes);*/

  }
}