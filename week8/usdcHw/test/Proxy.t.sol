// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {FiatTokenV3} from "../src/USDC.sol";
import {FiatTokenProxy} from "../src/Proxy.sol";

contract FiatTokenV3Test is Test {
    // Contract
    address proxyAddr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    string MAINNET_RPC_URL =
        "https://eth-mainnet.g.alchemy.com/v2/FV1NlKDA3WOn6s_Bg32c4q6Z9A02W1ng";

    // Owner and users
    address owner = 0xFcb19e6a322b27c06842A71e8c725399f049AE3a;
    address admin = 0x807a96288A1A408dBC13DE2b1d087d10356395d2;
    address masterMinter = 0xE982615d461DD5cD06575BbeA87624fda4e3de17;

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    // Contracts
    FiatTokenV3 fiatTokenV3;
    FiatTokenV3 proxyFiatTokenV3;
    FiatTokenProxy proxy;

    function setUp() public {
        // 1. Create fork
        uint256 forkId = vm.createFork(MAINNET_RPC_URL);
        vm.selectFork(forkId);
        // 2. Set Proxy with the proxyAddr
        proxy = FiatTokenProxy(proxyAddr);
        // 3. Deploys FiatTokenV3
        fiatTokenV3 = new FiatTokenV3();
        vm.startPrank(admin);
        // 4. Check proxy implementation != address of fiatTokenV3
        require(proxy.implementation() != address(fiatTokenV3));
        // 5. Proxy upgrade to fiatTokenV3
        proxy.upgradeTo(address(fiatTokenV3));
        // 6. Proxy implementation == address of fiatTokenV3
        assertEq(proxy.implementation(), address(fiatTokenV3));
        proxyFiatTokenV3 = FiatTokenV3(address(proxy));
        vm.stopPrank();
    }

    function testWhiteList() public {
        // Let's pretend that you are proxy owner
        vm.startPrank(owner);
        // Check user1 is not in the whitelist
        require(proxyFiatTokenV3.isWhitelisted(user1) == false);
        // Add user1 to whitelist
        proxyFiatTokenV3.updateWhitelister(user1);
        proxyFiatTokenV3.whitelist(user1);
        // User1 now is in the whitelist
        assertEq(proxyFiatTokenV3.isWhitelisted(user1), true);
        vm.stopPrank();
    }

    /*
    line64-line93 test user1 mint tokens with no limit
    line95-line115 test transfer works only if you are whitelisted
    */
    function testMintAndTransfer() public {
        // Let's pretend that you are masterMinter
        vm.startPrank(masterMinter);
        // Check user1 is not a minter
        require(proxyFiatTokenV3.isMinter(user1) == false);
        // Set user1 as a minter, minterAllowedAmount = 1
        proxyFiatTokenV3.configureMinter(user1, 1);
        // User1 now is a minter
        assertEq(proxyFiatTokenV3.isMinter(user1), true);
        vm.stopPrank();
        // Let's pretend that you are proxy owner
        vm.startPrank(owner);
        // Check user1 is not in the whitelist
        require(proxyFiatTokenV3.isWhitelisted(user1) == false);
        // Add user1 to whitelist
        proxyFiatTokenV3.updateWhitelister(user1);
        proxyFiatTokenV3.whitelist(user1);
        // User1 now is in the whitelist
        assertEq(proxyFiatTokenV3.isWhitelisted(user1), true);
        vm.stopPrank();
        // Let's pretend that you are user1
        vm.startPrank(user1);
        // Check user1 minterAllowedAmount = 1
        require(proxyFiatTokenV3.minterAllowance(user1) == 1);
        // Check user1 balance = 0
        require(proxyFiatTokenV3.balanceOf(user1) == 0);
        // User1 mint 1000 tokens (ignore minterAllowedAmount)
        proxyFiatTokenV3.mint(user1, 1000);
        // User1 now has 1000 tokens
        assertEq(proxyFiatTokenV3.balanceOf(user1), 1000);
        vm.stopPrank();

        // Let's pretend that you are user1
        vm.startPrank(user1);
        // Check user2 balance = 0
        require(proxyFiatTokenV3.balanceOf(user2) == 0);
        // User1 transfer 50 tokens to user2
        proxyFiatTokenV3.transfer(user2, 50);
        // User2 now has 50 tokens
        assertEq(proxyFiatTokenV3.balanceOf(user2), 50);
        vm.stopPrank();
        // Let's pretend that you are user2
        vm.startPrank(user2);
        // Check user1 balance = 950 (1000-50)
        require(proxyFiatTokenV3.balanceOf(user1) == 950);
        // Check user2 is not in the whitelist
        require(proxyFiatTokenV3.isWhitelisted(user2) == false);
        // User2 transfer 25 tokens to user1
        vm.expectRevert(bytes("Whitelistable: addr is not whitelisted"));
        proxyFiatTokenV3.transfer(user1, 25);
        // User2 now still has 50 tokens
        assertEq(proxyFiatTokenV3.balanceOf(user2), 50);
        vm.stopPrank();
    }

    function test
}
