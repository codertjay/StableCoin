// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {TetherUSDT} from "../src/TetherUSDT.sol";


contract TetherUSDTTest is Test {
    TetherUSDT tetherUSDT;
    address user = address(456);
    address userB = address(456);


    function setUp() external {
        vm.createFork(vm.envString("POLYGON_RPC_URL"));

        uint256 minWithdrawal = 1E18;
        uint256 initialSupply = 12900E18;

        vm.startBroadcast(user);
        tetherUSDT = new TetherUSDT(initialSupply, minWithdrawal, "DamnValuableToken", "DVT");
        vm.stopBroadcast();
    }


    function testSetMinWithdrawal() public {
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        tetherUSDT.setMinWithdrawal(_minWithdrawal);
        assertEq(tetherUSDT.minWithdrawal(), _minWithdrawal);
        vm.stopBroadcast();

    }

    function testBurn() public {
        uint256 _initialSupply = 1E18;
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        tetherUSDT = new TetherUSDT(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        tetherUSDT.burn(1E18);
        assertEq(tetherUSDT.balanceOf(address(this)), 0);

        vm.stopBroadcast();
    }

    function testMint() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        tetherUSDT = new TetherUSDT(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        tetherUSDT.mint(address(this), 10E18);
        vm.stopBroadcast();

        assertEq(tetherUSDT.balanceOf(address(this)), 10E18);

    }


    function testTransfer() public {

        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        tetherUSDT = new TetherUSDT(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        tetherUSDT.setMinWithdrawal(1E18);


        tetherUSDT.transfer(address(this), 9E18);
        vm.stopBroadcast();

        assertEq(tetherUSDT.balanceOf(address(this)), 9E18);
    }


    function testFailedTransfer() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 1E18;

        vm.startBroadcast(user);
        tetherUSDT = new TetherUSDT(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");
        vm.expectRevert();
        tetherUSDT.transfer(address(this), 1E18);
        vm.stopBroadcast();
    }


    function testTransferFromFailed() public {
        uint256 _initialSupply = 10E18;
        uint256 _minWithdrawal = 10E18;

        vm.startBroadcast(user);
        tetherUSDT = new TetherUSDT(_initialSupply, _minWithdrawal, "DamnValuableToken", "DVT");

        //  Approve user to spend up to 10E18 tokens on behalf of user
        tetherUSDT.approve(user, 10E18);

        // Now, transferFrom can be called successfully
        tetherUSDT.transferFrom(user, userB, 10E18);
        vm.stopBroadcast();

        assertEq(tetherUSDT.balanceOf(userB), 10E18);
    }


    function testAddDexAddress() public {
        vm.startBroadcast(user);
        tetherUSDT.addDexAddress(address(this));
        assertEq(tetherUSDT.getDexAddress(address(this)), true);
        vm.stopBroadcast();
    }

    function testRemoveDexAddress() public {
        vm.startBroadcast(user);
        tetherUSDT.addDexAddress(address(this));
        tetherUSDT.removeDexAddress(address(this));
        assertEq(tetherUSDT.getDexAddress(address(this)), false);
        vm.stopBroadcast();
    }


}