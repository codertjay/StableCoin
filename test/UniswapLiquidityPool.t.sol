// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {UniswapLiquidityPool} from "../src/UniswapLiquidityPool.sol";
import {StableCoin} from  "../src/StableCoin.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract UniswapLiquidityPoolTest is Test {
    UniswapLiquidityPool uniswapLiquidityPool;

    address private constant EXTERNAL_TOKEN = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;
    StableCoin stableCoin;
    StableCoin stableCoin2;


    address user = address(456);
    address userB = address(456);

    function setUp() external {
        vm.startBroadcast(user);

        uint256 minWithdrawal = 1E18;
        uint256 initialSupply = 12900E18;

        stableCoin = new StableCoin(initialSupply, minWithdrawal);
        stableCoin2 = new StableCoin(initialSupply, minWithdrawal);

        // mint the token
        stableCoin.mint(user, 1000E18);
        stableCoin2.mint(user, 1000E18);

        uniswapLiquidityPool = new UniswapLiquidityPool();

        vm.stopBroadcast();
    }


    function testCreatePair() public {
        vm.startBroadcast(user);

        uniswapLiquidityPool.createPair(address(stableCoin), address(stableCoin2));
        address pairAddress = uniswapLiquidityPool.getPair(address(stableCoin), address(stableCoin2));

        vm.stopBroadcast();

        assertNotEq(pairAddress, address(0));
    }


    function testAddLiquidity() public {
        vm.startBroadcast(user);

        IERC20(address(stableCoin)).approve(address(uniswapLiquidityPool), 2e18);
        IERC20(address(stableCoin2)).approve(address(uniswapLiquidityPool), 2e18);

        uniswapLiquidityPool.addLiquidity(address(stableCoin), address(stableCoin2), 2e18, 2e18);
        vm.stopBroadcast();

    }


    function testRemoveLiquidity() public {
        vm.startBroadcast(user);

        uniswapLiquidityPool.createPair(address(stableCoin), address(stableCoin2));


        IERC20(address(stableCoin)).approve(address(uniswapLiquidityPool), 2e18);
        IERC20(address(stableCoin2)).approve(address(uniswapLiquidityPool), 2e18);

        (uint tokenAmountA, uint tokenAmountB) = uniswapLiquidityPool.addLiquidity(address(stableCoin), address(stableCoin2), 2e18, 2e18);

        console.log("This is adding the liquidity ");
        console.log(tokenAmountA);
        console.log(tokenAmountB);
        console.log("===========");

        (tokenAmountA, tokenAmountB) = uniswapLiquidityPool.removeLiquidity(address(stableCoin), address(stableCoin2));
        console.log("This is removing the liquidity ");
        console.log(tokenAmountA);
        console.log(tokenAmountB);

        console.log("Get the balance for both token in the pair");
        console.log(IERC20(address(stableCoin)).balanceOf(address(uniswapLiquidityPool.getPair(address(stableCoin), address(stableCoin2)))));
        console.log(IERC20(address(stableCoin2)).balanceOf(address(uniswapLiquidityPool.getPair(address(stableCoin), address(stableCoin2)))));

        uniswapLiquidityPool.withdrawAllERC20(address(stableCoin));
        uniswapLiquidityPool.withdrawAllERC20(address(stableCoin2));
        vm.stopBroadcast();
    }


    function testSwapTokens() public {
        vm.startBroadcast(user);

        uniswapLiquidityPool.createPair(address(stableCoin), address(stableCoin2));


        IERC20(address(stableCoin)).approve(address(uniswapLiquidityPool), 200e18);
        IERC20(address(stableCoin2)).approve(address(uniswapLiquidityPool), 200e18);

        (uint tokenAmountA, uint tokenAmountB) = uniswapLiquidityPool.addLiquidity(address(stableCoin), address(stableCoin2), 200e18, 200e18);

        console.log("This is adding the liquidity ");
        console.log(tokenAmountA);
        console.log(tokenAmountB);
        console.log("===========");

        // This is the swapping of the token part

        IERC20(address(stableCoin)).approve(address(uniswapLiquidityPool), 10e18);
        uniswapLiquidityPool.swapToken(address(stableCoin), address(stableCoin2), 10e18);
        vm.stopBroadcast();
    }

}