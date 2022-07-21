// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./IPeronio.sol";
import "@openzeppelin/contracts_latest/access/Ownable.sol";


contract AutoCompounder is
    Ownable
{
    IPeronio internal peronio;

    uint256 public lastExecuted;

    constructor(
        address _peronio
    ) {
        peronio = IPeronio(_peronio);
    }

    function autoCompound()
        public
        onlyOwner
    {
        require(12 * 60 * 60 < block.timestamp - lastExecuted, "autoCompound: Time not elapsed");
        lastExecuted = block.timestamp;

        peronio.claimRewards();
        peronio.compoundRewards();
    }
}
