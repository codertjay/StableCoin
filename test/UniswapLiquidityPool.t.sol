// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {UniswapLiquidityPool} from "../src/UniswapLiquidityPool.sol";
import {StableCoin} from  "../src/StableCoin.sol";


contract UniswapLiquidityPoolTest is Test {
    UniswapLiquidityPool uniswapLiquidityPool;

    address private constant USDT = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    StableCoin stableCoin;


    address user = address(456);
    address userB = address(456);

    function setUp() external {
        vm.startBroadcast(user);

        uint256 minWithdrawal = 1E18;
        uint256 initialSupply = 12900E18;

        stableCoin = new StableCoin(initialSupply, minWithdrawal);
        uniswapLiquidityPool = new UniswapLiquidityPool();

        vm.stopBroadcast();
    }


    function testCreatePair() public {

        uniswapLiquidityPool.createPair(address(stableCoin), USDT);
        address pairAddress = uniswapLiquidityPool.getPair(address(stableCoin), USDT);

        assertNotEq(pairAddress, address(0));
    }


    function testAddLiquidity() public {
        uniswapLiquidityPool.addLiquidity(address(stableCoin), USDT, 1e18, 1e18);
        uniswapLiquidityPool.removeLiquidity(address(stableCoin), USDT);
    }





}