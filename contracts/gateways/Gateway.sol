// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {SignatureChecker} from "@openzeppelin/contracts_latest/utils/cryptography/SignatureChecker.sol";

import {IGateway} from "./IGateway.sol";

abstract contract Gateway is Context, ERC165, IGateway {
    // Set of voucher hashes served
    mapping(bytes32 => bool) public override voucherServed;

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IGateway).interfaceId || super.supportsInterface(interfaceId);
    }

    // --- Protected utilities --------------------------------------------------------------------------------------------------------------------------------

    /**
     * Validate the given voucher against the given signature, by the given signer
     *
     * @param voucherHash  The voucher hash to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function _validateVoucher(
        bytes32 voucherHash,
        bytes memory signature,
        address signer
    ) internal view {
        require(SignatureChecker.isValidSignatureNow(signer, voucherHash, signature), "Gateway: invalid voucher signature");
        require(voucherServed[voucherHash] == false, "Gateway: voucher already served");
    }

    /**
     * Mark the given voucher hash as served, and emit the corresponding event
     *
     * @param voucherHash  The voucher hash to serve
     * @custom:emit  VoucherServed
     */
    function _serveVoucher(bytes32 voucherHash) internal {
        voucherServed[voucherHash] = true;
        emit VoucherServed(voucherHash, _msgSender());
    }
}
