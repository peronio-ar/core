// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20PermitGateway} from "./IERC20PermitGateway.sol";

interface IPeronioGateway is IERC20PermitGateway {
    // --- mint -----------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * mint() voucher
     *
     * @custom:member from  The address from which to transfer USDC collateral
     * @custom:member to  The address to which minted PE tokens are transferred
     * @custom:member usdcAmount  The number of USDC tokens to provide as collateral
     * @custom:member minReceive  The minimum number of PE tokens to mint
     * @custom:member nonce  The voucher nonce to use
     * @custom:member voucherDeadline  The maximum block timestamp this voucher is valid until
     * @custom:member metadata  Additional abi.encode()-ed metadata
     */
    struct MintVoucher {
        address from;
        address to;
        uint256 usdcAmount;
        uint256 minReceive;
        //
        uint256 nonce;
        uint256 voucherDeadline;
        //
        bytes metadata;
    }

    /**
     * Return the typehash associated to the mintWithVoucher() method
     *
     * @return  The typehash associated to the mintWithVoucher() method
     */
    function MINT_WITH_VOUCHER_TYPEHASH() external view returns (bytes32);

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashMintWithVoucher(MintVoucher memory voucher) external view returns (bytes32 voucherHash);

    /**
     * Validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function validateMintWithVoucher(
        MintVoucher memory voucher,
        bytes memory signature,
        address signer
    ) external view;

    /**
     * Execute the mint() call to the underlying Peronio token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function mintWithVoucher(MintVoucher memory voucher, bytes memory signature) external;

    // --- withdraw -------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * withdraw() voucher
     *
     * @custom:member from  The address from which to burn extracted PE tokens
     * @custom:member to  The address to which extracted USDC tokens are transferred
     * @custom:member peAmount  The number of PE tokens to burn
     * @custom:member nonce  The voucher nonce to use
     * @custom:member voucherDeadline  The maximum block timestamp this voucher is valid until
     * @custom:member metadata  Additional abi.encode()-ed metadata
     */
    struct WithdrawVoucher {
        address from;
        address to;
        uint256 peAmount;
        //
        uint256 nonce;
        uint256 voucherDeadline;
        //
        bytes metadata;
    }

    /**
     * Return the typehash associated to the withdrawWithVoucher() method
     *
     * @return  The typehash associated to the withdrawWithVoucher() method
     */
    function WITHDRAW_WITH_VOUCHER_TYPEHASH() external view returns (bytes32);

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashWithdrawWithVoucher(WithdrawVoucher memory voucher) external view returns (bytes32 voucherHash);

    /**
     * Validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function validateWithdrawWithVoucher(
        WithdrawVoucher memory voucher,
        bytes memory signature,
        address signer
    ) external view;

    /**
     * Execute the withdraw() call to the underlying Peronio token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function withdrawWithVoucher(WithdrawVoucher memory voucher, bytes memory signature) external;
}
