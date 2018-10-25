pragma solidity ^0.4.25;

import "./IBuyable.sol";
import "./IPriceable.sol";
import "./IBuyMechanism.sol";

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address _to, uint256 value) public returns (bool) {
    require(_to != address(0));
    require(value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[_to] = balances[_to].add(value);
    emit Transfer(msg.sender, _to, value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param value The amount of token to be burned.
   */
  function burn(uint256 value) public {
    _burn(msg.sender, value);
  }

  function _burn(address _who, uint256 value) internal {
    require(value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(value);
    totalSupply_ = totalSupply_.sub(value);
    emit Burn(_who, value);
    emit Transfer(_who, address(0), value);
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(value <= balances[_from]);
    require(value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(value);
    balances[_to] = balances[_to].add(value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(value);
    emit Transfer(_from, _to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 value) public returns (bool) {
    allowed[msg.sender][_spender] = value;
    emit Approval(msg.sender, _spender, value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;

  address public minter;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner || msg.sender == minter);
    _;
  }


  function setMinter(address allowedMinter) public onlyOwner returns (bool) {
    minter = allowedMinter;
    return true;
  }
  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


// File: openzeppelin-solidity/contracts/token/ERC20/CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: contracts/HaraToken.sol

contract HaraTokenPrivate is IBuyMechanism, BurnableToken, CappedToken(1200000000 * (10 ** uint256(18))) {
    // token details
    string public constant name = "HaraToken";
    string public constant symbol = "HART";
    uint8 public constant decimals = 18;
    
    // initial supply of token
    uint256 public constant INITIAL_SUPPLY = 12000 * (10 ** 5) * (10 ** uint256(decimals));

    // network hart network id from deployed contract network, as for now,
    // 1: mainnet
    // 2: hara network
    uint8 public constant HART_NETWORK_ID = 2;
    
    uint256 public nonce;
    mapping (uint8 => mapping(uint256 => bool)) public mintStatus;

    // token transaction related storage
    struct Receipt { 
        address buyer;
        address seller;
        uint256 id;
        uint256 value;
    }
    mapping(uint256=>Receipt) private txReceipt;
    uint256 public receiptNonce;

    uint256 public transferFee;
    address public transferFeeRecipient;

    // events
    event BurnLog(uint256 indexed id, address indexed burner, uint256 value, bytes32 hashDetails, string data);
    event MintLog(uint256 indexed id, address indexed requester, uint256 value, bool status);
    event PaidLog(address from, address to, uint256 value);
    event ReceiptCreatedLog(uint256 receiptId, address buyer, address seller, uint256 id, uint256 value);
    event ItemBoughtLog(uint256 receiptId, address buyer, address seller, uint256 id, uint256 value);
    event TransferFeeChanged(uint256 oldFee, uint256 newFee, address modifierFee);
    event TransferFeeRecipientChanged(address oldRecipient, address newRecipient, address modifierRecipient);

    /**
    * @dev Modifier to check if an address have enough value to pay
    * @param buyer Buyer address.
    * @param value value of token to pay.
    */
    modifier haveEnoughToken (address buyer, uint256 value) {
        require(balanceOf(buyer) >= value, "buyer token is not enough");
        _;
    }

    /**
    * @dev Modifier to check if value to transfer more than transfer fee
    * @param value value of token transfer.
    */
    modifier valueMoreThanFee(uint256 value){
      require(value > transferFee, "value must be more than transfer fee");
        _;
    }

    constructor() public {
      transferFee = 10 * (10 ** uint256(decimals));
      emit TransferFeeChanged(0, transferFee, msg.sender);
      transferFeeRecipient = msg.sender;
      emit TransferFeeRecipientChanged(address(0), msg.sender, msg.sender);
    }

    function setTransferFee(uint feeValue) onlyOwner public {
      uint256 oldValue = transferFee;
      transferFee = feeValue;
      emit TransferFeeChanged(oldValue, transferFee, msg.sender);
    }

    function setTransferRecipient(address newRecipient) onlyOwner public {
      address oldRecipient = transferFeeRecipient;
      transferFeeRecipient = newRecipient;
      emit TransferFeeRecipientChanged(oldRecipient, transferFeeRecipient, msg.sender);
    }

    /**
    * @dev Function to burn tokens
    * @param value The amount of tokens to burn.
    * @param data String of description.
    */
    function doBurnToken(uint256 value, string data) private {
        burn(value);
        emit BurnLog(nonce, msg.sender, value, hashDetails(nonce, msg.sender, value, HART_NETWORK_ID), data);
        nonce = nonce.add(1);
    }

    /**
    * @dev Function to burn tokens with transfer fee
    * @param value The amount of tokens to burn.
    * @param data String of description.
    */
    function burnToken(uint256 value, string data) valueMoreThanFee(value) public {
      require(transfer(transferFeeRecipient, transferFee), "transfer fee failed");
      doBurnToken(value.sub(transferFee), data);
    }

    /**
    * @dev Function to burn tokens with transfer fee
    * @param value The amount of tokens to burn.
    */
    function burnToken(uint256 value) valueMoreThanFee(value) public {
      require(transfer(transferFeeRecipient, transferFee), "transfer fee failed");
      doBurnToken(value.sub(transferFee), "");
    }

    // /**
    // * @dev Function to burn tokens
    // * @param value The amount of tokens to burn.
    // * @param data String of description.
    // */
    // function doBurnToken(uint256 value, string data) internal {
    //     burn(value);
    //     emit BurnLog(nonce, msg.sender, value, hashDetails(nonce, msg.sender, value, HART_NETWORK_ID), data);
    //     nonce = nonce.add(1);
    // }



    /**
    * @dev Function to mint tokens
    * @param id The unique burn ID.
    * @param requester The address that will receive the minted tokens.
    * @param value The amount of tokens to mint.
    * @param hash Generated hash from burn function.
    * @return A boolean that indicates if the operation was successful.
    */
    function mintToken(uint256 id, address requester, uint256 value, bytes32 hash, uint8 from) public returns(bool) {
        require(mintStatus[from][id]==false, "id already requested for mint");
        bytes32 hashInput = hashDetails(id, requester, value, from);
        require(hashInput == hash, "request item are not valid");
        bool status = mint(requester, value);
        emit MintLog(id, requester, value, status);
        mintStatus[from][id] = status;
        return status;
    }

    /**
    * @dev Function to buy item with hart.
    * @param seller Seller address where the item recorded.
    * @param id Id of item to buy.
    * @param value The amount of tokens to pay the item.
    */
    function buy(address seller, uint256 id, uint256 value) public haveEnoughToken(msg.sender, value){
      IPriceable itemPrice = IPriceable(seller);
      require(itemPrice.isSale(id) == true, "item is not on sale");
      require(value >= itemPrice.getPrice(id), "value underpriced");
      require(transfer(seller, value), "Payment failed");
      emit PaidLog(msg.sender, seller, value);
      
      receiptNonce = receiptNonce.add(1);
      txReceipt[receiptNonce] = Receipt(msg.sender, seller, id, value);
      emit ReceiptCreatedLog(receiptNonce, msg.sender, seller, id, value);
      
      IBuyable item = IBuyable(seller);
      require(item.buy(receiptNonce), "buy proccess failed");
      emit ItemBoughtLog(receiptNonce, msg.sender, seller, id, value);
    }

    /**
    * @dev Function to get reciept from certain transaction receipt id.
    * @param receiptId Transaction receipt ID to know the details.
    * @return Tuple of buyer, seller, id, and value on reciept.
    */
    function getReceipt(uint256 receiptId) external view returns (address buyer, address seller, uint256 id, uint256 value){
      Receipt memory receipt =  txReceipt[receiptId];
      buyer = receipt.buyer;
      seller = receipt.seller;
      id = receipt.id;
      value = receipt.value;
    }

    /**
    * @dev Function to hash burn and mint details.
    * @param id The unique burn ID.
    * @param burner The address that will receive the minted tokens.
    * @param value The amount of tokens to mint.
    * @param hartNetworkID hart network id
    * @return bytes32 from keccak256 hash of inputs.
    */
    function hashDetails(uint256 id, address burner, uint256 value, uint8 hartNetworkID) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(id, burner, value, hartNetworkID));
    }   
}

