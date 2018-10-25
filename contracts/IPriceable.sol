pragma solidity ^0.4.25;

/**
 * @title Priceable
 * @dev 
 */
contract IPriceable {
    
    // events
    event PriceChangedLog(uint256 id, uint oldValue, uint256 newValue);
    event SaleLog(address sellerAddress, uint256 id, bool saleStatus);

    // functions
    function setPrice(uint256 _id, uint256 _value) public;

    function getPrice(uint256 _id) external view  returns (uint256 _idPrice);

    function isSale(uint _id) external view returns (bool _saleStatus);

    function setSale(uint _id, bool _saleStatus) public;
}