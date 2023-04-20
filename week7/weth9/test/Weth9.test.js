const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Weth9", () => {

  let weth;
  let user1, user2;
  let amount = ethers.utils.parseEther("1.0");
  let amountHuge = ethers.utils.parseEther("10");

  beforeEach(async () => {
    // 1. get the signers
    [user1, user2] = await ethers.getSigners();
    // 2. get contract factory
    const Weth = await ethers.getContractFactory("WETH9");
    // 3. deploy
    weth = await Weth.deploy();
  })

  it("測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user", async () => {
    // 1. get balance before deposit;
    let balanceBefore = await weth.balanceOf(user1.address);
    // 2. deposit
    await weth.connect(user1).deposit({ value: amount });
    // 3. get balance after deposit;
    let balanceAfter = await weth.balanceOf(user1.address);
    // 4. compare
    expect(balanceAfter).to.equal(balanceBefore.add(amount));
  })

  it("測項 2: deposit 應該將 msg.value 的 ether 轉入合約", async () => {
    // 1. get totalSupply before deposit;
    let balanceBefore = await weth.totalSupply();
    // 2. deposit
    await weth.connect(user1).deposit({ value: amount });
    // 3. get totalSupply after deposit;
    let balanceAfter = await weth.totalSupply();
    // 4. compare
    expect(balanceAfter).to.equal(balanceBefore.add(amount));
  })

  it("測項 3: deposit 應該要 emit Deposit event", async () => {
    // 1. check emit event == Deposit, parameters in withArgs (doc 寫法)
    await expect(weth.connect(user1).deposit({ value: amount }))
      .to.emit(weth, "Deposit")
      .withArgs(user1.address, amount);

    /* others (自己想的寫法)
      let tx = await weth.connect(user1).deposit({ value: amount });
      let receipt = await tx.wait();

      expect(receipt.events.length).to.gt(0);
      // then filter event name eq to Deposit
    */
  })

  it("測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 erc20 token", async () => {
    // 1. deposit 10 ETH
    await weth.connect(user1).deposit({ value: amountHuge });
    // 2. get totalSupply before withdraw;
    let balanceBefore = await weth.totalSupply();
    // 3. withdraw 1 ETH
    await weth.connect(user1).withdraw(amount);
    // 4. get totalSupply after withdraw;
    let balanceAfter = await weth.totalSupply();
    // 5. compare
    expect(balanceAfter).to.equal(balanceBefore.sub(amount));
  })

  it("測項 5: withdraw 應該將 burn 掉的 erc20 換成 ether 轉給 user", async () => {
    // 1. deposit 10 ETH to contract
    await weth.connect(user1).deposit({ value: amountHuge });
    // 2. get ethBalance before withdraw;
    let ethBalanceBefore = await ethers.provider.getBalance(user1.address);
    // 3. withdraw 1 ETH  (-1 ETH)
    await weth.connect(user1).withdraw(amount);
    // 4. get ethBalance after withdraw;
    let ethBalanceAfter = await ethers.provider.getBalance(user1.address);
    // 5. compare (not equal because there is gas used)
    // 這種比較方式會不會不夠精確，有沒有更精準的確認方式？
    expect(ethBalanceAfter).to.be.gt(ethBalanceBefore);
    expect(ethBalanceAfter).to.be.lt(ethBalanceBefore.add(amount));
  })

  it("測項 6: withdraw 應該要 emit Withdraw event", async () => {
    // 1. deposit 10 ETH to contract
    await weth.connect(user1).deposit({ value: amountHuge });
    // 2. withdraw 1 ETH, check emit event == Withdraw, parameters in withArgs
    await expect(weth.connect(user1).withdraw(amount))
      .to.emit(weth, "Withdrawal")
      .withArgs(user1.address, amount);
  })

  it("測項 7: transfer 應該要將 erc20 token 轉給別人", async () => {
    // 1. user1 deposit 10 ETH to contract
    await weth.connect(user1).deposit({ value: amountHuge });
    // 2. get balance before transfer
    let balanceBefore = await weth.balanceOf(user2.address);
    // 3. transfer 1 ETH to user2 address
    await weth.connect(user1).transfer(user2.address, amount);
    // 4. get balance after transfer
    let balanceAfter = await weth.balanceOf(user2.address);
    // 5. compare
    expect(balanceAfter).to.equal(balanceBefore.add(amount));
  })

  it("測項 8: approve 應該要給他人 allowance", async () => {
    // 1. get allowance before approve
    let allowanceBefore = await weth.allowance(user1.address, user2.address);
    // 2. user1 approve user2 of amount 1 ETH
    await weth.connect(user1).approve(user2.address, amount);
    // 3. get allowance after approve
    let allowanceAfter = await weth.allowance(user1.address, user2.address);
    // 4. compare
    expect(allowanceAfter).to.equal(allowanceBefore.add(amount));
  })

  it("測項 9: transferFrom 應該要可以使用他人的 allowance", async () => {
    // 1. user1 deposit 10 ETH to contract
    await weth.connect(user1).deposit({ value: amountHuge });
    // 2. user1 approve user2 of amount 1 ETH (user2 have allownance of user1 of 1 ETH)
    await weth.connect(user1).approve(user2.address, amount);
    // 3. get receipt of user2 call transferFrom
    let tx = await weth.connect(user2).transferFrom(user1.address, user2.address, amount);
    let receipt = await tx.wait();
    // 4. compare (if status === 1, means user2 call transferFrom, use allownce successfully)
    expect(receipt.status).to.equal(1);
  })

  it("測項 10: transferFrom 後應該要減除用完的 allowance", async () => {
    // 1. user1 deposit 10 ETH to contract
    await weth.connect(user1).deposit({ value: amountHuge });
    // 2. user1 approve user2 of amount 10 ETH (user2 have allownance of user1 of 10 ETH)
    await weth.connect(user1).approve(user2.address, amountHuge);
    // 3. get allowance before transferFrom
    let allowanceBefore = await weth.allowance(user1.address, user2.address);
    // 4. user2 call transferFrom to use allownance of user1 of 1 ETH to transfer 1 ETH to him
    await weth.connect(user2).transferFrom(user1.address, user2.address, amount);
    // 5. get allowance after transferFrom
    let allowanceAfter = await weth.allowance(user1.address, user2.address);
    // compare
    expect(allowanceAfter).to.equal(allowanceBefore.sub(amount));

    // console.log(allowanceBefore);
    // console.log(allowanceAfter);
  })

  // more
  it("測項 11-1: name 要等於 'Wrapped Ether'", async () => {
    let name = await weth.name();
    expect(name).to.equal("Wrapped Ether");
  })

  // it("測項 11-2: 驗證 withdraw 錯誤", async () => {
  //   // user1 wants to withdraw 1 ETH, but dont have enough amount to do that.
  //   await expect(weth.connect(user1).withdraw(amount)).to.be.revertedWith('withdraw exceed user balance');
  // })
})