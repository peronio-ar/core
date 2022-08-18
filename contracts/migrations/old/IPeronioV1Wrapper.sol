// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IPeronioV1Wrapper {
    function peronioAddress() external view returns (address);

    function usdcAddress() external view returns (address);

    function maiAddress() external view returns (address);

    function lpAddress() external view returns (address);

    function quickSwapRouterAddress() external view returns (address);

    function qiDaoFarmAddress() external view returns (address);

    function qiAddress() external view returns (address);

    function qiDaoPoolId() external view returns (uint256);

    function withdraw(address to, uint256 peAmount) external returns (uint256 usdc);

    function quoteOut(uint256 pe) external view returns (uint256 usdc);
}
