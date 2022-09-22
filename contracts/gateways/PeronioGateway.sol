// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {ERC20PermitGateway} from "./ERC20PermitGateway.sol";
import {IPeronioGateway} from "./IPeronioGateway.sol";

import {IPeronio, PeQuantity, UsdcQuantity} from "../IPeronio.sol";

abstract contract PeronioGateway is ERC20PermitGateway, IPeronioGateway {
    /**
     * Build a new PeronioGateway from the given token address and gateway name
     *
     * @param _token  Underlying ERC20 token
     * @param _name  The name to give the newly created gateway
     */
    constructor(address _token, string memory _name) ERC20PermitGateway(_token, _name) {}

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC20PermitGateway, IERC165) returns (bool) {
        return interfaceId == type(IPeronioGateway).interfaceId || super.supportsInterface(interfaceId);
    }

    // --- mint -----------------------------------------------------------------------------------------------------------------------------------------------

    // typehash associated to the mintWithVoucher() method
    bytes32 public constant override MINT_WITH_VOUCHER_TYPEHASH =
        keccak256(bytes("mintWithVoucher(MintVoucher{address,address,uint256,uint256,uint256,uint256,bytes})"));

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashMintWithVoucher(MintVoucher memory voucher) external view override returns (bytes32 voucherHash) {
        voucherHash = _hashMintWithVoucher(voucher);
    }

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
    ) external view override {
        _validateMintWithVoucher(voucher, signature, signer);
    }

    /**
     * Execute the mint() call to the underlying Peronio token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function mintWithVoucher(MintVoucher memory voucher, bytes memory signature) external override nonReentrant {
        _beforeMintWithVoucher(voucher);
        _mintWithVoucher(voucher, signature);
        _afterMintWithVoucher(voucher);
    }

    // --- withdraw -------------------------------------------------------------------------------------------------------------------------------------------

    // typehash associated to the mintWithVoucher() method
    bytes32 public constant override WITHDRAW_WITH_VOUCHER_TYPEHASH =
        keccak256(bytes("withdrawWithVoucher(WithdrawVoucher{address,address,uint256,uint256,uint256,bytes})"));

    /**
     * Return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function hashWithdrawWithVoucher(WithdrawVoucher memory voucher) external view override returns (bytes32 voucherHash) {
        voucherHash = _hashWithdrawWithVoucher(voucher);
    }

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
    ) external view override {
        _validateWithdrawWithVoucher(voucher, signature, signer);
    }

    /**
     * Execute the withdraw() call to the underlying Peronio token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function withdrawWithVoucher(WithdrawVoucher memory voucher, bytes memory signature) external override nonReentrant {
        _beforeWithdrawWithVoucher(voucher);
        _withdrawWithVoucher(voucher, signature);
        _afterWithdrawWithVoucher(voucher);
    }

    // --- Protected interface --------------------------------------------------------------------------------------------------------------------------------

    /**
     * Actually return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function _hashMintWithVoucher(MintVoucher memory voucher) internal view returns (bytes32 voucherHash) {
        voucherHash = _hashTypedDataV4(keccak256(abi.encode(MINT_WITH_VOUCHER_TYPEHASH, voucher)));
    }

    /**
     * Actually validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function _validateMintWithVoucher(
        MintVoucher memory voucher,
        bytes memory signature,
        address signer
    ) internal view {
        _validateVoucher(_hashMintWithVoucher(voucher), signature, signer);
    }

    /**
     * Actually execute the mint() call to the underlying Peronio token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function _mintWithVoucher(MintVoucher memory voucher, bytes memory signature) internal {
        require(block.timestamp <= voucher.voucherDeadline, string.concat(name, ": expired deadline"));

        bytes32 voucherHash = _hashMintWithVoucher(voucher);
        _validateVoucher(voucherHash, signature, voucher.from);
        _serveVoucher(voucherHash);

        IPeronio(token).mint(voucher.to, UsdcQuantity.wrap(voucher.usdcAmount), PeQuantity.wrap(voucher.minReceive));
    }

    /**
     * Hook called before the actual mint() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforeMintWithVoucher(MintVoucher memory voucher) internal {}

    /**
     * Hook called after the actual mint() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterMintWithVoucher(MintVoucher memory voucher) internal {}

    /**
     * Actually return the voucher hash associated to the given voucher
     *
     * @param voucher  The voucher to retrieve the hash for
     * @return voucherHash  The voucher hash associated to the given voucher
     */
    function _hashWithdrawWithVoucher(WithdrawVoucher memory voucher) internal view returns (bytes32 voucherHash) {
        voucherHash = _hashTypedDataV4(keccak256(abi.encode(WITHDRAW_WITH_VOUCHER_TYPEHASH, voucher)));
    }

    /**
     * Actually validate the given voucher and signature, against the given signer
     *
     * @param voucher  Voucher to validate
     * @param signature  The associated voucher signature
     * @param signer  The address signing the voucher
     */
    function _validateWithdrawWithVoucher(
        WithdrawVoucher memory voucher,
        bytes memory signature,
        address signer
    ) internal view {
        _validateVoucher(_hashWithdrawWithVoucher(voucher), signature, signer);
    }

    /**
     * Actually execute the withdraw() call to the underlying Peronio token with the parameters in the given voucher
     *
     * @param voucher  The voucher to execute
     * @param signature  The associated voucher signature
     * @custom:emit  VoucherServed
     */
    function _withdrawWithVoucher(WithdrawVoucher memory voucher, bytes memory signature) internal {
        require(block.timestamp <= voucher.voucherDeadline, string.concat(name, ": expired deadline"));

        bytes32 voucherHash = _hashWithdrawWithVoucher(voucher);
        _validateVoucher(voucherHash, signature, voucher.from);
        _serveVoucher(voucherHash);

        IPeronio(token).withdraw(voucher.to, PeQuantity.wrap(voucher.peAmount));
    }

    /**
     * Hook called before the actual withdraw() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforeWithdrawWithVoucher(WithdrawVoucher memory voucher) internal {}

    /**
     * Hook called after the actual withdraw() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterWithdrawWithVoucher(WithdrawVoucher memory voucher) internal {}
}
