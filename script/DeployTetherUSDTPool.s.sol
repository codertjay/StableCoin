// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {TetherUSDT} from "../src/TetherUSDT.sol";
import {TetherUSDTPool} from  "../src/TetherUSDTPool.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DeployTetherUSDTPool is Script {
    address private constant TetherUSDTAddress = 0x10A7Ee546C3108a4F97Ba95ed685eE17078Cc2fE;
    address private constant TetherUSDTPoolAddress = 0x83dE4c97D1551B55e309DD54C9435849c9eCeC36;
    address private constant ExternalToken = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    uint256 private constant TokenLiquidityAmount = 6e18;
    uint256 private constant  ExternalTokenLiquidityAmount = 6e6;

    address private constant ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address private constant FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;

    TetherUSDT public  tetherUSDT;
    TetherUSDTPool public  tetherUSDTPool;


    function run() external returns (TetherUSDTPool) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        setUp();
       removeLiquidity();

        vm.stopBroadcast();
        return tetherUSDTPool;
    }


    function newSetUp() public {
        tetherUSDTPool = new  TetherUSDTPool(FACTORY, ROUTER);
        tetherUSDT = TetherUSDT(TetherUSDTAddress);
    }


    function setUp() public {
        tetherUSDTPool = TetherUSDTPool(TetherUSDTPoolAddress);
        tetherUSDT = TetherUSDT(TetherUSDTAddress);
    }


    function createPair() public {
        // this is used to create pair
        tetherUSDTPool.createPair(TetherUSDTAddress, ExternalToken);
    }

    function getPair() public view returns (address) {
        // this is used to get pair
        address pairAddress = tetherUSDTPool.getPair(TetherUSDTAddress, ExternalToken);
        return pairAddress;
    }


    function removeLiquidity() public {
        tetherUSDT.setMinWithdrawal(0);

        // this is to remove the liquidity
        tetherUSDTPool.removeLiquidity(TetherUSDTAddress, ExternalToken);
        tetherUSDTPool.withdrawAllERC20(ExternalToken);
        tetherUSDTPool.withdrawAllERC20(address(tetherUSDT));

    }


    function addLiquidity() public {

        IERC20(TetherUSDTAddress).approve(address(tetherUSDTPool), TokenLiquidityAmount);
        IERC20(ExternalToken).approve(address(tetherUSDTPool), ExternalTokenLiquidityAmount);

        // this is used to add liquidity
        tetherUSDTPool.addLiquidity(TetherUSDTAddress, ExternalToken, TokenLiquidityAmount, ExternalTokenLiquidityAmount);
    }

    function maintainPeg() public {
        tetherUSDT.setMinWithdrawal(0);

        IERC20(address(tetherUSDT)).approve(address(tetherUSDTPool), type(uint256).max);
        IERC20(address(ExternalToken)).approve(address(tetherUSDTPool), type(uint256).max);

        uint256 swapAmount = 5e17;

        tetherUSDTPool.swapToken(address(tetherUSDT), address(ExternalToken), swapAmount);
        // this is used to maintain peg
        tetherUSDTPool.maintainPeg(TetherUSDTAddress, ExternalToken);

        address pairAddress = tetherUSDTPool.getPair(TetherUSDTAddress, ExternalToken);

        uint256 miniMumAmount = IERC20(tetherUSDT).balanceOf(address(pairAddress));

        tetherUSDT.setMinWithdrawal(miniMumAmount);
    }



}