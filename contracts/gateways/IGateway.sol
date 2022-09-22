// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IGateway is IERC165 {

    /**
     * Emitted upon a voucher being served
     *
     * @param voucherHash  The voucher hash served
     * @param delegate  The delegate serving the voucher
     */
    event VoucherServed(bytes32 indexed voucherHash, address delegate);

    /**
     * Determine whether the given voucher hash has been already served
     *
     * @param voucherHash  The voucher hash to check
     * @return served  True whenever the given voucher hash has already been served
     */
    function voucherServed(bytes32 voucherHash) external view returns (bool served);
}
