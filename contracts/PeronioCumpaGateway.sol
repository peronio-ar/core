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
     * Hook called before the actual mint() call is executed
     *
     */
    function _beforeMintWithVoucher(Voucher memory) internal virtual override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual mint() call is executed
     *
     */
    function _afterMintWithVoucher(Voucher memory) internal virtual override {
        gasUsed -= gasleft();
        // TODO
    }

    /**
     * Hook called before the actual withdraw() call is executed
     *
     */
    function _beforeWithdrawWithVoucher(Voucher memory) internal virtual override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual withdraw() call is executed
     *
     */
    function _afterWithdrawWithVoucher(Voucher memory) internal virtual override {
        gasUsed -= gasleft();
        // TODO
    }

    /**
     * Hook called before the actual permit() call is executed
     *
     */
    function _beforePermitWithVoucher(Voucher memory) internal virtual override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual permit() call is executed
     *
     */
    function _afterPermitWithVoucher(Voucher memory) internal virtual override {
        gasUsed -= gasleft();
        // TODO
    }

    /**
     * Hook called before the actual transferFrom() call is executed
     *
     */
    function _beforeTransferFromWithVoucher(Voucher memory) internal virtual override {
        require(gasUsed == 0, "PeronioCumpaGateway: gas already used");
        gasUsed = gasleft();
        // TODO
    }

    /**
     * Hook called after the actual transferFrom() call is executed
     *
     */
    function _afterTransferFromWithVoucher(Voucher memory) internal virtual override {
        gasUsed -= gasleft();
        // TODO
    }
}
