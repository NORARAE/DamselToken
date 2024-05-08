// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable@5.0.2/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/token/ERC20/extensions/ERC20FlashMintUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@5.0.2/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact playdamsel@gmail.com
contract Damsel is Initializable, ERC20Upgradeable, ERC20BurnableUpgradeable, ERC20PausableUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC20FlashMintUpgradeable, UUPSUpgradeable {
    address private _devWallet;
    uint256 private _feePercentage;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address devWallet, uint256 feePercentage) {
        _disableInitializers();
        _devWallet = devWallet;
        _feePercentage = feePercentage;

        // Send 10% of the total supply to a secondary address
        uint256 initialSupply = 1000000000 * 10 ** decimals();
        uint256 initialBalance = initialSupply / 10; // 10% of initial supply
        _mint(msg.sender, initialSupply - initialBalance);
        _mint(devWallet, initialBalance);
    }

    function initialize(address initialOwner) initializer public {
        __ERC20_init("Damsel", "DAM");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __Ownable_init(initialOwner);
        __ERC20Permit_init("Damsel");
        __ERC20FlashMint_init();
        __UUPSUpgradeable_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner // Restrict upgrade authorization to the owner (developer)
    {}

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        uint256 feeAmount = (amount * _feePercentage) / 10000;
        uint256 transferAmount = amount - feeAmount;
        _transfer(_msgSender(), recipient, transferAmount);
        _transfer(_msgSender(), _devWallet, feeAmount);
        return true;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
    {
        ERC20PausableUpgradeable._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        virtual
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _update(address from, address to, uint256 value)
        internal
        virtual
    {
        super._update(from, to, value);
    }

    // Events

    event TokensSwappedForETH(address indexed sender, uint256 amountIn, uint256 amountOut);

    // Access Control

    modifier onlyDevWallet() {
        require(_msgSender() == _devWallet, "Damsel: caller is not the dev wallet");
        _;
    }

    // Functionality

    function swapTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] calldata path, uint256 deadline) external onlyDevWallet {
        // Placeholder function for token swap functionality with Uniswap
        // To be implemented when Uniswap integration is ready
        emit TokensSwappedForETH(_msgSender(), amountIn, amountOutMin);
    }

    // Error Handling

    error OnlyOwnerError();
    error InvalidSwapPathError();
}
