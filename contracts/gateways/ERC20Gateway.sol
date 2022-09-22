// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {EIP712} from "@openzeppelin/contracts_latest/utils/cryptography/draft-EIP712.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";

import {Gateway} from "./Gateway.sol";
import {IERC20Gateway} from "./IERC20Gateway.sol";

abstract contract ERC20Gateway is EIP712, Gateway, IERC20Gateway, ReentrancyGuard {

    // address of the underlying ERC20 token
    address public immutable override token;
    // generated name of gateway proper
    string public override name;

    /**
     * Build a new ERC20Gateway from the given token address and gateway name
     *
     * @param _token  Underlying ERC20 token
     * @param _name  The name to give the newly created gateway
     */
    constructor(address _token, string memory _name) EIP712(_name, "1") {
        token = _token;
        name = _name;
    }

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Gateway, IERC165) returns (bool) {
        return interfaceId == type(IERC20Gateway).interfaceId || super.supportsInterface(interfaceId);
    }

    // --- transferFrom ---------------------------------------------------------------------------------------------------------------------------------------

    // typehash associated to the transferFromWithVoucher() method
    bytes32 public constant override TRANSFER_FROM_WITH_VOUCHER_TYPEHASH =
        keccak256(bytes("transferFromWithVoucher(TransferFromVoucher{address,address,uint256,uint256,uint256,bytes})"));

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashTransferFromWithVoucher(TransferFromVoucher memory voucher) external view override returns (bytes32 voucherHash) {
        voucherHash = _hashTransferFromWithVoucher(voucher);
    }

    /**
     * Validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function validateTransferFromWithVoucher(TransferFromVoucher memory voucher, bytes memory signature, address signer) external view override {
        _validateTransferFromWithVoucher(voucher, signature, signer);
    }

    /**
     * Execute the transferFrom() call to the underlying ERC20 token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function transferFromWithVoucher(TransferFromVoucher memory voucher, bytes memory signature) external nonReentrant override {
        _beforeTransferFromWithVoucher(voucher);
        _transferFromWithVoucher(voucher, signature);
        _afterTransferFromWithVoucher(voucher);
    }

    // --- Protected interface --------------------------------------------------------------------------------------------------------------------------------

    /**
     * Actually return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function _hashTransferFromWithVoucher(TransferFromVoucher memory voucher) internal view returns (bytes32 voucherHash) {
        voucherHash = _hashTypedDataV4(keccak256(abi.encode(TRANSFER_FROM_WITH_VOUCHER_TYPEHASH, voucher)));
    }

    /**
     * Actually validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function _validateTransferFromWithVoucher(TransferFromVoucher memory voucher, bytes memory signature, address signer) internal view {
        _validateVoucher(_hashTransferFromWithVoucher(voucher), signature, signer);
    }

    /**
     * Actually execute the transferFrom() call to the underlying ERC20 token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function _transferFromWithVoucher(TransferFromVoucher memory voucher, bytes memory signature) internal {
        require(block.timestamp <= voucher.voucherDeadline, string.concat(name, ": expired deadline"));

        bytes32 voucherHash = _hashTransferFromWithVoucher(voucher);
        _validateVoucher(voucherHash, signature, voucher.from);
        _serveVoucher(voucherHash);

        IERC20(token).transferFrom(voucher.from, voucher.to, voucher.amount);
    }

    /**
     * Hook called before the actual transferFrom() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforeTransferFromWithVoucher(TransferFromVoucher memory voucher) internal {}

    /**
     * Hook called after the actual transferFrom() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterTransferFromWithVoucher(TransferFromVoucher memory voucher) internal {}
}
