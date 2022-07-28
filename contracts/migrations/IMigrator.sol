// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IMigrator {
    // Constants
    function usdcAddress() external view returns (address);

    function maiAddress() external view returns (address);

    function lpAddress() external view returns (address);

    function quickSwapRouterAddress() external view returns (address);

    function qiDaoFarmAddress() external view returns (address);

    function qiAddress() external view returns (address);

    function qiDaoPoolId() external view returns (uint256);

    // Methods
    function quoteV1(uint256 pe) external view returns (uint256 usdc, uint256 p);

    function migrateV1(uint256 pe) external view returns (uint256 usdc, uint256 p);
}
