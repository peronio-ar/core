// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IMigrator {
    // Peronio Addresses
    function peronioV1Address() external view returns (address);

    function peronioV2Address() external view returns (address);

    // Methods
    function quote(uint256 peV1) external view returns (uint256 usdc, uint256 pe);

    function migrate(uint256 peV1) external returns (uint256 usdc, uint256 pe);
}
