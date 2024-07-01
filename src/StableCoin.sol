// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from  "node_modules/@openzeppelin/contracts/access/Ownable.sol";


contract StableCoin is ERC20Burnable, Ownable {
    uint256 public minWithdrawal;  // Min withdrawal amount in the same units as the token

    mapping(address => bool) private dexAddresses; // Mapping to identify DEX addresses


    error StableCoin__AmountMustBeMoreThanZero();
    error StableCoin__BurnAmountExceedsBalance();
    error StableCoin__NotZeroAddress();
    error StableCoin__AmountAboveMinWithdrawal();
    error StableCoin__TransferToDexNotAllowed();

    constructor(uint256 _initialSupply, uint256 _minWithdrawal) ERC20("New StableCoin", "NSTC") Ownable(msg.sender) {
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
        if (dexAddresses[recipient]) {
            revert StableCoin__TransferToDexNotAllowed();
        }

        if (amount < minWithdrawal) {
            revert StableCoin__AmountAboveMinWithdrawal();
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (dexAddresses[recipient]) {
            revert StableCoin__TransferToDexNotAllowed();
        }

        if (amount < minWithdrawal) {
            revert StableCoin__AmountAboveMinWithdrawal();
        }
        return super.transferFrom(sender, recipient, amount);
    }

    // Function to mark an address as a DEX
    function addDexAddress(address _dexAddress) external onlyOwner {
        dexAddresses[_dexAddress] = true;
    }

    // Optional: Function to remove a DEX address
    function removeDexAddress(address _dexAddress) external onlyOwner {
        delete dexAddresses[_dexAddress];
    }


    function getDexAddress(address _dexAddress) external view returns (bool) {
        return dexAddresses[_dexAddress];
    }

}
