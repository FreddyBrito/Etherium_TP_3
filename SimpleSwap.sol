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

        uint256 numerator = amountIn * reserveOut;
        uint256 denominator = reserveIn + amountIn;
        amountOut = numerator / denominator;
    }

    /*

    function addLiquidity(address tokenA, 
                          address tokenB, 
                          uint amountADesired, 
                          uint amountBDesired, 
                          uint amountAMin, 
                          uint amountBMin, 
                          address to, 
                          uint deadline) 
                          external returns (uint amountA, 
                                            uint amountB, 
                                            uint liquidity) {


        // Transferir tokens del usuario al contrato.
        // Calcular y asignar liquidez según reservas.
        // Emitir tokens de liquidez al usuario.

    }


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
