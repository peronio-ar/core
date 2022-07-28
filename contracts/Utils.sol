// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// Compute square-roots accorfding to the Babylonian (viz. Heron's) method
//
// Ref: https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method
//
function sqrt256(
    uint256 y
)
    pure
    returns (uint256 z)
{
    if (y > 3) {
        z = y;
        uint256 x = y / 2 + 1;
        while (x < z) {
            (z, x) = (x, (y / x + x) / 2);
        }
    } else if (y != 0) {
        z = 1;
    } else {
        z = 0;
    }
}
