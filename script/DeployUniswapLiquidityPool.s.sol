// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {UniswapLiquidityPool} from  "../src/UniswapLiquidityPool.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DeployUniswapLiquidityPool is Script {
    address private constant StableCoinAddress = 0x54AafdbFa2f52a8E5871E14EE2b863ff9C695F19;
    address private constant UniswapLiquidityPoolAddress = 0xdeaA322F2b12c8dF4634BCdE680FCA4F3F3F80Eb;
    address private constant ExternalToken = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address private  constant sender = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
    uint256 private constant TokenLiquidityAmount = 1e18;
    uint256 private constant  ExternalTokenLiquidityAmount = 1e6;


    StableCoin stableCoin;
    UniswapLiquidityPool uniswapLiquidityPool;


    function run() external returns (UniswapLiquidityPool) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        uniswapLiquidityPool = UniswapLiquidityPool(0xdeaA322F2b12c8dF4634BCdE680FCA4F3F3F80Eb);
        stableCoin = StableCoin(StableCoinAddress);

        removeLiquidity();

        vm.stopBroadcast();
        return uniswapLiquidityPool;
    }


    function createPair() public {
        // this is used to create pair
        uniswapLiquidityPool.createPair(StableCoinAddress, ExternalToken);
    }

    function getPair() public returns (address) {
        // this is used to get pair
        address pairAddress = uniswapLiquidityPool.getPair(StableCoinAddress, ExternalToken);
        return pairAddress;
    }


    function removeLiquidity() public {
        // this is to remove the liquidity
        uniswapLiquidityPool.removeLiquidity(StableCoinAddress, ExternalToken);
    }


    function addLiquidity() public {

        IERC20(StableCoinAddress).approve(address(uniswapLiquidityPool), TokenLiquidityAmount);
        IERC20(ExternalToken).approve(address(uniswapLiquidityPool), ExternalTokenLiquidityAmount);

        // this is used to add liquidity
        uniswapLiquidityPool.addLiquidity(StableCoinAddress, ExternalToken, TokenLiquidityAmount, ExternalTokenLiquidityAmount);
    }

}