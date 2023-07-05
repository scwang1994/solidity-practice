// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {EIP20Interface} from "compound-protocol/contracts/EIP20Interface.sol";
import {CErc20} from "compound-protocol/contracts/CErc20.sol";
import "test/helper/CompoundPracticeSetUp.sol";

interface IBorrower {
    function borrow() external;
}

contract CompoundPracticeTest is CompoundPracticeSetUp {
    EIP20Interface public USDC =
        EIP20Interface(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    address public user;

    IBorrower public borrower;

    function setUp() public override {
        uint256 forkId = vm.createFork(
            vm.envString("MAINNET_RPC_URL"),
            12299047
        );
        // 3. select fork
        vm.selectFork(forkId);

        super.setUp();

        // Deployed in CompoundPracticeSetUp helper
        borrower = IBorrower(borrowerAddress);

        user = makeAddr("User");

        uint256 initialBalance = 10000 * 10 ** USDC.decimals();
        deal(address(USDC), user, initialBalance);

        vm.label(address(cUSDC), "cUSDC");
        vm.label(borrowerAddress, "Borrower");
    }

    function test_compound_mint_interest() public {
        vm.startPrank(user);
        // TODO: 1. Mint some cUSDC with USDC
        EIP20Interface(USDC).approve(
            address(cUSDC),
            EIP20Interface(USDC).balanceOf(user)
        );
        cUSDC.mint(EIP20Interface(USDC).balanceOf(user));
        // TODO: 2. Modify block state to generate interest
        vm.roll(13000000);
        // TODO: 3. Redeem and check the redeemed amount
        cUSDC.redeem(CErc20(cUSDC).balanceOf(user));
        vm.stopPrank();
        assertGt(
            EIP20Interface(USDC).balanceOf(user), // 10141475678
            10000 * 10 ** USDC.decimals()
        );
    }

    function test_compound_mint_interest_with_borrower() public {
        vm.startPrank(user);
        // TODO: 1. Mint some cUSDC with USDC
        EIP20Interface(USDC).approve(
            address(cUSDC),
            EIP20Interface(USDC).balanceOf(user)
        );
        cUSDC.mint(EIP20Interface(USDC).balanceOf(user));
        // 2. Borrower.borrow() will borrow some USDC
        borrower.borrow();
        // TODO: 3. Modify block state to generate interest
        vm.roll(13000000);
        // TODO: 4. Redeem and check the redeemed amount
        cUSDC.redeem(CErc20(cUSDC).balanceOf(user));
        vm.stopPrank();
        assertGt(
            EIP20Interface(USDC).balanceOf(user), // 10148058649
            10000 * 10 ** USDC.decimals()
        );
    }
}
