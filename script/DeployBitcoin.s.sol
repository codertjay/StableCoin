// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {Bitcoin} from "../src/Bitcoin.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployBitcoin is Script {

    address  constant DeployerAddress = 0xdeaA322F2b12c8dF4634BCdE680FCA4F3F3F80Eb;

    function run() external returns (Bitcoin) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 initialSupply = 129000 * 10 ** 18; // 1,000,000 tokens with 18 decimals
        uint256 minimumWithdrawal = 1E18; // 1 token with 18 decimals
        string memory tokenName = "Bitcoin";
        string memory tokenSymbol = "BTC";
        Bitcoin stableCoin = new Bitcoin(initialSupply, minimumWithdrawal, tokenName, tokenSymbol);

        vm.stopBroadcast();
        console.log("Deployed Bitcoin at address: %s", address(stableCoin));
        return stableCoin;
    }

}