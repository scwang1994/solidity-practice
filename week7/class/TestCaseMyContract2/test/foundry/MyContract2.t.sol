// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "forge-std/Test.sol";
import {MyContract} from "../../contracts/MyContract2.sol";

contract MyContractTest is Test {
    MyContract instance;
    address user1;
    address user2;
    address user3;
    event SendETH(address to, uint256 amount);

    function setUp() public {
        // TODO:
        // 1. Set user1, user2
        user1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        user2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        user3 = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        // 2. Create a new instance of MyContract
        instance = new MyContract(user1, user2);
    }

    function testConstructor() public {
        // 1. Assert instance.user1() is user1
        assertEq(instance.user1(), user1);
        // 2. Assert instance.user2() is user2
        assertEq(instance.user2(), user2);
    }

    function testLimitedSender() public {
        // 1. pretending you are user3
        vm.startPrank(user3);
        // 2. set revert check
        vm.expectRevert(bytes("only user1 or user2 can send"));
        // 3. user3 send ether
        instance.sendETH(user2, 1 ether);
        // 4. stop pretending
        vm.stopPrank();
    }

    function testAmountLimit() public {
        // 1. pretending you are user1
        vm.startPrank(user1);
        // 2. set revert check
        vm.expectRevert(bytes("insufficient balance"));
        // 3. user1 send ether
        instance.sendETH(user2, address(this).balance + 1 ether);
        // 4. stop pretending
        vm.stopPrank();
    }

    function testSend() public {
        // 1. pretending you are user1
        vm.startPrank(user1);
        // 2. let this has 10 ether
        vm.deal(address(instance), 10 ether);
        // 3. user1 send ether to user2
        instance.sendETH(user2, 1 ether);
        // 4. compare
        assertEq(user2.balance, 1 ether);
        // 5. stop pretending
        vm.stopPrank();
    }

    function testEmitSendEvent() public {
        // 1. pretending you are user1
        vm.startPrank(user1);
        // 2. let this has 10 ether
        vm.deal(address(instance), 10 ether);
        // 3. check emit
        vm.expectEmit(true, false, false, true);
        // 4. set emit expect to see
        emit SendETH(user2, 1 ether);
        // 3. user1 send ether to user2
        instance.sendETH(user2, 1 ether);
        // 5. stop pretending
        vm.stopPrank();
    }
}
