// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-IERC20Permit.sol";

import {ERC20Gateway} from "./ERC20Gateway.sol";
import {IERC20PermitGateway} from "./IERC20PermitGateway.sol";

abstract contract ERC20PermitGateway is ERC20Gateway, IERC20PermitGateway {
    // Tag associated to the PermitVoucher
    uint32 public constant override PERMIT_VOUCHER_TAG =
        uint32(bytes4(keccak256(bytes("PermitVoucher{address,address,uint256,uint256,uint8,bytes32,bytes32}"))));

    /**
     * Build a new ERC20PermitGateway from the given token address and gateway name
     *
     * @param _token  Underlying ERC20 token
     * @param _name  The name to give the newly created gateway
     */
    constructor(address _token, string memory _name) ERC20Gateway(_token, _name) {
        _addHandler(PERMIT_VOUCHER_TAG, HandlerEntry({signer: _extractPermitVoucherSigner, execute: _executePermitVoucher}));
    }

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC20PermitGateway).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * Extract the signer from the given voucher
     *
     * @param voucher  Voucher to extract the signer of
     * @return signer  The voucher's signer
     */
    function _extractPermitVoucherSigner(Voucher memory voucher) private pure returns (address signer) {
        PermitVoucher memory decodedVoucher = abi.decode(voucher.payload, (PermitVoucher));
        signer = decodedVoucher.owner;
    }

    /**
     * Execute the given (already validated) voucher
     *
     * @param voucher  The voucher to execute
     */
    function _executePermitVoucher(Voucher memory voucher) private {
        _beforePermitWithVoucher(voucher);

        PermitVoucher memory decodedVoucher = abi.decode(voucher.payload, (PermitVoucher));
        IERC20Permit(token).permit(
            decodedVoucher.owner,
            decodedVoucher.spender,
            decodedVoucher.value,
            decodedVoucher.deadline,
            decodedVoucher.v,
            decodedVoucher.r,
            decodedVoucher.s
        );

        _afterPermitWithVoucher(voucher);
    }

    /**
     * Hook called before the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _beforePermitWithVoucher(Voucher memory voucher) internal virtual {}

    /**
     * Hook called after the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _afterPermitWithVoucher(Voucher memory voucher) internal virtual {}
}
