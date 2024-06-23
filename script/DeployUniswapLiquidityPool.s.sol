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
    address private constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    address private  constant sender = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

    StableCoin stableCoin;
    UniswapLiquidityPool uniswapLiquidityPool;


    function run() external returns (UniswapLiquidityPool) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        uniswapLiquidityPool = new  UniswapLiquidityPool();
        stableCoin = StableCoin(StableCoinAddress);


        uint256 usdtAmount = 2e6;
        uint256 stableCoinAmount = stableCoin.minWithdrawal() + 1;

        console.log("Adding liquidity by : ", msg.sender);

        // Ensure sufficient approval for USDT and StableCoin
        IERC20(USDT).transfer(address(uniswapLiquidityPool), usdtAmount);
        IERC20(StableCoinAddress).transfer(address(uniswapLiquidityPool), stableCoinAmount);
        stableCoin.mint(address(uniswapLiquidityPool), stableCoinAmount);


        addLiquidity();

        vm.stopBroadcast();
        return uniswapLiquidityPool;
    }


    function addLiquidity() public {
        // this is used to add liquidity
        uniswapLiquidityPool.addLiquidity(StableCoinAddress, USDT, 1e18, 1e6);
    }


    function createPair() public {
        // this is used to create pair
        uniswapLiquidityPool.createPair(StableCoinAddress, USDT);
    }


}