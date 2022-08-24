// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IMigrator {
    // --- Events ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Emitted upon migration
     *
     * @param timestamp  The address initializing the contract
     * @param oldPe  The number of old PE tokens withdraw
     * @param usdc  The number of USDC tokens converted
     * @param newPe  The number of new PE tokens migrated
     */
    event Migrated(uint256 timestamp, uint256 oldPe, uint256 usdc, uint256 newPe);

    // Peronio Addresses
    function peronioV1Address() external view returns (address);

    function peronioV2Address() external view returns (address);

    // Methods
    function quote(uint256 peV1) external view returns (uint256 usdc, uint256 pe);

    function migrate(uint256 peV1) external returns (uint256 usdc, uint256 pe);
}
