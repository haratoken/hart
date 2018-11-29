pragma solidity ^0.4.25;

/**
 * @title Priceable
 * @dev 
 */
contract IPriceable {
    
    // events
    event PriceChangedLog(string id, uint oldValue, uint256 newValue);
    event SaleLog(address sellerAddress, string id, bool saleStatus);

    // functions
    function setPrice(string _id, uint256 _value) public;

    function getPrice(string _id) external view  returns (uint256 _idPrice);

    function isSale(string _id) external view returns (bool _saleStatus);

    function setSale(string _id, bool _saleStatus) public;
}