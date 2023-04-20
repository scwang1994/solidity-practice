// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

interface IBYAC {
    function mintApe(uint numberOfTokens) external payable;

    function balanceOf(address owner) external view returns (uint256 balance);
}

contract TestCase is Test {
    IBYAC bayc;
    uint256 forkId;
    address user1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address baycAddr = 0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D;

    string MAINNET_RPC_URL =
        "https://eth-mainnet.g.alchemy.com/v2/Pl6OPgnY0_d3PT09U1iddzBXevWmiIKa";

    function setUp() public {
        // 1. set bayc
        bayc = IBYAC(baycAddr);
        // 2. create fork
        forkId = vm.createFork(MAINNET_RPC_URL, 12299047);
        // 3. select fork
        vm.selectFork(forkId);
    }

    // 1. set forkMainnet
    function testForkMainnet() public {
        // check block number
        assertEq(block.number, 12299047);
    }

    // 2. test mint number and check baycAddr get ether
    function testMint() public {
        // 1. pretending you are user1
        vm.startPrank(user1);
        // 2. let user1 have 8 ether
        vm.deal(user1, 80 ether);
        // 3. get balance before mint
        uint balanceBefore = baycAddr.balance;
        // 4. mint Ape
        for (uint i = 0; i < 5; i++) {
            bayc.mintApe{value: 1.6 ether}(20);
        }
        // 5. check mint 100 bayc
        uint mintNum = bayc.balanceOf(user1);
        assertEq(mintNum, 100);
        // 6. get balance after mint
        uint balanceAfter = baycAddr.balance;
        // 7. check bayc get eth
        assertEq(balanceAfter - balanceBefore, 8 ether);
        vm.stopPrank();
    }
}
