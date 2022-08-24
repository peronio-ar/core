// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IMigrator {
    // --- Events ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Emitted upon migration
     *
     * @param timestamp  The moment in time when migration took place
     * @param oldPe  The number of old PE tokens withdraw from the previous version
     * @param usdc  The number of USDC tokens converted from the previous version and into the new version
     * @param newPe  The number of new PE tokens migrated to the new version
     */
    event Migrated(uint256 timestamp, uint256 oldPe, uint256 usdc, uint256 newPe);

    // --- Addresses - Automatic ------------------------------------------------------------------------------------------------------------------------------

    /**
     * Retrieve the old version's address
     *
     * @return The address in question
     */
    function peronioV1Address() external view returns (address);

    /**
     * Retrieve the new version's address
     *
     * @return The address in question
     */
    function peronioV2Address() external view returns (address);

    // --- Quotes ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Retrieve the number of USDC tokens to withdraw from the old contract, and the number of OE tokens to mint on the new one
     *
     * @param amount  The number of PE tokens to withdraw from the old contract
     * @return usdc  The number of USDC tokens to withdraw from the old contract
     * @return pe  The number of PE tokens to mint on the new contract
     */
    function quote(uint256 amount) external view returns (uint256 usdc, uint256 pe);

    // --- Migration Proper -----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Migrate the given number of PE tokens from the old contract to the new one
     *
     * @param amount  The number of PE tokens to withdraw from the old contract
     * @return usdc  The number of USDC tokens withdrawn from the old contract
     * @return pe  The number of PE tokens minted on the new contract
     * @custom:emit  Migrated
     */
    function migrate(uint256 amount) external returns (uint256 usdc, uint256 pe);
}
