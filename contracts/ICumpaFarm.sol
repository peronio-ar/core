// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICumpaFarm {
    function distribute() external;

    function collectedTips() external view returns (uint256);

    function rewardsByAddress(address to) external view returns (uint256);

    function deposit(uint256 amount) external;

    function withdraw(address to, uint256 amount) external;

    function extract(address to, uint256 amount) external;
}
