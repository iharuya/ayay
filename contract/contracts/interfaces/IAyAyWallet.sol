// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;
import "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import "./IAyAyReceiver.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IAyAyWallet {
    function nonce() external view returns (uint256);
    function entryPoint() external view returns (IEntryPoint);
    function pay(IAyAyReceiver receiver, IERC20 token, uint256 amount) external;
    function getDeposit() external view returns (uint256);
    function addDeposit() external payable;
    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) external;
}