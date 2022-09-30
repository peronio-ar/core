// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IGateway {
    /**
     * Voucher --- tagged union used for specific vouchers' implementation
     *
     * @custom:member tag  An integer representing the type of voucher this particular voucher is
     * @custom:member nonce  The voucher nonce to use
     * @custom:member deadline  The maximum block timestamp this voucher is valid until
     * @custom:member payload  Actual abi.encode()-ed payload (used for serving the call proper)
     * @custom:member metadata  Additional abi.encode()-ed metadata (used for administrative tasks)
     */
    struct Voucher {
        uint32 tag;
        //
        uint256 nonce;
        uint256 deadline;
        //
        bytes payload;
        bytes metadata;
    }

    /**
     * Emitted upon a voucher being served
     *
     * @param voucherHash  The voucher hash served
     * @param delegate  The delegate serving the voucher
     */
    event VoucherServed(bytes32 indexed voucherHash, address delegate);

    /**
     * Return the typehash associated to the Gateway Voucher itself
     *
     * @return  The typehash associated to the gateway Voucher itself
     */
    function VOUCHER_TYPEHASH() external view returns (bytes32);

    /**
     * Determine whether the given voucher hash has been already served
     *
     * @param voucherHash  The voucher hash to check
     * @return served  True whenever the given voucher hash has already been served
     */
    function voucherServed(bytes32 voucherHash) external view returns (bool served);

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashVoucher(Voucher memory voucher) external view returns (bytes32 voucherHash);

    /**
     * Validate the given voucher against the given signature, by the given signer
     *
     * @param voucher  The voucher to validate
     * @param signature  The associated voucher signature
     */
    function validateVoucher(Voucher memory voucher, bytes memory signature) external view;

    /**
     * Serve the given voucher, by forwarding to the appropriate handler for the voucher's tag
     *
     * @param voucher  The voucher to serve
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function serveVoucher(Voucher memory voucher, bytes memory signature) external;
}
