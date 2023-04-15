// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAyAyReceiver.sol";

// No ETH deposit allowed
contract AyAyReceiver is IAyAyReceiver, Ownable {
    IERC20 public immutable CURRENCY;

    constructor(address owner, address currency) {
        _transferOwnership(owner);
        CURRENCY = ERC20(currency);
    }

    function currencyAddress() public view returns (address) {
        return address(CURRENCY);
    }

    function balance() public view returns (uint256) {
        return CURRENCY.balanceOf(address(this));
    }

    function withdraw(address payable to, uint256 amount) public onlyOwner {
        CURRENCY.transfer(to, amount);
    }
}
