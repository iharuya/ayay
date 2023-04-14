// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AyAyWallet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AyAyFactory is Ownable {
    IEntryPoint public immutable entryPoint;

    constructor(IEntryPoint _entryPoint) {
        entryPoint = _entryPoint;
    }

    /**
     * create an account, and return its address.
     * returns the address even if the account is already deployed.
     * Note that during UserOperation execution, this method is called only if the account is not deployed.
     * This method returns an existing account address so that entryPoint.getSenderAddress() would work even after account creation
     */
    function createAccount(
        address owner,
        uint256 salt
    ) public returns (AyAyWallet ret) {
        address addr = getAddress(owner, salt);
        uint codeSize;
        assembly {
            codeSize := extcodesize(addr)
        }
        if (codeSize > 0) {
            return AyAyWallet(payable(addr));
        }

        ret = new AyAyWallet{salt: bytes32(salt)}(entryPoint, owner);
    }

    function getAddress(
        address owner,
        uint256 salt
    ) public view returns (address) {
        return
            Create2.computeAddress(
                bytes32(salt),
                keccak256(
                    abi.encodePacked(
                        type(AyAyWallet).creationCode,
                        abi.encode(entryPoint, owner)
                    )
                )
            );
    }

    function addStake(uint32 unstakeDelaySec) external payable onlyOwner {
        entryPoint.addStake{value : msg.value}(unstakeDelaySec);
    }
     /**
     * unlock the stake, in order to withdraw it.
     * This can't serve requests once unlocked, until it calls addStake again
     */
    function unlockStake() external onlyOwner {
        entryPoint.unlockStake();
    }
    /**
     * withdraw the entire stake.
     * stake must be unlocked first (and then wait for the unstakeDelay to be over)
     * @param withdrawAddress the address to send withdrawn value.
     */
    function withdrawStake(address payable withdrawAddress) external onlyOwner {
        entryPoint.withdrawStake(withdrawAddress);
    }
    function withdrawTo(address payable withdrawAddress, uint256 amount) public onlyOwner {
        entryPoint.withdrawTo(withdrawAddress, amount);
    }
}
