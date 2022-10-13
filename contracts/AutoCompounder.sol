// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPeronio} from "./IPeronio.sol";
import {Ownable} from "@openzeppelin/contracts_latest/access/Ownable.sol";

contract AutoCompounder is Ownable {
    IPeronio internal peronio;

    constructor(address _peronio) {
        peronio = IPeronio(_peronio);
    }

    function autoCompound() public onlyOwner {
        peronio.compoundRewards();
    }
}
