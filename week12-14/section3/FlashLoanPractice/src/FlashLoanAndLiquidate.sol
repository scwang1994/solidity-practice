pragma solidity 0.8.19;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import "compound-protocol/contracts/CErc20.sol";
import {IFlashLoanSimpleReceiver, IPoolAddressesProvider, IPool} from "aave-v3-core/contracts/flashloan/interfaces/IFlashLoanSimpleReceiver.sol";
// uniswap-v3
import "v3-periphery/interfaces/ISwapRouter.sol";

// TODO: Inherit IFlashLoanSimpleReceiver
contract FlashLoanAndLiquidate {
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant POOL_ADDRESSES_PROVIDER =
        0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
    address constant SWAP_Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    function execute(
        address assets,
        uint amount,
        bytes calldata data
    ) external {
        IPool(ADDRESSES_PROVIDER().getPool()).flashLoanSimple(
            address(this),
            assets,
            amount,
            data,
            0
        );
    }

    function executeOperation(
        address asset, // flashloan USDC
        uint256 amount, // amount = liquidateBorrow amount
        uint256 premium, // fee
        address initiator, // address(this)
        bytes calldata params
    ) external returns (bool) {
        require(initiator == address(this), "not this contract");

        // decode data, to do what I want to do (in this case, liquidate)
        (
            address borrower, // man to be liquidated
            address liquidatedCToken, // cUSDC
            address rewardCToken, // cUNI
            address rewardToken // UNI
        ) = abi.decode(params, (address, address, address, address));

        // approve CUSDC to use USDC
        IERC20(USDC).approve(address(liquidatedCToken), amount);

        // liquidates user1(borrower) collateral
        // get cUNI as reward
        CErc20(liquidatedCToken).liquidateBorrow(
            borrower,
            amount,
            CErc20(rewardCToken)
        );

        // redeem CUNI to UNI
        CErc20(rewardCToken).redeem(CErc20(rewardCToken).balanceOf(initiator));

        // approve router to swap UNI to USDC
        IERC20(rewardToken).approve(
            SWAP_Router,
            IERC20(rewardToken).balanceOf(initiator)
        );

        // swap UNI to USDC
        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: rewardToken,
                tokenOut: asset,
                fee: 3000, // 0.3%
                recipient: initiator,
                deadline: block.timestamp,
                amountIn: IERC20(rewardToken).balanceOf(initiator),
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });
        // uint256 amountOut =
        ISwapRouter(SWAP_Router).exactInputSingle(swapParams);

        // approve aave transfer amount and premium back (repay to flashloan)
        IERC20(asset).approve(msg.sender, amount + premium);
        return true;
    }

    function ADDRESSES_PROVIDER() public view returns (IPoolAddressesProvider) {
        return IPoolAddressesProvider(POOL_ADDRESSES_PROVIDER);
    }

    function POOL() public view returns (IPool) {
        return IPool(ADDRESSES_PROVIDER().getPool());
    }
}
