import decodeLogs from './../openzeppelin-solidity/test/helpers/decodeLogs';
const expectRevert = require("./helpers/expectRevert")

const HaraTokenPrivate = artifacts.require('HaraTokenPrivate');
const DataStore = require('./helpers/DataStore.js')

contract('HaraTokenPrivate', accounts => {
  let token;
  let ds;
  const creator = accounts[0];
  const minter = accounts[1];
  const burner = accounts[2];
  const itemOwner = accounts[3];
  const buyer = accounts[4];
  const transferRecipient = accounts[5];
  const notOwner = accounts[6];

  before(async function () {
    // deploy hart contract
    token = await HaraTokenPrivate.new({ from: creator });
    
    // deploy data store contract
    var datastoreContract = new web3.eth.Contract(DataStore.abi);
    ds = await datastoreContract.deploy({
      data: DataStore.bytecode,
      arguments: ["2", itemOwner, web3.utils.asciiToHex("http://endpoint"), "0x430dec04b9ebe807ce8fb9b0d025861c13f5e36f226c12469ff6f89fb217fa9f",
                    web3.utils.asciiToHex("markle"), [web3.utils.asciiToHex("size"), web3.utils.asciiToHex("filename")], [web3.utils.asciiToHex("2MB"), web3.utils.asciiToHex("ktp.jpg")],
                    0, 10, token.address]
    }).send({
      from: itemOwner,
      gas: 4700000
    });
  });

  it('has a name', async function () {
    const name = await token.name();
    assert.equal(name, 'HaraToken');
  });

  it('has a symbol', async function () {
    const symbol = await token.symbol();
    assert.equal(symbol, 'HART');
  });

  it('has 18 decimals', async function () {
    const decimals = await token.decimals();
    assert.strictEqual(decimals.toNumber(), 18);
  });

  it('has HART Network ID', async function () {
    const networkId = await token.HART_NETWORK_ID();
    assert.strictEqual(networkId.toNumber(), 2);
  });

  it('assigns the initial total supply to the creator', async function () {
    const totalSupply = await token.totalSupply();
    const creatorBalance = await token.balanceOf(creator);

    assert.strictEqual(creatorBalance.toString(), totalSupply.toString());
    assert.strictEqual(totalSupply.toNumber(), 0);
  });

  describe('contract is mintable and burnable', async function () {
    before(async function () {
      await token.mint(creator, 500 * Math.pow(10, 18), {from: creator});
    });

    it('transfer 10 token to burner', async function () {
      // creator balance = 10000
      // burner balance = 50
      await token.transfer(burner, 50  * Math.pow(10, 18), { from: creator });
      const userToken = await token.balanceOf(burner);
      assert.strictEqual(userToken.toString(), (50  * Math.pow(10, 18)).toString());
    });
  
    it('burn 20 token and mint the same amount for account[0]', async function () {
      // creator balance = 500 - 50 = 450
      // burner balance  after burn = 50 + 50 - 20 = 80
      // burner balance  after mint = 40 + 20 = 60      
      await token.transfer(burner, 50  * Math.pow(10, 18), { from: creator });

      var creatorBefore = await token.balanceOf(creator);
      var txHash = await token.burnToken(20 * Math.pow(10, 18), "1this is tes", { from: burner });
      const receipt = await web3.eth.getTransactionReceipt(txHash.receipt.transactionHash);
      const logs = decodeLogs(receipt.logs, HaraTokenPrivate, token.address);
      const afterBurn = await token.balanceOf(burner);
      assert.strictEqual(afterBurn.toString(), (80  * Math.pow(10, 18)).toString());
      var creatorAfter = await token.balanceOf(creator);
      
      await token.mintToken(logs[3].args.id.valueOf(), logs[3].args.burner, 
            logs[3].args.value.valueOf(), logs[3].args.hashDetails, 2, { from: creator });
      const afterMint = await token.balanceOf(burner);
      
      assert.strictEqual(afterMint.toString(), (90  * Math.pow(10, 18)).toString());
      assert.strictEqual(creatorAfter-creatorBefore, (10  * Math.pow(10, 18)));
    });
  
    it('minted by minter instead of creator', async function (){
      await token.setMinter(minter, { from: creator });
      const allowedMinter = await token.minter();
      assert.strictEqual(allowedMinter, minter);
      
      
      await token.transfer(burner, 50  * Math.pow(10, 18), { from: creator });
      var txBurn = await token.burnToken(20  * Math.pow(10, 18), "1this is tes", { from: burner });
      const receiptBurn = await web3.eth.getTransactionReceipt(txBurn.receipt.transactionHash);
      const logsBurn = decodeLogs(receiptBurn.logs, HaraTokenPrivate, token.address);

      const txMint = await token.mintToken(logsBurn[3].args.id.valueOf(), logsBurn[3].args.burner, 
          logsBurn[3].args.value.valueOf(), logsBurn[3].args.hashDetails, 2, { from: minter });
      const receiptMint = await web3.eth.getTransactionReceipt(txMint.receipt.transactionHash);
      const logsMint = decodeLogs(receiptMint.logs, HaraTokenPrivate, token.address);
      assert.strictEqual(logsMint[2].args.status, true);
    });

    it('failed if burn value less than transaction fee', async function () {    
      var creatorBefore = await token.balanceOf(creator);
      var burnerBefore = await token.balanceOf(burner);
      await expectRevert(
        token.burnToken(5 * Math.pow(10, 18), "1this is tes", { from: burner })
      );
      var creatorAfter = await token.balanceOf(creator);
      var burnerAfter = await token.balanceOf(burner);

      assert.strictEqual(creatorBefore.toString(), creatorAfter.toString())
      assert.strictEqual(burnerBefore.toString(), burnerAfter.toString())
    });
  });
  describe('contract have buy mechanism', async function () {
    before(async function(){
      await token.transfer(buyer, 100, { from: creator });
    });

    it('can buy item', async function (){
      var before = await token.balanceOf(ds.options.address);
      var buyItem = await token.buy(ds.options.address, 0, 10, {from: buyer});
      var receipt = await token.getReceipt(1);

      var after = await token.balanceOf(ds.options.address);
      assert.strictEqual(before.toString(), "0");
      assert.strictEqual(after.toString(), "10");
      assert.strictEqual(receipt.buyer, buyer);
      assert.strictEqual(receipt.seller, ds.options.address);
      assert.strictEqual(receipt.id.toString(), "0");
      assert.strictEqual(receipt.value.toString(), "10")
    });

    it('can not buy item if price underpriced', async function (){
      var before = await token.balanceOf(buyer);
      await expectRevert(
      token.buy(ds.options.address, 0, 5, {from: buyer})
      );
      var after = await token.balanceOf(buyer);
      assert.strictEqual(before.toString(), after.toString());
    });
    it('can not buy item if buyer don\'t have enough token', async function (){
      var before = await token.balanceOf(buyer);
      await expectRevert(
        token.buy(ds.options.address, 0, 100, {from: buyer})
      );
      var after = await token.balanceOf(buyer);
      assert.strictEqual(before.toString(), after.toString());
    });
    it('can not buy item if seller address is not address', async function (){
      var before = await token.balanceOf(buyer);
      await expectRevert(
        token.buy("0", 0, 100, {from: buyer})
      );
      var after = await token.balanceOf(buyer);
      assert.strictEqual(before.toString(), after.toString());
    });

    it('revert token when buy failed', async function (){
      var before = await token.balanceOf(buyer);
      await expectRevert(
        // can't buy same item
        token.buy(ds.options.address, 0, 20, {from: buyer})
      );
      var after = await token.balanceOf(buyer);
      assert.strictEqual(before.toString(), after.toString());
    });
  });
  describe('have token bridge address and burn fee', async function () {

    it('set transfer fee recipient by owner', async function () {
      var receipt = await token.setTransferRecipient(transferRecipient, { from: creator });
      var newRecipient = await token.transferFeeRecipient();
      var log = receipt.logs[0];
      assert.strictEqual(newRecipient, transferRecipient);
      assert.strictEqual(log.args.oldRecipient, creator);
      assert.strictEqual(log.args.newRecipient, transferRecipient);
      assert.strictEqual(log.args.modifierRecipient, creator);
    });

    it('can not set transfer fee recipient by not owner', async function (){
      var before = await token.transferFeeRecipient();
      await expectRevert(
        token.setTransferRecipient(notOwner, { from: notOwner })
      );
      var after = await token.transferFeeRecipient();
      assert.strictEqual(before.toString(), after.toString());
    });

    it('set transfer fee  ', async function () {
      var receipt = await token.setTransferFee(20 * Math.pow(10, 18), { from: creator });
      var newFee = await token.transferFee();
      var log = receipt.logs[0];
      assert.strictEqual(newFee.toString(), (20 * Math.pow(10, 18)).toString());
      assert.strictEqual(log.args.oldFee.toString(), (10 * Math.pow(10, 18)).toString());
      assert.strictEqual(log.args.newFee.toString(), (20 * Math.pow(10, 18)).toString());
      assert.strictEqual(log.args.modifierFee.toString(), creator);
    });

    it('can not set transfer fee  by not owner', async function (){
      var before = await token.transferFee();
      await expectRevert(
        token.setTransferFee(50, { from: notOwner })
      );
      var after = await token.transferFee();
      assert.strictEqual(before.toString(), after.toString());
    });
  });
});