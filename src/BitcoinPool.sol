// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "node_modules/@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Router02} from 'node_modules/@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';

import {Ownable} from  "node_modules/@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Metadata} from  "node_modules/@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {console} from "forge-std/Test.sol";


contract BitcoinPool is Ownable {

    ////////////////////////////////////////////////////////////////////////
    //        Private
    ////////////////////////////////////////////////////////////////////////
    address private immutable FACTORY;
    address private immutable ROUTER;

    ////////////////////////////////////////////////////////////////////////
    //        EVENTS
    ////////////////////////////////////////////////////////////////////////
    event Log(string message, uint val);

    constructor(address _factory, address _router) Ownable(msg.sender) {
        FACTORY = _factory;
        ROUTER = _router;
    }

    ////////////////////////////////////////////////////////////////////////
    //        EXTERNAL
    ////////////////////////////////////////////////////////////////////////
    function createPair(address _tokenA, address _tokenB) external onlyOwner {
        IUniswapV2Factory(FACTORY).createPair(_tokenA, _tokenB);
    }


    function getPair(address _tokenA, address _tokenB) external view onlyOwner returns (address){
        return IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
    }


    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB
    ) external onlyOwner returns (uint, uint)  {

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        IERC20(_tokenA).approve(ROUTER, _amountA);
        IERC20(_tokenB).approve(ROUTER, _amountB);

        (uint amountA, uint amountB,) =
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

        return (amountA, amountB);
    }

    function removeLiquidity(address _tokenA, address _tokenB) external onlyOwner returns (uint, uint) {
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        uint liquidity = IERC20(pair).balanceOf(address(this));

        bool isApproved = IERC20(pair).approve(ROUTER, liquidity);
        require(isApproved, "Approval failed");

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

        return (amountA, amountB);
    }


    function withdrawAllERC20(address _token) external onlyOwner {
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }


    function swapToken(address _tokenA, address _tokenB, uint256 _tokenAmount) public onlyOwner {


        IERC20(_tokenA).transferFrom(msg.sender, address(this), _tokenAmount);
        IERC20(_tokenA).approve(ROUTER, _tokenAmount);

        address[] memory path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;

        // Get the amounts out (price) for the tokens
        // uint[] memory amountsOut = IUniswapV2Router02(ROUTER).getAmountsOut(_tokenAmount, path);


        IUniswapV2Router02(ROUTER).swapExactTokensForTokens(
            _tokenAmount,
            0, // minimum amount out
            path,
            address(this),
            block.timestamp
        );
    }


    function maintainPeg(address _tokenA, address _tokenB) external onlyOwner {
        uint256 tolerance = 10; // Adjust as needed for your use case

        // Fetch decimals of each token
        uint8 decimalsA = IERC20Metadata(_tokenA).decimals();
        uint8 decimalsB = IERC20Metadata(_tokenB).decimals();

        for (uint256 i = 0; i < 10; i++) {
            // Check the balances of tokenA and tokenB in the pool
            address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);
            uint balanceA = IERC20(_tokenA).balanceOf(pair);
            uint balanceB = IERC20(_tokenB).balanceOf(pair);

            // Adjust balances to a common base (e.g., 18 decimals)
            uint adjustedBalanceA = balanceA * (10 ** (18 - decimalsA));
            uint adjustedBalanceB = balanceB * (10 ** (18 - decimalsB));


            if (adjustedBalanceA > adjustedBalanceB) {
                uint excess = (adjustedBalanceA - adjustedBalanceB) / 2;

                // Adjust excess back to the original token's decimal base
                excess = excess / (10 ** (18 - decimalsB));

                if (excess < tolerance) {
                    break;
                }

                address[] memory path = new address[](2);
                path[0] = _tokenB;
                path[1] = _tokenA;
                uint[] memory  amountOut = IUniswapV2Router02(ROUTER).getAmountsOut(excess, path);

                if (amountOut[1] < tolerance) {
                    break;
                }


                swapToken(_tokenB, _tokenA, excess);
            } else if (adjustedBalanceB > adjustedBalanceA) {
                uint excess = (adjustedBalanceB - adjustedBalanceA) / 2;

                // Adjust excess back to the original token's decimal base
                excess = excess / (10 ** (18 - decimalsA));

                if (excess < tolerance) {
                    break;
                }

                address[] memory path = new address[](2);
                path[0] = _tokenA;
                path[1] = _tokenB;
                uint[] memory amountOut = IUniswapV2Router02(ROUTER).getAmountsOut(excess, path);

                if (amountOut[1] < tolerance) {
                    break;
                }

                swapToken(_tokenA, _tokenB, excess);
            } else {
                break;
            }
        }

    }

}