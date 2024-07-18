// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";
import {IERC20} from  "node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployStableCoin is Script {

    address  constant DeployerAddress = 0xdeaA322F2b12c8dF4634BCdE680FCA4F3F3F80Eb;


    function run() external returns (StableCoin) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 initialSupply = 129000 * 10 ** 18; // 1,000,000 tokens with 18 decimals
        uint256 minimumWithdrawal = 10E18; // 1 token with 18 decimals
        string memory tokenName = "DamnValuableToken";
        string memory tokenSymbol = "DVT";
        StableCoin stableCoin = new StableCoin(initialSupply, minimumWithdrawal, tokenName, tokenSymbol);

        stableCoin.mint(DeployerAddress, 100000 * 10 ** 18);

        vm.stopBroadcast();
        console.log("Deployed StableCoin at address: %s", address(stableCoin));
        return stableCoin;
    }

}