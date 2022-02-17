// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Peronio.sol";

contract AutoCompounder {
    Peronio peronio;

    constructor (address _peronio) {
        peronio = Peronio(_peronio);
    }

    uint256 public lastExecuted;

    modifier onlyManager() {
        require(msg.sender == address(0xFA14B3b6104A64F676A170C61A93e17556CE128e), "Not authorized: Only manager");
        _;
    }

    /*
        Try catch flow
        
        cost: 0.1 Matic per task
    */

    function lastExec() internal view returns (bool) {
        return ((block.timestamp - lastExecuted) > 86400);
    }

    function autoCompound() public onlyManager() {
        require(
            lastExec(),
            "autoCompound: Time not elapsed"
        );

        try peronio.claimRewards() {
        } catch {
        }

        try peronio.compoundRewards() {
        } catch {
        }

        lastExecuted = block.timestamp;
    }

    function resolver() external view returns (bool, bytes memory execPayload) {
        return (lastExec(), abi.encodeWithSelector((this).autoCompound.selector) );
    }

}