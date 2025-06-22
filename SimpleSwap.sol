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
