// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IMigrator {
  // Constants
  function USDC_ADDRESS() external view returns (address);

  function MAI_ADDRESS() external view returns (address);

  function LP_ADDRESS() external view returns (address);

  function QUICKSWAP_ROUTER_ADDRESS() external view returns (address);

  function QIDAO_FARM_ADDRESS() external view returns (address);

  function QI_ADDRESS() external view returns (address);

  function QIDAO_POOL_ID() external view returns (uint256);

  // Methods
  function quoteV1(uint256 pe) external view returns (uint256 usdc, uint256 p);

  function migrateV1(uint256 pe)
    external
    view
    returns (uint256 usdc, uint256 p);
}
