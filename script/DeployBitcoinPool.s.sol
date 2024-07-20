// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {Bitcoin} from "../src/Bitcoin.sol";
import {BitcoinPool} from  "../src/BitcoinPool.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract DeployBitcoinPool is Script {
    address private constant BitcoinAddress = 0x10A7Ee546C3108a4F97Ba95ed685eE17078Cc2fE;
    address private constant BitcoinPoolAddress = 0x83dE4c97D1551B55e309DD54C9435849c9eCeC36;
    address private constant ExternalToken = 0xc2132D05D31c914a87C6611C10748AEb04B58e8F;

    uint256 private constant TokenLiquidityAmount = 6e18;
    uint256 private constant  ExternalTokenLiquidityAmount = 6e6;

    address private constant ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;
    address private constant FACTORY = 0x5757371414417b8C6CAad45bAeF941aBc7d3Ab32;

    Bitcoin public  bitcoin;
    BitcoinPool public  bitcoinPool;


    function run() external returns (BitcoinPool) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        setUp();
       removeLiquidity();

        vm.stopBroadcast();
        return bitcoinPool;
    }


    function newSetUp() public {
        bitcoinPool = new  BitcoinPool(FACTORY, ROUTER);
        bitcoin = Bitcoin(BitcoinAddress);
    }


    function setUp() public {
        bitcoinPool = BitcoinPool(BitcoinPoolAddress);
        bitcoin = Bitcoin(BitcoinAddress);
    }


    function createPair() public {
        // this is used to create pair
        bitcoinPool.createPair(BitcoinAddress, ExternalToken);
    }

    function getPair() public view returns (address) {
        // this is used to get pair
        address pairAddress = bitcoinPool.getPair(BitcoinAddress, ExternalToken);
        return pairAddress;
    }


    function removeLiquidity() public {
        bitcoin.setMinWithdrawal(0);

        // this is to remove the liquidity
        bitcoinPool.removeLiquidity(BitcoinAddress, ExternalToken);
        bitcoinPool.withdrawAllERC20(ExternalToken);
        bitcoinPool.withdrawAllERC20(address(bitcoin));

    }


    function addLiquidity() public {

        IERC20(BitcoinAddress).approve(address(bitcoinPool), TokenLiquidityAmount);
        IERC20(ExternalToken).approve(address(bitcoinPool), ExternalTokenLiquidityAmount);

        // this is used to add liquidity
        bitcoinPool.addLiquidity(BitcoinAddress, ExternalToken, TokenLiquidityAmount, ExternalTokenLiquidityAmount);
    }

    function maintainPeg() public {
        bitcoin.setMinWithdrawal(0);

        IERC20(address(bitcoin)).approve(address(bitcoinPool), type(uint256).max);
        IERC20(address(ExternalToken)).approve(address(bitcoinPool), type(uint256).max);

        uint256 swapAmount = 5e17;

        bitcoinPool.swapToken(address(bitcoin), address(ExternalToken), swapAmount);
        // this is used to maintain peg
        bitcoinPool.maintainPeg(BitcoinAddress, ExternalToken);

        address pairAddress = bitcoinPool.getPair(BitcoinAddress, ExternalToken);

        uint256 miniMumAmount = IERC20(bitcoin).balanceOf(address(pairAddress));

        bitcoin.setMinWithdrawal(miniMumAmount);
    }

}