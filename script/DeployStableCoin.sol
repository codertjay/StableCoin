// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";

contract DeployStableCoin is Script {


    function run() external returns (StableCoin) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 initialSupply = 1_000_000 * 10 ** 18; // 1,000,000 tokens with 18 decimals
        uint256 minimumWithdrawal = 1 * 10 ** 18; // 1 token with 18 decimals
        StableCoin stableCoin = new StableCoin(initialSupply, minimumWithdrawal);
        vm.stopBroadcast();
        console.log("Deployed StableCoin at address: %s", address(stableCoin));
        return stableCoin;
    }


}