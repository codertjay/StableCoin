// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import {TetherUSDTPool} from "../src/TetherUSDTPool.sol";
import {Bitcoin} from  "../src/Bitcoin.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/console.sol";


contract TetherUSDTPoolTest is Test {
    TetherUSDTPool tetherUSDTPool;

    address private constant ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address private constant FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;

    Bitcoin bitcoin;
    Bitcoin bitcoin2;


    address user = address(456);
    address userB = address(456);

    function setUp() external {
        vm.startBroadcast(user);

        uint256 minWithdrawal = 1E18;
        uint256 initialSupply = 12900E18;

        bitcoin = new Bitcoin(initialSupply, minWithdrawal, "DamnValuableToken", "DVT");
        bitcoin2 = new Bitcoin(initialSupply, minWithdrawal, "DamnValuableToken2", "DVT2");

        // mint the token
        bitcoin.mint(user, 1000E18);
        bitcoin2.mint(user, 1000E18);

        tetherUSDTPool = new TetherUSDTPool(FACTORY, ROUTER);

        vm.stopBroadcast();
    }


    function testCreatePair() public {
        vm.startBroadcast(user);

        tetherUSDTPool.createPair(address(bitcoin), address(bitcoin2));
        address pairAddress = tetherUSDTPool.getPair(address(bitcoin), address(bitcoin2));

        vm.stopBroadcast();

        assertNotEq(pairAddress, address(0));
    }


    function testAddLiquidity() public {
        vm.startBroadcast(user);

        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 10e18);
        IERC20(address(bitcoin2)).approve(address(tetherUSDTPool), 10e18);

        tetherUSDTPool.addLiquidity(address(bitcoin), address(bitcoin2), 10e18, 10e18);
        vm.stopBroadcast();

    }


    function testMakeSwapsPegToken() public {
        vm.startBroadcast(user);

        tetherUSDTPool.createPair(address(bitcoin), address(bitcoin2));

        address pairAddress = tetherUSDTPool.getPair(address(bitcoin), address(bitcoin2));

        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 10e18);
        IERC20(address(bitcoin2)).approve(address(tetherUSDTPool), 10e18);

        tetherUSDTPool.addLiquidity(address(bitcoin), address(bitcoin2), 10e18, 10e18);

        bitcoin.setMinWithdrawal(0);
        bitcoin2.setMinWithdrawal(0);


        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), type(uint256).max);
        IERC20(address(bitcoin2)).approve(address(tetherUSDTPool), type(uint256).max);

        tetherUSDTPool.swapToken(address(bitcoin), address(bitcoin2), 1e18);

        // Perform swaps to maintain the peg
        tetherUSDTPool.maintainPeg(address(bitcoin), address(bitcoin2));

        console.log("This is the balance of the token after the swap", IERC20(address(bitcoin)).balanceOf(pairAddress));
        console.log("This is the balance of the token after the swap", IERC20(address(bitcoin2)).balanceOf(pairAddress));

        vm.stopBroadcast();
    }


    function testRemoveLiquidity() public {
        vm.startBroadcast(user);

        tetherUSDTPool.createPair(address(bitcoin), address(bitcoin2));


        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 2e18);
        IERC20(address(bitcoin2)).approve(address(tetherUSDTPool), 2e18);

        (uint tokenAmountA, uint tokenAmountB) = tetherUSDTPool.addLiquidity(address(bitcoin), address(bitcoin2), 2e18, 2e18);

        console.log("This is adding the liquidity ");
        console.log(tokenAmountA);
        console.log(tokenAmountB);
        console.log("===========");

        (tokenAmountA, tokenAmountB) = tetherUSDTPool.removeLiquidity(address(bitcoin), address(bitcoin2));
        console.log("This is removing the liquidity ");
        console.log(tokenAmountA);
        console.log(tokenAmountB);

        console.log("Get the balance for both token in the pair");
        console.log(IERC20(address(bitcoin)).balanceOf(address(tetherUSDTPool.getPair(address(bitcoin), address(bitcoin2)))));
        console.log(IERC20(address(bitcoin2)).balanceOf(address(tetherUSDTPool.getPair(address(bitcoin), address(bitcoin2)))));

        tetherUSDTPool.withdrawAllERC20(address(bitcoin));
        tetherUSDTPool.withdrawAllERC20(address(bitcoin2));
        vm.stopBroadcast();
    }


    function testSwapTokens() public {
        vm.startBroadcast(user);

        tetherUSDTPool.createPair(address(bitcoin), address(bitcoin2));


        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 200e18);
        IERC20(address(bitcoin2)).approve(address(tetherUSDTPool), 200e18);

        (uint tokenAmountA, uint tokenAmountB) = tetherUSDTPool.addLiquidity(address(bitcoin), address(bitcoin2), 200e18, 200e18);

        console.log("This is adding the liquidity ");
        console.log(tokenAmountA);
        console.log(tokenAmountB);
        console.log("===========");

        // This is the swapping of the token part

        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 10e18);
        tetherUSDTPool.swapToken(address(bitcoin), address(bitcoin2), 10e18);
        vm.stopBroadcast();
    }


    function testSwapFailedTokens() public {
        vm.startBroadcast(user);

        tetherUSDTPool.createPair(address(bitcoin), address(bitcoin2));


        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 200e18);
        IERC20(address(bitcoin2)).approve(address(tetherUSDTPool), 200e18);

        (uint tokenAmountA, uint tokenAmountB) = tetherUSDTPool.addLiquidity(address(bitcoin), address(bitcoin2), 200e18, 200e18);

        // disable the router of quick swap from making transfer of token
        bitcoin.addDexAddress(address(ROUTER));

        // This is the swapping of the token part

        IERC20(address(bitcoin)).approve(address(tetherUSDTPool), 10e18);
        vm.expectRevert();
        tetherUSDTPool.swapToken(address(bitcoin), address(bitcoin2), 10e18);

        // unblock the dex address
        bitcoin.removeDexAddress(address(ROUTER));
        tetherUSDTPool.swapToken(address(bitcoin), address(bitcoin2), 10e18);
        vm.stopBroadcast();
    }

}