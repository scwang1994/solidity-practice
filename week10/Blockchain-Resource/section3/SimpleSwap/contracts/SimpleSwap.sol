// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { ISimpleSwap } from "./interface/ISimpleSwap.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./libraries/Math.sol";
import "./libraries/SafeMath.sol";
import "./libraries/UQ112x112.sol";
import "./interface/IERC20.sol";

contract SimpleSwap is ISimpleSwap, ERC20 {
    using SafeMath for uint;
    using UQ112x112 for uint224;

    address public token0;
    address public token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;

    constructor(address tokenA, address tokenB) ERC20("SimpleSwap", "SimpleSwap") {
        require(isContract(tokenA), "SimpleSwap: TOKENA_IS_NOT_CONTRACT");
        require(isContract(tokenB), "SimpleSwap: TOKENB_IS_NOT_CONTRACT");
        require(tokenA != tokenB, "SimpleSwap: TOKENA_TOKENB_IDENTICAL_ADDRESS");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    // Implement core logic here
    /// @notice Swap tokenIn for tokenOut with amountIn
    /// @param tokenIn The address of the token to swap from
    /// @param tokenOut The address of the token to swap to
    /// @param amountIn The amount of tokenIn to swap
    /// @return amountOut The amount of tokenOut received
    function swap(address tokenIn, address tokenOut, uint256 amountIn) external override returns (uint256 amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "SimpleSwap: INVALID_TOKEN_IN");
        require(tokenOut == token0 || tokenOut == token1, "SimpleSwap: INVALID_TOKEN_OUT");
        require(tokenIn != tokenOut, "SimpleSwap: IDENTICAL_ADDRESS");
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        amountOut = (amountIn * reserve1) / (reserve0 + amountIn);

        if (amountOut > 0) IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn); // transferFrom token0
        if (amountOut > 0) IERC20(tokenOut).transfer(msg.sender, amountOut); // transfer token1

        uint balance0 = IERC20(tokenIn).balanceOf(address(this));
        uint balance1 = IERC20(tokenOut).balanceOf(address(this));

        _update(balance0, balance1);
        emit Swap(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @notice Add liquidity to the pool
    /// @param amountAIn The amount of tokenA to add
    /// @param amountBIn The amount of tokenB to add
    /// @return amountA The actually amount of tokenA added
    /// @return amountB The actually amount of tokenB added
    /// @return liquidity The amount of liquidity minted
    function addLiquidity(
        uint256 amountAIn,
        uint256 amountBIn
    ) external override returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        require(amountAIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");
        require(amountBIn > 0, "SimpleSwap: INSUFFICIENT_INPUT_AMOUNT");

        if (reserve0 == 0 && reserve1 == 0) {
            (amountA, amountB) = (amountAIn, amountBIn);
        } else {
            uint amountBOptimal = quote(amountAIn, reserve0, reserve1);
            if (amountBOptimal <= amountBIn) {
                (amountA, amountB) = (amountAIn, amountBOptimal);
            } else {
                uint amountAOptimal = quote(amountBIn, reserve1, reserve0);
                assert(amountAOptimal <= amountAIn);
                (amountA, amountB) = (amountAOptimal, amountBIn);
            }
        }

        IERC20(token0).transferFrom(msg.sender, address(this), amountA);
        IERC20(token1).transferFrom(msg.sender, address(this), amountB);
        // mint
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(reserve0);
        uint amount1 = balance1.sub(reserve1);

        uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1));
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / reserve0, amount1.mul(_totalSupply) / reserve1);
        }
        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(msg.sender, liquidity);
        _update(balance0, balance1);

        emit Transfer(address(0), msg.sender, liquidity);
        emit AddLiquidity(msg.sender, amount0, amount1, liquidity);
    }

    /// @notice Remove liquidity from the pool
    /// @param liquidity The amount of liquidity to remove
    /// @return amountA The amount of tokenA received
    /// @return amountB The amount of tokenB received
    function removeLiquidity(uint256 liquidity) external override returns (uint256 amountA, uint256 amountB) {
        require(liquidity > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY_BURNED");

        IERC20(address(this)).transferFrom(msg.sender, address(this), liquidity);
        //    burn
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amountA = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amountB = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amountA > 0 && amountB > 0, "INSUFFICIENT_LIQUIDITY_BURNED");
        _burn(address(this), liquidity);
        IERC20(token0).transfer(msg.sender, amountA);
        IERC20(token1).transfer(msg.sender, amountB);
        balance0 = IERC20(token0).balanceOf(address(this));
        balance1 = IERC20(token1).balanceOf(address(this));

        _update(balance0, balance1);

        emit Transfer(address(this), address(0), liquidity);
    }

    /// @notice Get the reserves of the pool
    /// @return reserveA The reserve of tokenA
    /// @return reserveB The reserve of tokenB
    function getReserves() external view override returns (uint256 reserveA, uint256 reserveB) {
        return (reserve0, reserve1);
    }

    /// @notice Get the address of tokenA
    /// @return tokenA The address of tokenA
    function getTokenA() external view override returns (address tokenA) {
        return token0;
    }

    /// @notice Get the address of tokenB
    /// @return tokenB The address of tokenB
    function getTokenB() external view override returns (address tokenB) {
        return token1;
    }

    /// @notice Check the address if a contract
    /// @param _addr The address to be check
    function isContract(address _addr) public view returns (bool) {
        return _addr.code.length > 0;
    }

    /// @notice update the reserve0 and reserve1 with balance0 and balance1
    /// @param balance0 The new balance of token0
    /// @param balance1 The new balance of token1
    function _update(uint balance0, uint balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    /// @notice get the actual amount of tokenB
    /// @param amountA The amount of tokenA received
    /// @param reserveA The reserve of tokenA
    /// @param reserveB The reserve of tokenB
    /// @return amountB The actual amount of tokenB
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        amountB = amountA.mul(reserveB) / reserveA;
    }
}
