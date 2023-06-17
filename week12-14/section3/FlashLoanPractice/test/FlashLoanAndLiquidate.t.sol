// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
// compound
import "compound-protocol/contracts/CErc20Delegate.sol";
import "compound-protocol/contracts/CErc20Delegator.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "compound-protocol/contracts/Unitroller.sol";
import "compound-protocol/contracts/Comptroller.sol";
import "compound-protocol/contracts/WhitePaperInterestRateModel.sol";
import "compound-protocol/contracts/SimplePriceOracle.sol";
// aave
import "../src/FlashLoanAndLiquidate.sol";

contract FlashLoanAndLiquidateTest is Test {
    // oracle
    SimplePriceOracle public priceOracle;
    // whitepaper
    WhitePaperInterestRateModel public whitePaper;
    // comprtroller
    Unitroller public unitroller;
    Comptroller public comptroller;
    Comptroller public unitrollerProxy;
    // USDC
    ERC20 public USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    CErc20Delegate public cUSDCDelegate;
    CErc20Delegator public cUSDC;

    // UNI
    ERC20 public UNI = ERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
    CErc20Delegate public cUNIDelegate;
    CErc20Delegator public cUNI;

    // user
    address public user1;
    address public user2;

    // flashloan
    FlashLoanAndLiquidate public flashLoanAndLiquidate;

    function setUp() public {
        uint256 forkId = vm.createFork(
            "https://eth-mainnet.g.alchemy.com/v2/Pl6OPgnY0_d3PT09U1iddzBXevWmiIKa",
            17465000
        );
        // select fork
        vm.selectFork(forkId);

        // set oracle
        priceOracle = new SimplePriceOracle(); // deploy oracle contract

        // set whitepaper
        whitePaper = new WhitePaperInterestRateModel(0, 0); // deploy interestRate contract

        // set comptroller
        unitroller = new Unitroller(); // deploy unitroller contract
        comptroller = new Comptroller(); // deploy comptroller contract
        unitrollerProxy = Comptroller(address(unitroller));
        unitroller._setPendingImplementation(address(comptroller)); // set Implementation contract
        comptroller._become(unitroller);
        unitrollerProxy._setPriceOracle(priceOracle); // set oracle

        // set USDC
        cUSDCDelegate = new CErc20Delegate(); // deploy CErc20Delegate contract
        bytes memory data = new bytes(0x00);
        cUSDC = new CErc20Delegator(
            address(USDC),
            ComptrollerInterface(address(unitroller)),
            InterestRateModel(address(whitePaper)),
            1e18,
            "Compound USDC",
            "cUSDC",
            18,
            payable(msg.sender),
            address(cUSDCDelegate),
            data
        ); // deploy cUSDC
        unitrollerProxy._supportMarket(CToken(address(cUSDC)));

        // set cUNI
        cUNIDelegate = new CErc20Delegate(); // deploy CErc20Delegate contract
        cUNI = new CErc20Delegator(
            address(UNI),
            ComptrollerInterface(address(unitroller)),
            InterestRateModel(address(whitePaper)),
            1e18,
            "Compound Uniswap",
            "cUNI",
            18,
            payable(msg.sender),
            address(cUNIDelegate),
            data
        ); // deploy cUNI
        unitrollerProxy._supportMarket(CToken(address(cUNI)));

        // set USDC, UNI oracle price
        priceOracle.setUnderlyingPrice(
            CToken(address(cUSDC)),
            1 * 10 ** (18 + (18 - 6))
        ); // USDC decimals = 6, cUSDC decimals = 18.
        priceOracle.setUnderlyingPrice(CToken(address(cUNI)), 5e18);

        // set close factor
        unitrollerProxy._setCloseFactor(0.5 * 1e18);

        // set UNI collateral factor
        unitrollerProxy._setCollateralFactor(CToken(address(cUNI)), 0.5 * 1e18);

        // set liquidation incentive
        unitrollerProxy._setLiquidationIncentive(1.08 * 1e18);

        // set users
        user1 = makeAddr("User1");
        user2 = makeAddr("User2");

        // give user1 UNI
        uint256 initialBalanceUNI = 1000 * 10 ** UNI.decimals();
        deal(address(UNI), user1, initialBalanceUNI);

        // flashloan
        flashLoanAndLiquidate = new FlashLoanAndLiquidate();
    }

    function test_flashloan_and_compound_liquidate() public {
        // background setting
        // ==========================================================
        // set mint/borrow amount
        uint mintAmount = 1000 * 10 ** UNI.decimals();
        uint borrowAmount = 2500 * 10 ** USDC.decimals();
        deal(address(USDC), address(cUSDC), borrowAmount);

        // prank user1
        vm.startPrank(user1);

        // check user1 have 1000 UNI
        require(
            ERC20(UNI).balanceOf(user1) == mintAmount,
            "invalid UNI balance"
        );

        // user1 approve cUNI contract 1000 UNI
        ERC20(UNI).approve(address(cUNI), mintAmount);

        // 1000 UNI mint to 1000 cUNI
        cUNI.mint(mintAmount);

        // user1 cUNI balance now = 1000
        assertEq(CErc20Delegator(cUNI).balanceOf(user1), mintAmount);

        // user1 cUNI now as an asset in liquidate markets
        address[] memory addr = new address[](1);
        addr[0] = address(cUNI);
        unitrollerProxy.enterMarkets(addr);

        // check user1 have 0 USDC
        require(ERC20(USDC).balanceOf(user1) == 0, "invalid USDC balance");

        // user1 borrow 2500 usdc
        cUSDC.borrow(borrowAmount);

        // user1 USDC balance now = 2500
        assertEq(ERC20(USDC).balanceOf(user1), borrowAmount);
        vm.stopPrank();
        // ==========================================================
        // background setting

        // change UNI oracle
        priceOracle.setUnderlyingPrice(CToken(address(cUNI)), 4e18);

        // prank user2
        vm.startPrank(user2);
        // check user1 has excess collateral
        (, , uint shortfall) = unitrollerProxy.getAccountLiquidity(user1);
        require(shortfall > 0, "account has not excess collateral");

        // User2 liquidate user1's position
        // set data to do flashloan
        bytes memory data = abi.encode(address(user1), cUSDC, cUNI, UNI);
        // the flashloan amount = borrow * collateral factor
        flashLoanAndLiquidate.execute(address(USDC), borrowAmount / 2, data);

        vm.stopPrank();

        // check user2 now have > 63 USDC (63.638693)
        assertGt(
            USDC.balanceOf(address(flashLoanAndLiquidate)),
            63 * 10 ** USDC.decimals()
        );
    }
}
