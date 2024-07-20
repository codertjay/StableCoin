// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Bitcoin} from "../src/Bitcoin.sol";


contract BitcoinTest is Test {
    Bitcoin bitcoin;
    address user = address(456);
    address userB = address(456);


    function setUp() external {
        vm.createFork(vm.envString("POLYGON_RPC_URL"));

        uint256 minWithdrawal = 1E18;
        uint256 initialSupply = 12900E18;

        vm.startBroadcast(user);
        bitcoin = new Bitcoin(initialSupply, minWithdrawal, "DamnValuableToken", "DVT");
        vm.stopBroadcast();
    }


    function testSetMinWithdrawal() public {
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        bitcoin.setMinWithdrawal(_minWithdrawal);
        assertEq(bitcoin.minWithdrawal(), _minWithdrawal);
        vm.stopBroadcast();

    }

    function testBurn() public {
        uint256 _initialSupply = 1E18;
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        bitcoin = new Bitcoin(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        bitcoin.burn(1E18);
        assertEq(bitcoin.balanceOf(address(this)), 0);

        vm.stopBroadcast();
    }

    function testMint() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        bitcoin = new Bitcoin(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        bitcoin.mint(address(this), 10E18);
        vm.stopBroadcast();

        assertEq(bitcoin.balanceOf(address(this)), 10E18);

    }


    function testTransfer() public {

        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        bitcoin = new Bitcoin(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        bitcoin.setMinWithdrawal(1E18);


        bitcoin.transfer(address(this), 9E18);
        vm.stopBroadcast();

        assertEq(bitcoin.balanceOf(address(this)), 9E18);
    }


    function testFailedTransfer() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        bitcoin = new Bitcoin(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        vm.expectRevert();
        bitcoin.transfer(address(this), 1E18);
        vm.stopBroadcast();
    }


    function testTransferFromFailed() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        bitcoin = new Bitcoin(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");

        //  Approve user to spend up to 10E18 tokens on behalf of user
        bitcoin.approve(user, 10E18);

        // Now, transferFrom can be called successfully
        bitcoin.transferFrom(user, userB, 10E18);
        vm.stopBroadcast();

        assertEq(bitcoin.balanceOf(userB), 10E18);
    }


    function testAddDexAddress() public {
        vm.startBroadcast(user);
        bitcoin.addDexAddress(address(this));
        vm.stopBroadcast();
        assertEq(bitcoin.getDexAddress(address(this)), true);
    }

}