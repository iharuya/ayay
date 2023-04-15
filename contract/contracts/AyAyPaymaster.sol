// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@account-abstraction/contracts/core/BasePaymaster.sol";
import "./interfaces/IAyAyReceiver.sol";
import "./interfaces/IAyAyWallet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AyAyPaymaster is BasePaymaster {
    IAyAyReceiver public immutable RECEIVER;
    uint256 public immutable MINIMAL_AMOUNT;

    constructor(
        IEntryPoint entryPoint_,
        IAyAyReceiver receiver_,
        address owner_
    ) BasePaymaster(entryPoint_) {
        RECEIVER = receiver_;
        MINIMAL_AMOUNT = 50 * 10e5; // 50YEN
        _transferOwnership(owner_);
    }

    function _validatePaymasterUserOp(
        UserOperation calldata userOp,
        bytes32 /*userOpHash*/,
        uint256 /* requiredPreFund */
    ) internal view override returns (bytes memory context, uint256 validationData) {
        bytes4 selector = bytes4(userOp.callData[:4]);
        (address receiver, address token, uint256 amount) = abi.decode(
            userOp.callData[4:],
            (address, address, uint256)
        );
        require(selector == IAyAyWallet.pay.selector, "Unsupported calldata");
        require(receiver == address(RECEIVER), "Incorrect receiver");
        require(token == RECEIVER.currencyAddress(), "Incorrect token");
        require(amount >= MINIMAL_AMOUNT, "Amount too small");

        return ("", 0);
    }
}
