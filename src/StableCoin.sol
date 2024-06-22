// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from  "node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract StableCoin is ERC20Burnable, Ownable {
    uint256 public minWithdrawal;  // Min withdrawal amount in the same units as the token


    error StableCoin__AmountMustBeMoreThanZero();
    error StableCoin__BurnAmountExceedsBalance();
    error StableCoin__NotZeroAddress();
    error StableCoin__AmountAboveMinWithdrawal();

    constructor(uint256 _initialSupply, uint256 _minWithdrawal) ERC20("StableCoin", "STC") Ownable(msg.sender) {
        _mint(msg.sender, _initialSupply);
        minWithdrawal = _minWithdrawal;
    }


    function setMinWithdrawal(uint256 _minWithdrawal) external onlyOwner {
        minWithdrawal = _minWithdrawal;
    }

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert StableCoin__AmountMustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert StableCoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert StableCoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert StableCoin__AmountMustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (amount > minWithdrawal) {
            revert StableCoin__AmountAboveMinWithdrawal();
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (amount > minWithdrawal) {
            revert StableCoin__AmountAboveMinWithdrawal();
        }
        return super.transferFrom(sender, recipient, amount);
    }
}
