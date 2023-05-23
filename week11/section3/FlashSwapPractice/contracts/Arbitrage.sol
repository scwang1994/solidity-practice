// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IUniswapV2Pair } from "v2-core/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Callee } from "v2-core/interfaces/IUniswapV2Callee.sol";

// This is a pracitce contract for flash swap arbitrage
contract Arbitrage is IUniswapV2Callee, Ownable {
    struct CallbackData {
        address borrowPool;
        address targetSwapPool;
        address borrowToken;
        address debtToken;
        uint256 borrowAmount;
        uint256 debtAmount;
        uint256 debtAmountOut;
    }

    //
    // EXTERNAL NON-VIEW ONLY OWNER
    //

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{ value: address(this).balance }("");
        require(success, "Withdraw failed");
    }

    function withdrawTokens(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(msg.sender, amount), "Withdraw failed");
    }

    //
    // EXTERNAL NON-VIEW
    //

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external override {
        require(sender == address(this), "Sender must be this contract");
        require(amount0 > 0 || amount1 > 0, "amount0 or amount1 must be greater than 0");

        // 3. decode callback data
        CallbackData memory callback = abi.decode(data, (CallbackData));
        // 4. swap WETH to USDC
        IERC20(callback.borrowToken).transfer(callback.targetSwapPool, callback.borrowAmount); // send weth to higher pool to swap
        IUniswapV2Pair(callback.targetSwapPool).swap(0, callback.debtAmountOut, address(this), ""); // swap usdc
        // 5. repay USDC to lower price pool
        IERC20(callback.debtToken).transfer(callback.borrowPool, callback.debtAmount);
    }

    // Method 1 is
    //  - borrow WETH from lower price pool
    //  - swap WETH for USDC in higher price pool
    //  - repay USDC to lower pool
    // Method 2 is
    //  - borrow USDC from higher price pool
    //  - swap USDC for WETH in lower pool
    //  - repay WETH to higher pool
    // for testing convenient, we implement the method 1 here
    function arbitrage(address priceLowerPool, address priceHigherPool, uint256 borrowETH) external {
        // 1. finish callbackData
        CallbackData memory callback;
        callback.borrowPool = priceLowerPool;
        callback.targetSwapPool = priceHigherPool;
        callback.borrowToken = IUniswapV2Pair(priceLowerPool).token0(); // weth
        callback.debtToken = IUniswapV2Pair(priceLowerPool).token1(); // usdc
        callback.borrowAmount = borrowETH; // weth

        (uint reserve0, uint reserve1, ) = IUniswapV2Pair(priceLowerPool).getReserves(); // get reserves of lower pool
        (uint reserveA, uint reserveB, ) = IUniswapV2Pair(priceHigherPool).getReserves(); // get reserves of higher pool
        callback.debtAmount = _getAmountIn(borrowETH, reserve1, reserve0); // get usdc that repay to lower pool
        callback.debtAmountOut = _getAmountOut(borrowETH, reserveA, reserveB); // get usdc that swap at higher pool
        // 2. flash swap (borrow WETH from lower price pool)
        // Uncomment next line when you do the homework
        IUniswapV2Pair(priceLowerPool).swap(borrowETH, 0, address(this), abi.encode(callback));
    }

    //
    // INTERNAL PURE
    //

    // copy from UniswapV2Library
    function _getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        amountIn = numerator / denominator + 1;
    }

    // copy from UniswapV2Library
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
