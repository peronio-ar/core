// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-IERC20Permit.sol";

import {ERC20Gateway} from "./ERC20Gateway.sol";
import {IERC20PermitGateway} from "./IERC20PermitGateway.sol";

abstract contract ERC20PermitGateway is ERC20Gateway, IERC20PermitGateway {
    /**
     * Build a new ERC20PermitGateway from the given token address and gateway name
     *
     * @param _token  Underlying ERC20 token
     * @param _name  The name to give the newly created gateway
     */
    constructor(address _token, string memory _name) ERC20Gateway(_token, _name) {}

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC20Gateway, IERC165) returns (bool) {
        return interfaceId == type(IERC20PermitGateway).interfaceId || super.supportsInterface(interfaceId);
    }

    // --- permit ---------------------------------------------------------------------------------------------------------------------------------------------

    // typehash associated to the permitWithVoucher() method
    bytes32 public constant override PERMIT_WITH_VOUCHER_TYPEHASH =
        keccak256(bytes("permitWithVoucher(PermitVoucher{address,address,uint256,uint256,uint8,bytes32,bytes32,uint256,uint256,bytes})"));

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashPermitWithVoucher(PermitVoucher memory voucher) external view override returns (bytes32 voucherHash) {
        voucherHash = _hashPermitWithVoucher(voucher);
    }

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
    ) external view override {
        _validatePermitWithVoucher(voucher, signature, signer);
    }

    /**
     * Execute the permit() call to the underlying ERC20Permit token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function permitWithVoucher(PermitVoucher memory voucher, bytes memory signature) external override nonReentrant {
        _beforePermitWithVoucher(voucher);
        _permitWithVoucher(voucher, signature);
        _afterPermitWithVoucher(voucher);
    }

    // --- Protected interface --------------------------------------------------------------------------------------------------------------------------------

    /**
     * Actually return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function _hashPermitWithVoucher(PermitVoucher memory voucher) internal view returns (bytes32 voucherHash) {
        voucherHash = _hashTypedDataV4(keccak256(abi.encode(PERMIT_WITH_VOUCHER_TYPEHASH, voucher)));
    }

    /**
     * Actually validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function _validatePermitWithVoucher(
        PermitVoucher memory voucher,
        bytes memory signature,
        address signer
    ) internal view {
        _validateVoucher(_hashPermitWithVoucher(voucher), signature, signer);
    }

    /**
     * Actually execute the permit() call to the underlying ERC20Permit token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function _permitWithVoucher(PermitVoucher memory voucher, bytes memory signature) internal {
        require(block.timestamp <= voucher.voucherDeadline, string.concat(name, ": expired deadline"));

        bytes32 voucherHash = _hashPermitWithVoucher(voucher);
        _validateVoucher(voucherHash, signature, voucher.owner);
        _serveVoucher(voucherHash);

        IERC20Permit(token).permit(voucher.owner, voucher.spender, voucher.value, voucher.deadline, voucher.v, voucher.r, voucher.s);
    }

    /**
     * Hook called before the actual permit() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforePermitWithVoucher(PermitVoucher memory voucher) internal {}

    /**
     * Hook called after the actual permit() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterPermitWithVoucher(PermitVoucher memory voucher) internal {}
}
