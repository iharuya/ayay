// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

interface IAyAyReceiver {
    function currencyAddress() external view returns (address);
    function balance() external view returns (uint256);
    function withdraw(address payable to, uint256 amount) external;
}
