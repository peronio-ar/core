// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {EIP712} from "@openzeppelin/contracts_latest/utils/cryptography/draft-EIP712.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {SignatureChecker} from "@openzeppelin/contracts_latest/utils/cryptography/SignatureChecker.sol";

import "./IGateway.sol";

abstract contract Gateway is Context, EIP712, ERC165, IGateway {
    /**
     * Structure used to keep track of handling functions
     *
     * @custom:member signer  The signer-extractor function
     * @custom:member execute  The execution function
     */
    struct HandlerEntry {
        function(Voucher memory) view returns (address) signer;
        function(Voucher memory) execute;
    }

    // Mapping from voucher tag to handling entry
    mapping(uint32 => HandlerEntry) private voucherHandler;

    // typehash associated to the gateway Voucher itself
    bytes32 public constant override VOUCHER_TYPEHASH = keccak256(bytes("Voucher{uint32,uint256,uint256,bytes,bytes}"));

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

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashVoucher(Voucher memory voucher) external view override returns (bytes32 voucherHash) {
        voucherHash = _hashVoucher(voucher);
    }

    /**
     * Validate the given voucher against the given signature
     *
     * @param voucher  The voucher to validate
     * @param signature  The associated voucher signature
     */
    function validateVoucher(Voucher memory voucher, bytes memory signature) external view override {
        _validateVoucher(voucher, signature);
    }

    /**
     * Serve the given voucher, by forwarding to the appropriate handler for the voucher's tag
     *
     * @param voucher  The voucher to serve
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function serveVoucher(Voucher memory voucher, bytes memory signature) external override {
        _serveVoucher(voucher, signature);
    }

    // --- Protected handling ---------------------------------------------------------------------------------------------------------------------------------

    /**
     * Add the given pair of signer and serving functions to the tag map
     *
     * @param tag  The tag to add the mapping for
     * @param entry  The handling entry instance
     */
    function _addHandler(uint32 tag, HandlerEntry memory entry) internal {
        voucherHandler[tag] = entry;
    }

    /**
     * Add the given pair of signer and serving functions to the tag map
     *
     * @param tag  The tag to remove the mapping for
     * @return entry  The previous entry
     */
    function _removeHandler(uint32 tag) internal returns (HandlerEntry memory entry) {
        entry = voucherHandler[tag];
        delete voucherHandler[tag];
    }

    // --- Protected utilities --------------------------------------------------------------------------------------------------------------------------------

    /**
     * Retrieve the signer of the given Voucher
     *
     * @param voucher  Voucher to retrieve the signer of
     * @return signer  The voucher's signer
     */
    function _getSigner(Voucher memory voucher) internal view returns (address signer) {
        signer = voucherHandler[voucher.tag].signer(voucher);
    }

    /**
     * Retrieve the serving function for the given Voucher
     *
     * @param voucher  Voucher to retrieve the serving function of
     * @return execute  The voucher's serving function
     */
    function _getExecute(Voucher memory voucher) internal view returns (function(Voucher memory) execute) {
        execute = voucherHandler[voucher.tag].execute;
    }

    /**
     * Actually return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function _hashVoucher(Voucher memory voucher) internal view returns (bytes32 voucherHash) {
        voucherHash = _hashTypedDataV4(keccak256(abi.encode(VOUCHER_TYPEHASH, voucher)));
    }

    /**
     * Validate the given voucher against the given signature, by the given signer
     *
     * @param voucher  The voucher to validate
     * @param signature  The associated voucher signature
     */
    function _validateVoucher(Voucher memory voucher, bytes memory signature) internal view {
        bytes32 voucherHash = _hashVoucher(voucher);
        require(SignatureChecker.isValidSignatureNow(_getSigner(voucher), voucherHash, signature), "Gateway: invalid voucher signature");
        require(block.timestamp <= voucher.deadline, "Gateway: expired deadline");
    }

    /**
     * Mark the given voucher hash as served, and emit the corresponding event
     *
     * @param voucher  The voucher hash to serve
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function _serveVoucher(Voucher memory voucher, bytes memory signature) internal {
        _validateVoucher(voucher, signature);

        bytes32 voucherHash = _hashVoucher(voucher);
        require(voucherServed[voucherHash] == false, "Gateway: voucher already served");
        voucherServed[voucherHash] = true;

        _getExecute(voucher)(voucher);

        emit VoucherServed(voucherHash, _msgSender());
    }
}
