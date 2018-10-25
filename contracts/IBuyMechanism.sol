pragma solidity ^0.4.25;

/**
 * @title Buy Mechanism Interface
 * @dev 
 */
contract IBuyMechanism {

    function getReceipt(uint256 _txReceipt) external view returns (address buyer, address seller, uint256 id, uint256 value);

}