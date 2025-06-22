// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title SimpleSwap
 * @dev Smart contract that allows you to add and remove liquidity, 
 * exchange tokens, obtain prices and calculate amounts to receive
 * Allows exchanges between two ERC-20 tokens.
 */
contract SimpleSwap {

    /**
    * @dev Variable declaration,  
    * We make them public so that Solidity automatically creates a getter function for them.
    */

    // Variables for the pair tokens
    ERC20 public tokenA;
    ERC20 public tokenB;

    // Pool reservations
    uint256 public reserveA;
    uint256 public reserveB;

    // Variables for LP (Liquidity Pool) tokens
    uint256 public totalSupply; // Total LP tokens issued
    mapping(address => uint256) public balanceOf; // LP token balances per user

   

    /**
     * @dev When deploying the contract we set the token pair.
     * @param _tokenA Address of the first ERC-20 token. (FTK)
     * @param _tokenB Address of the second ERC-20 token. (BTK)
     */
    constructor(address _tokenA, address _tokenB) {
        tokenA = ERC20(_tokenA);
        tokenB = ERC20(_tokenB);
    }

    // Compare that two addresses are the same
    function isSameAddress(address a, address b) public pure returns (bool) {
    return a == b;
    }



    /**
     * @notice Returns the number of output tokens for a given input amount.
     * @dev This is a pure view function, it does not modify state.
     * @param amountIn The amount of the token being sent to the pool.
     * @param reserveIn The reservation of the input token.
     * @param reserveOut The reserve of the output token.
     * @return amountOut The amount of the token to be received.
     */
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256 amountOut) {
        require(amountIn > 0, "SimpleSwap: INSUFFICIENT_INOUT_AMOUNT");
        require(reserveIn > 0 && reserveOut > 0, "SimpleSwap: INSUFFICIENT_LIQUIDITY");

        uint256 amountInWithFee = amountIn * 997; // 0.3% Commission (1000 - 3)
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;
        amountOut = numerator / denominator;
    }


    /**
     * @notice Returns the instant price of tokenA in terms of tokenB.
     * @dev It is based on the proportion of reserves. It does not consider the impact of a trade.
     * @return The price of 1 tokenA in units of tokenB.
     */
    function getPrice(address _tokenA, address _tokenB) external view returns (uint256){
        require(reserveA > 0 && reserveB > 0, "SimpleSwap: NO_LIQUIDITY");
        
        // Get reserves of both tokens
        // Determine input and output reserves based on token addresses
        uint256 _reserveA = (_tokenA == address(tokenA)) ? reserveA : reserveB;
        uint256 _reserveB = (_tokenB == address(tokenB)) ? reserveB : reserveA;

        // Calculate and return the price
        // Multiply by 1e18 to handle decimals.
        return (_reserveB * 1e18) / _reserveA;
    }


    /**
     * @dev Update reservations with current contract balances.
     */
    function _updateLiquidity(uint256 balanceA, uint256 balanceB) private {
        reserveA = balanceA;
        reserveB = balanceB;
    }

    
    /**
    * @notice Adds liquidity to the pair.
    * @dev The user must have approved the contract to spend their tokens first.
    * @param _tokenA TokenA contract address to add.
    * @param _tokenB TokenB contract address to add.
    * @param amountADesired Desired amount of tokenA to add.
    * @param amountBDesired Desired amount of tokenB to add.
    * @param amountAMin Minimum amount of tokenA to add.
    * @param amountBMin Minimum amount of tokenB to add.
    * @param to Recipient of the liquidity tokens.
    * @param deadline Time after which the transaction is invalid.
    * @return amountA Effective amount of tokenA added.
    * @return amountB Effective amount of tokenB added.
    * @return liquidity Amount of liquidity tokens minted.
    */
    function addLiquidity(address _tokenA, address _tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity) {

        require(deadline >= block.timestamp, "SimpleSwap: DEADLINE_EXPIRED");
        // Get reserves of both tokens
        // Determine input and output reserves based on token addresses
        uint256 _reserveA = (_tokenA == address(tokenA)) ? reserveA : reserveB;
        uint256 _reserveB = (_tokenB == address(tokenB)) ? reserveB : reserveA;

        uint256 _amountADesired = amountADesired;
        uint256 _amountBDesired = amountBDesired;

        // I assign 0 to these amounts because I will not consider them for any calculations.
        amountAMin = 0;
        amountBMin = 0;

        // If there is pre-existing liquidity, 
        // calculate the optimal amount of tokenB 
        // for a given amount of tokenA
        if (_reserveA > 0 || _reserveB > 0) {
            uint256 amountBOptimal = (_amountADesired * _reserveB) / _reserveA;
           
            if (amountBOptimal <= _amountBDesired) {
                // We use all the amountADesired and the optimal amount of amountB
                amountA = _amountADesired;
                amountB = amountBOptimal;

            } else {
                // We don't have enough amountBDesired, so we calculate the optimal amountA
                uint256 amountAOptimal = (_amountBDesired * _reserveA) / _reserveB;
                amountA = amountAOptimal;
                amountB = _amountBDesired;
            }

            // Collect user tokens
            tokenA.transferFrom(msg.sender, address(this), amountA);
            tokenB.transferFrom(msg.sender, address(this), amountB);

        } else {
            // It is the first liquidity provider, it sets the price
            // Collect user tokens
            tokenA.transferFrom(msg.sender, address(this), _amountADesired);
            tokenB.transferFrom(msg.sender, address(this), _amountBDesired);
        }

        uint256 balanceA = tokenA.balanceOf(address(this));
        uint256 balanceB = tokenB.balanceOf(address(this));
        uint256 amountAAdded = balanceA - _reserveA;
        uint256 amountBAdded = balanceB - _reserveB;

        // Mint LP tokens
        if (totalSupply == 0) {
            // First, the amount of shares is the square root of the product of the amounts
            liquidity = sqrt(amountAAdded * amountBAdded);
        } else {
            // Proportional to existing liquidity
            liquidity = ((amountAAdded * totalSupply) / _reserveA);
        }

        require(liquidity > 0, "SimpleSwap: MINT_FAILED");

        totalSupply += liquidity;
        balanceOf[msg.sender] += liquidity;

        _updateLiquidity(balanceA, balanceB);
        amountA = balanceA;
        amountB = balanceB;

        return (amountA, amountB, liquidity);
    }

    // Auxiliary function to calculate the square root, necessary for the first minting.
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


    /**
     * @notice Exchanges an exact amount of input tokens for output tokens.
     * @param amountIn Amount of input token.
     * @param amountOutMin Minimum acceptable output token amount (slippage protection).
     * @param path Input token address and Output token address.
     * @param to Address that will receive the output tokens.
     * @param deadline Deadline for the transaction to be valid (front-running protection).
     * @return amounts Array with input and output quantities.
     */
    function swapExactTokensForTokens(uint amountIn, 
                                      uint amountOutMin, 
                                      address[] calldata path, 
                                      address to, 
                                      uint deadline) 
                                      external returns (uint[] memory amounts){

        require(deadline >= block.timestamp, "SimpleSwap: DEADLINE_EXPIRED");

        address tokenIn = path[0];
        address tokenOut = path[1];

        uint256 _reserveA = reserveA;
        uint256 _reserveB = reserveB;

        // Determine input and output reserves based on token addresses
        (uint256 reserveIn, uint256 reserveOut) = (tokenIn == address(tokenA)) ? (_reserveA, _reserveB) : (_reserveB, _reserveA);

        uint256 _amountIn = amountIn;
        amounts[0] = _amountIn;
        // Calculate how much output token should be received
        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "SimpleSwap: INSUFFICIENT_OUTPUT_AMOUNT");
        amounts[1] = amountOut;

        // Make transfers
        // 1. Collect the user's input token
        ERC20(tokenIn).transferFrom(msg.sender, address(this), _amountIn);
        
        // 2. Send the output token to the recipient
        ERC20(tokenOut).transfer(to, amountOut);

        // 3. Update reservations
        uint256 balance0 = tokenA.balanceOf(address(this));
        uint256 balance1 = tokenB.balanceOf(address(this));
        _updateLiquidity(balance0, balance1);

        return amounts;
    }






    /*
    function removeLiquidity(address tokenA, 
                             address tokenB, 
                             uint liquidity, 
                             uint amountAMin, 
                             uint amountBMin, 
                             address to, 
                             uint deadline) 
                             external returns (uint amountA, 
                                               uint amountB){

        // Quemar tokens de liquidez del usuario.
        // Calcular y retornar tokens A y B.

    }


    function swapExactTokensForTokens(uint amountIn, 
                                      uint amountOutMin, 
                                      address[] calldata path, 
                                      address to, 
                                      uint deadline) 
                                      external returns (uint[] memory amounts){
        
        // Transferir token de entrada del usuario al contrato.
        // Calcular intercambio según reservas.
        // Transferir token de salida al usuario.

    }


    function getPrice(address tokenA, address tokenB) external view returns (uint price){
        
        // Obtener reservas de ambos tokens.
        // Calcular y retornar el precio.

    }


    function getAmountOut(uint amountIn, 
                          uint reserveIn, 
                          uint reserveOut) 
                          external pure returns (uint amountOut){
        
        // Calcular y retornar cantidad a recibir.

    }

    */
}
