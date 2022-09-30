// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {EIP712} from "@openzeppelin/contracts_latest/utils/cryptography/draft-EIP712.sol";

import {Gateway} from "./Gateway.sol";
import {IERC20Gateway} from "./IERC20Gateway.sol";

abstract contract ERC20Gateway is Gateway, IERC20Gateway {
    // address of the underlying ERC20 token
    address public immutable override token;
    // generated name of gateway proper
    string public override name;

    // Tag associated to the TransferFromVoucher
    uint32 public constant TRANSFER_FROM_VOUCHER_TAG = uint32(bytes4(keccak256(bytes("TransferFromVoucher{address,address,uint256}"))));

    /**
     * Build a new ERC20Gateway from the given token address and gateway name
     *
     * @param _token  Underlying ERC20 token
     * @param _name  The name to give the newly created gateway
     */
    constructor(address _token, string memory _name) EIP712(_name, "1") {
        token = _token;
        name = _name;
        _addHandler(TRANSFER_FROM_VOUCHER_TAG, HandlerEntry({signer: _extractTransferFromVoucherSigner, execute: _executeTransferFromVoucher}));
    }

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(Gateway) returns (bool) {
        return interfaceId == type(IERC20Gateway).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * Extract the signer from the given voucher
     *
     * @param voucher  Voucher to extract the signer of
     * @return signer  The voucher's signer
     */
    function _extractTransferFromVoucherSigner(Voucher memory voucher) private pure returns (address signer) {
        TransferFromVoucher memory decodedVoucher = abi.decode(voucher.payload, (TransferFromVoucher));
        signer = decodedVoucher.from;
    }

    /**
     * Execute the given (already validated) voucher
     *
     * @param voucher  The voucher to execute
     */
    function _executeTransferFromVoucher(Voucher memory voucher) private {
        _beforeTransferFromWithVoucher(voucher);

        TransferFromVoucher memory decodedVoucher = abi.decode(voucher.payload, (TransferFromVoucher));
        IERC20(token).transferFrom(decodedVoucher.from, decodedVoucher.to, decodedVoucher.amount);

        _afterTransferFromWithVoucher(voucher);
    }

    /**
     * Hook called before the actual transferFrom() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _beforeTransferFromWithVoucher(Voucher memory voucher) virtual internal {}

    /**
     * Hook called after the actual transferFrom() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _afterTransferFromWithVoucher(Voucher memory voucher) virtual internal {}
}
