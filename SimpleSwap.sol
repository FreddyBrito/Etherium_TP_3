// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SimpleSwap (Final Corrected Version)
 * @author Freddy Brito (Inspired by Uniswap V2)
 * @dev A highly gas-optimized AMM for swapping two ERC20 tokens.
 * This version focuses on minimizing state reads/writes and external calls.
 */
contract SimpleSwap is ERC20, ReentrancyGuard {

    // --- State Variables ---

    ERC20 public immutable tokenA;
    ERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;


    // --- Events ---
    event AddLiquidity(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event RemoveLiquidity(address indexed provider, uint256 amountA, uint256 amountB, uint256 liquidity);
    event Swap(address indexed sender, address indexed to, uint256 amountIn, uint256 amountOut, address tokenIn, address tokenOut);
    event Sync(uint256 reserveA, uint256 reserveB);

    // --- Modifiers ---

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "EXPIRED");
        _;
    }

    // --- Constructor ---

    constructor(address _tokenA, address _tokenB) ERC20("SimpleSwap Liquidity", "SSL") {
        require(_tokenA != address(0) && _tokenB != address(0), "ZERO_ADDRESS");
        require(_tokenA != _tokenB, "IDENTICAL_ADDRESSES");
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
    }

    // --- Reading Functions (View/Pure) ---

    /**
     * @notice Calculates the amount of output tokens for a given input amount, including fees.
     * @dev This is the standard Uniswap V2 formula for getAmountOut.
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) private pure returns (uint256 amountOut) {
        require(amountIn > 0, "INSUFFICIENT_INPUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "INSUFFICIENT_LIQUIDITY");

        // The ratio of reserves is based on the ratio of input amounts and output amounts.
        amountOut = (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    function getAmountByTokenToChange(address token, uint256 amountToChange) public view returns (uint256 amountToPay) {
        (uint256 reserveIn, uint256 reserveOut) = (token == address(tokenA)) ? (reserveA, reserveB) : (reserveB, reserveA);
        amountToPay = getAmountOut(amountToChange, reserveIn, reserveOut);
    }

    /**
     * @notice Returns the reserves of the pool.
     */
    function getReserves() public view returns (uint256 _reserveA, uint256 _reserveB) {
        return (reserveA, reserveB);
    }

    // --- Core Logic Functions ---

    /**
     * @dev Internal function to update reserves and emit a Sync event.
     * This is the most gas-efficient way to update state.
     */
    function _update(uint256 _reserveA, uint256 _reserveB) private {
        reserveA = _reserveA;
        reserveB = _reserveB;
        emit Sync(_reserveA, _reserveB);
    }

    /**
     * @notice Adds liquidity to the pool.
     */
    function addLiquidity(uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external nonReentrant ensure(deadline) returns (uint256 amountA, uint256 amountB, uint256 liquidity) {
        (uint256 _reserveA, uint256 _reserveB) = (reserveA, reserveB); // Gas optimization: read to memory once
        
        if (_reserveA > 0 || _reserveB > 0) {
            uint amountBOptimal = (amountADesired * _reserveB) / _reserveA;
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "INSUFFICIENT_B_AMOUNT");
                amountA = amountADesired;
                amountB = amountBOptimal;
            } else {
                uint amountAOptimal = (amountBDesired * _reserveA) / _reserveB;
                require(amountAOptimal >= amountAMin, "INSUFFICIENT_A_AMOUNT");
                amountA = amountAOptimal;
                amountB = amountBDesired;
            }
        } else {
            amountA = amountADesired;
            amountB = amountBDesired;
        }

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = sqrt(amountA * amountB);
        } else {
            liquidity = Math.min((amountA * _totalSupply) / _reserveA, (amountB * _totalSupply) / _reserveB);
        }

        require(liquidity > 0, "INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        // Gas Optimization: Update reserves arithmetically instead of calling balanceOf()
        _update(_reserveA + amountA, _reserveB + amountB);
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /**
     * @notice Removes liquidity from the pool.
     */
    function removeLiquidity(uint liquidity, uint amountAMin, uint amountBMin, address to, uint deadline) external nonReentrant ensure(deadline) returns (uint amountA, uint amountB) {
        require(balanceOf(msg.sender) >= liquidity, "INSUFFICIENT_LIQUIDITY");
        
        (uint256 _reserveA, uint256 _reserveB) = (reserveA, reserveB); // Gas optimization
        uint256 _totalSupply = totalSupply();

        amountA = (liquidity * _reserveA) / _totalSupply;
        amountB = (liquidity * _reserveB) / _totalSupply;
        
        require(amountA >= amountAMin, "INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "INSUFFICIENT_B_AMOUNT");

        _burn(msg.sender, liquidity);
        tokenA.transfer(to, amountA);
        tokenB.transfer(to, amountB);

        // Gas Optimization: Update reserves arithmetically
        _update(_reserveA - amountA, _reserveB - amountB);
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    /**
     * @notice Swaps an exact amount of input tokens for as many output tokens as possible.
     */
    function swapExactTokensForTokens(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external nonReentrant ensure(deadline) {
        require(path.length == 2, "INVALID_PATH");
        address tokenInAddress = path[0];
        address tokenOutAddress = path[1];
        require((tokenInAddress == address(tokenA) && tokenOutAddress == address(tokenB)) || (tokenInAddress == address(tokenB) && tokenOutAddress == address(tokenA)), "INVALID_TOKEN_PAIR");

        (uint256 _reserveA, uint256 _reserveB) = (reserveA, reserveB); // Gas optimization
        (uint256 reserveIn, uint256 reserveOut) = (tokenInAddress == address(tokenA)) ? (_reserveA, _reserveB) : (_reserveB, _reserveA);
  
        uint256 _amountIn = amountIn;

        ERC20(tokenInAddress).transferFrom(msg.sender, address(this), _amountIn);
        uint amountOut = getAmountOut(_amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "INSUFFICIENT_OUTPUT_AMOUNT");
        ERC20(tokenOutAddress).transfer(to, amountOut);

        // Gas Optimization: Update reserves arithmetically
        if (tokenInAddress == address(tokenA)) {
            _update(_reserveA + _amountIn, _reserveB - amountOut);
        } else {
            _update(_reserveA - amountOut, _reserveB + _amountIn);
        }
        
        emit Swap(msg.sender, to, _amountIn, amountOut, tokenInAddress, tokenOutAddress);
    }

    // --- Auxiliary Functions ---

    function sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

/**
 * @title Math
 * @author Uniswap Library
 * @dev A library for basic math operations.
 */
library Math {
    function min(uint x, uint y) internal pure returns (uint) {
        return x <= y ? x : y;
    }
}