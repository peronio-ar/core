// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * Type representing an CUM token quantity
 *
 */
type CumpaQuantity is uint256;

interface ICumpa {

    /**
     * Return the timestamp of last reap() execution
     *
     * @return  Timestamp of last reap() execution
     */
    function lastExecuted() external view returns (uint256);

    /**
     * Reap Peronio rewards, and get CUMs in return
     *
     * @return cumpaAmount  Number of CUM tokens awarded
     */
    function reap() external returns (CumpaQuantity cumpaAmount);
}
