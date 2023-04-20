const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MyContract", () => {

  let instance;
  let user1, user2;

  beforeEach(async () => {
    // TODO:
    // 1. get the signers
    [user1, user2] = await ethers.getSigners();

    // 2. get contract factory
    const Contract = await ethers.getContractFactory("MyContract");
    // 3. deploy with parameters
    instance = await Contract.deploy(user1.address, user2.address);
  })

  it("should return user1 and user2 correctly", async () => {
    // TODO:
    // 1. instance's user1 is equal to user1's address
    expect(await instance.user1()).to.equal(user1.address);
    // 2. instance's user2 is equal to user2's address
    expect(await instance.user2()).to.equal(user2.address);
  })

  it("instance should be able to receive token", async () => {
    // TODO:
    // 1. Create a transaction to send 1 ether to instance
    const tx = await user1.sendTransaction({
      to: instance.address,
      value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
    });
    const receipt = await tx.wait();
    // 2. expect the transaction to be successful
    expect(receipt.status).to.equal(1);
    // 3. expect the instance's balance to change by 1 ether
    expect(instance).to.changeEtherBalance(ethers.utils.parseEther("1.0"));
  })
})