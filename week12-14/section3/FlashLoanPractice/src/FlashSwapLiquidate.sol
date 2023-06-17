pragma solidity 0.8.19;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {IUniswapV2Callee} from "v2-core/interfaces/IUniswapV2Callee.sol";
import {IUniswapV2Factory} from "v2-core/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "v2-core/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "v2-periphery/interfaces/IUniswapV2Router02.sol";
import {CErc20} from "compound-protocol/contracts/CErc20.sol";

contract FlashSwapLiquidate is IUniswapV2Callee {
    struct CallbackData {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        address borrower;
    }

    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 public DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    CErc20 public cUSDC = CErc20(0x39AA39c021dfbaE8faC545936693aC917d5E7563);
    CErc20 public cDAI = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    IUniswapV2Router02 public router =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public factory =
        IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external override {
        // TODO
        require(sender == address(this), "Sender must be this contract");
        require(
            amount0 > 0 || amount1 > 0,
            "amount0 or amount1 must be greater than 0"
        );

        // 4. decode callback data
        CallbackData memory callback = abi.decode(data, (CallbackData));
        // 5. call liquidate
        USDC.approve(address(cUSDC), callback.amountIn);
        cUSDC.liquidateBorrow(callback.borrower, callback.amountIn, cDAI);
        // 6. redeem
        cDAI.redeem(cDAI.balanceOf(address(this)));
        // 7. repay DAI to uniswap pool
        address pairAddress = factory.getPair(
            callback.tokenOut, // Dai
            callback.tokenIn // USDC
        );
        DAI.transfer(pairAddress, callback.amountOut);
    }

    function liquidate(address borrower, uint256 amountOut) external {
        // TODO
        require(amountOut > 0, "AmountOut must be greater than 0");
        // 1. get uniswap pool address
        address[] memory path = new address[](2);
        path[0] = address(DAI);
        path[1] = address(USDC);

        address pairAddress = factory.getPair(path[0], path[1]);
        // 2. calculate repay amount
        uint256 repayAmount = router.getAmountsIn(amountOut, path)[0];

        // 3. flash swap from uniswap pool
        CallbackData memory data;
        data.tokenIn = path[1]; // USDC
        data.tokenOut = path[0]; // DAI
        data.amountIn = amountOut; // USDC
        data.amountOut = repayAmount; // DAI
        data.borrower = borrower; // borrower

        IUniswapV2Pair(pairAddress).swap(
            0,
            amountOut,
            address(this),
            abi.encode(data)
        );
    }
}
