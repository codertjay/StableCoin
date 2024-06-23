// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "node_modules/@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from 'node_modules/@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

import {Ownable} from  "node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract UniswapLiquidityPool is Ownable {

    address private constant FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;
    address private constant ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address private constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    event Log(string message, uint val);

    constructor() Ownable(msg.sender) {
    }



    function createPair(address _tokenA, address _tokenB) external {
        IUniswapV2Factory(FACTORY).createPair(_tokenA, _tokenB);
    }


    function getPair(address _tokenA, address _tokenB) external returns (address){
        return IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
    }


    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB
    ) external onlyOwner {


        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        (uint amountA, uint amountB, uint liquidity) =
                                IUniswapV2Router02(ROUTER).addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                1,
                1,
                address(this),
                block.timestamp
            );

    }

    function removeLiquidity(address _tokenA, address _tokenB) external onlyOwner {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint liquidity = IERC20(pair).balanceOf(address(this));
        IERC20(pair).approve(ROUTER, liquidity);

        (uint amountA, uint amountB) =
                                IUniswapV2Router02(ROUTER).removeLiquidity(
                _tokenA,
                _tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );

    }


    function withdrawAllERC20(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }


}