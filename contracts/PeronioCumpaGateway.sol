// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PeronioGateway} from "./gateways/PeronioGateway.sol";

contract PeronioCumpaGateway is PeronioGateway {
    address public immutable cumpaAddress;
    address public immutable peronioAddress;
    address public immutable usdcAddress;

    constructor(
        address _cumpaAddress,
        address _peronioAddress,
        address _usdcAddress
    ) PeronioGateway(_peronioAddress, "PeronioCumpaGateway") {
        cumpaAddress = _cumpaAddress;
        peronioAddress = _peronioAddress;
        usdcAddress = _usdcAddress;
    }

    uint256 private gasUsed;

    /**
     * Hook called before the actual mint() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforeMintWithVoucher(MintVoucher memory voucher) internal override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual mint() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterMintWithVoucher(MintVoucher memory voucher) internal override {
        gasUsed -= gasleft();
        // TODO
    }

    /**
     * Hook called before the actual withdraw() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforeWithdrawWithVoucher(WithdrawVoucher memory voucher) internal override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual withdraw() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterWithdrawWithVoucher(WithdrawVoucher memory voucher) internal override {
        gasUsed -= gasleft();
        // TODO
    }

    /**
     * Hook called before the actual permit() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforePermitWithVoucher(PermitVoucher memory voucher) internal override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual permit() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterPermitWithVoucher(PermitVoucher memory voucher) internal override {
        gasUsed -= gasleft();
        // TODO
    }

    /**
     * Hook called before the actual transferFrom() call is served
     *
     * @param voucher  The voucher being served
     */
    function _beforeTransferFromWithVoucher(TransferFromVoucher memory voucher) internal override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual transferFrom() call is served
     *
     * @param voucher  The voucher being served
     */
    function _afterTransferFromWithVoucher(TransferFromVoucher memory voucher) internal override {
        gasUsed -= gasleft();
        // TODO
    }
}
