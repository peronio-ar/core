// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * Type representing an CUM token quantity
 *
 */
type CumpaQuantity is uint256;

interface ICumpa {
    // --- Roles - Automatic ----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the hash identifying the role responsible for minting new tokens
     *
     * @return roleId  The role hash in question
     */
    function MINTER_ROLE() external view returns (bytes32 roleId); // solhint-disable-line func-name-mixedcase

    /**
     * Return the companion Peronio contract
     *
     * @return  The companion Peronio contract
     */
    function peronio() external view returns (address);

    /**
     * Expose ERC20's _mint() function
     *
     * @param to  Address to mint the CUM tokens to
     * @param amount  Number of CUM tokens to mint
     */
    function mint(address to, uint256 amount) external;

    /**
     * Compound Peronio rewards, and get CUMs in return
     *
     * @return cumpaAmount  Number of CUM tokens awarded
     */
    function compoundRewards() external returns (CumpaQuantity cumpaAmount);
}
