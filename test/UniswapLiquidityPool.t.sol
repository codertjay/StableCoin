// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {UniswapLiquidityPool} from "../src/UniswapLiquidityPool.sol";


contract UniswapLiquidityPoolTest is Test {
    UniswapLiquidityPool uniswapLiquidityPool;
    address user = address(456);
    address userB = address(456);

    function setUp() external {

        vm.startBroadcast(user);
        uniswapLiquidityPool = new UniswapLiquidityPool();
        vm.stopBroadcast();
    }


    function testCreatePair() public {
        address tokenA = address(123);
        address tokenB = address(456);
        uniswapLiquidityPool.createPair(tokenA, tokenB);
        assertNotEq(uniswapLiquidityPool.getPair(tokenA, tokenB), address(0));
    }



}