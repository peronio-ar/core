// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-IERC20Permit.sol";

import {IERC20Gateway} from "./IERC20Gateway.sol";

interface IERC20PermitGateway is IERC20Gateway {
    // --- permit ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * permit() voucher
     *
     * @custom:member owner  The address of the owner of the funds
     * @custom:member spender  The address of the spender being permitted to move the funds
     * @custom:member value  The number of tokens to allow transfer of
     * @custom:member v  The permit's signature "v" value
     * @custom:member r  The permit's signature "r" value
     * @custom:member s  The permit's signature "s" value
     * @custom:member nonce  The voucher nonce to use
     * @custom:member voucherDeadline  The maximum block timestamp this voucher is valid until
     * @custom:member metadata  Additional abi.encode()-ed metadata
     */
    struct PermitVoucher {
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
        //
        uint256 nonce;
        uint256 voucherDeadline;
        //
        bytes metadata;
    }

    /**
     * Return the typehash associated to the permitWithVoucher() method
     *
     * @return  The typehash associated to the permitWithVoucher() method
     */
    function PERMIT_WITH_VOUCHER_TYPEHASH() external view returns (bytes32);

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashPermitWithVoucher(PermitVoucher memory voucher) external view returns (bytes32 voucherHash);

    /**
     * Validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function validatePermitWithVoucher(
        PermitVoucher memory voucher,
        bytes memory signature,
        address signer
    ) external view;

    /**
     * Execute the permit() call to the underlying ERC20Permit token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function permitWithVoucher(PermitVoucher memory voucher, bytes memory signature) external;
}
