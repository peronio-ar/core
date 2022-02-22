// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./IPeronio.sol";
import "@openzeppelin/contracts_latest/access/Ownable.sol";

contract AutoCompounder is Ownable {
  IPeronio peronio;

  constructor(address _peronio) {
    peronio = IPeronio(_peronio);
  }

  uint256 public lastExecuted;

  function lastExec() internal view returns (bool) {
    return ((block.timestamp - lastExecuted) > 43200); // 12 hours
  }

  function autoCompound() public onlyOwner {
    require(lastExec(), "autoCompound: Time not elapsed");

    peronio.claimRewards();
    peronio.compoundRewards();

    lastExecuted = block.timestamp;
  }
}
