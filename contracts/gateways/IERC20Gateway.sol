// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IGateway} from "./IGateway.sol";

interface IERC20Gateway is IGateway {

    /**
     * Retrieve the address of the underlying ERC20 token
     *
     * @return  The address of the underlying ERC20 token
     */
    function token() external view returns (address);

    /**
     * Retrieve the generated name of gateway proper
     *
     * @return  The generated name of gateway proper
     */
    function name() external view returns (string memory);

    // --- transferFrom ---------------------------------------------------------------------------------------------------------------------------------------

    /**
     * transferFrom() voucher
     *
     * @custom:member from  The address from which to transfer funds
     * @custom:member to  The address to which to transfer funds
     * @custom:member amount  The number of tokens to transfer
     * @custom:member nonce  The voucher nonce to use
     * @custom:member voucherDeadline  The maximum block timestamp this voucher is valid until
     * @custom:member metadata  Additional abi.encode()-ed metadata
     */
    struct TransferFromVoucher {
        address from;
        address to;
        uint256 amount;
        //
        uint256 nonce;
        uint256 voucherDeadline;
        //
        bytes metadata;
    }

    /**
     * Return the typehash associated to the transferFromWithVoucher() method
     *
     * @return  The typehash associated to the transferFromWithVoucher() method
     */
    function TRANSFER_FROM_WITH_VOUCHER_TYPEHASH() external view returns (bytes32);

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashTransferFromWithVoucher(TransferFromVoucher memory voucher) external view returns (bytes32 voucherHash);

    /**
     * Validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function validateTransferFromWithVoucher(TransferFromVoucher memory voucher, bytes memory signature, address signer) external view;

    /**
     * Execute the transferFrom() call to the underlying ERC20 token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function transferFromWithVoucher(TransferFromVoucher memory voucher, bytes memory signature) external;
}
