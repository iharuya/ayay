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
        MINIMAL_AMOUNT = 10 * 10e6;
        _transferOwnership(owner_);
    }

    function _validatePaymasterUserOp(
        UserOperation calldata /*userOp*/,
        bytes32 /*userOpHash*/,
        uint256 /* requiredPreFund */
    ) internal pure override returns (bytes memory context, uint256 validationData) {
        // @todo

        return ("", 0);
    }
}
