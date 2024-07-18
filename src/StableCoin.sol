// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract StableCoin is ERC20Burnable {
    uint256 public minWithdrawal;
    address internal owner;

    mapping(address => bool) private blackListDexAddresses; // Mapping to identify DEX addresses


    error StableCoin__AmountMustBeMoreThanZero();
    error StableCoin__BurnAmountExceedsBalance();
    error StableCoin__NotZeroAddress();
    error StableCoin__AmountAboveMinWithdrawal();
    error StableCoin__TransferToDexNotAllowed();
    error StableCoin__NotAllowed();

    event MinWithdrawalSet(uint256 minWithdrawal);
    event DexAddressAdded(address indexed dexAddress);
    event DexAddressRemoved(address indexed dexAddress);


    modifier onlyOwner(){
        if (msg.sender != owner) {
            revert StableCoin__NotAllowed();
        }
        _;
    }

    constructor(uint256 _initialSupply, uint256 _minWithdrawal, string memory _tokenName, string memory _tokenSymbol)
        ERC20(_tokenName, _tokenSymbol) {
        _mint(msg.sender, _initialSupply);
        minWithdrawal = _minWithdrawal;
        owner = msg.sender;
    }


    function setMinWithdrawal(uint256 _minWithdrawal) external onlyOwner {
        minWithdrawal = _minWithdrawal;
        emit MinWithdrawalSet(_minWithdrawal);
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
        if (blackListDexAddresses[msg.sender]) {
            revert StableCoin__TransferToDexNotAllowed();
        }

        if (amount < minWithdrawal) {
            revert StableCoin__AmountAboveMinWithdrawal();
        }
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (blackListDexAddresses[msg.sender]) {
            revert StableCoin__TransferToDexNotAllowed();
        }

        if (amount < minWithdrawal) {
            revert StableCoin__AmountAboveMinWithdrawal();
        }
        return super.transferFrom(sender, recipient, amount);
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

}
