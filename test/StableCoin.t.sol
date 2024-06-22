// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {StableCoin} from "../src/StableCoin.sol";


contract StableCoinTest is Test {
    StableCoin stableCoin;
    address user = address(456);
    address userB = address(456);

    function setUp() external {
        uint256 minWithdrawal = 1E18;
        uint256 initialSupply = 12900E18;

        vm.startBroadcast(user);
        stableCoin = new StableCoin(initialSupply, minWithdrawal);
        vm.stopBroadcast();
    }


    function testSetMinWithdrawal() public {
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        stableCoin.setMinWithdrawal(_minWithdrawal);
        assertEq(stableCoin.minWithdrawal(), _minWithdrawal);
        vm.stopBroadcast();

    }

    function testBurn() public {
        uint256 _initialSupply = 1E18;
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        stableCoin = new StableCoin(_initialSupply, _minWithdrawal);
        stableCoin.burn(1E18);
        assertEq(stableCoin.balanceOf(address(this)), 0);

        vm.stopBroadcast();
    }

    function testMint() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        stableCoin = new StableCoin(_initialSupply, _minWithdrawal);
        stableCoin.mint(address(this), 10E18);
        vm.stopBroadcast();

        assertEq(stableCoin.balanceOf(address(this)), 10E18);

    }


    function testTransfer() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        stableCoin = new StableCoin(_initialSupply, _minWithdrawal);
        stableCoin.transfer(address(this), 9E18);
        vm.stopBroadcast();

        assertEq(stableCoin.balanceOf(address(this)), 9E18);
    }


    function testFailedTransfer() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        stableCoin = new StableCoin(_initialSupply, _minWithdrawal);
        vm.expectRevert();
        stableCoin.transfer(address(this), 1E18);
        vm.stopBroadcast();
    }


    function testTransferFrom() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        stableCoin = new StableCoin(_initialSupply, _minWithdrawal);

        //  Approve user to spend up to 10E18 tokens on behalf of user
        stableCoin.approve(user, 10E18);

        // Now, transferFrom can be called successfully
        stableCoin.transferFrom(user, userB, 10E18);
        vm.stopBroadcast();

        assertEq(stableCoin.balanceOf(userB), 10E18);
    }

}