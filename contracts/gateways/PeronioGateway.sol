// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

import {ERC20PermitGateway} from "./ERC20PermitGateway.sol";
import {IPeronioGateway} from "./IPeronioGateway.sol";

import {IPeronio, PeQuantity, UsdcQuantity} from "../IPeronio.sol";

abstract contract PeronioGateway is ERC20PermitGateway, IPeronioGateway {
    // typehash associated to the mintWithVoucher() method
    uint32 public constant override MINT_VOUCHER_TAG = uint32(bytes4(keccak256(bytes("MintVoucher{address,address,uint256,uint256}"))));

    // typehash associated to the mintWithVoucher() method
    uint32 public constant override WITHDRAW_VOUCHER_TAG = uint32(bytes4(keccak256(bytes("WithdrawVoucher{address,address,uint256}"))));

    /**
     * Build a new PeronioGateway from the given token address and gateway name
     *
     * @param _token  Underlying ERC20 token
     * @param _name  The name to give the newly created gateway
     */
    constructor(address _token, string memory _name) ERC20PermitGateway(_token, _name) {
        _addHandler(MINT_VOUCHER_TAG, HandlerEntry({signer: _extractMintVoucherSigner, execute: _executeMintVoucher}));
        _addHandler(WITHDRAW_VOUCHER_TAG, HandlerEntry({signer: _extractWithdrawVoucherSigner, execute: _executeWithdrawVoucher}));
    }

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IPeronioGateway).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * Extract the signer from the given voucher
     *
     * @param voucher  Voucher to extract the signer of
     * @return signer  The voucher's signer
     */
    function _extractMintVoucherSigner(Voucher memory voucher) private pure returns (address signer) {
        MintVoucher memory decodedVoucher = abi.decode(voucher.payload, (MintVoucher));
        signer = decodedVoucher.from;
    }

    /**
     * Extract the signer from the given voucher
     *
     * @param voucher  Voucher to extract the signer of
     * @return signer  The voucher's signer
     */
    function _extractWithdrawVoucherSigner(Voucher memory voucher) private pure returns (address signer) {
        WithdrawVoucher memory decodedVoucher = abi.decode(voucher.payload, (WithdrawVoucher));
        signer = decodedVoucher.from;
    }

    /**
     * Execute the given (already validated) voucher
     *
     * @param voucher  The voucher to execute
     */
    function _executeMintVoucher(Voucher memory voucher) private {
        _beforeMintWithVoucher(voucher);

        MintVoucher memory decodedVoucher = abi.decode(voucher.payload, (MintVoucher));
        IERC20(IPeronio(token).usdcAddress()).transferFrom(decodedVoucher.from, address(this), decodedVoucher.usdcAmount);
        IPeronio(token).mint(decodedVoucher.to, UsdcQuantity.wrap(decodedVoucher.usdcAmount), PeQuantity.wrap(decodedVoucher.minReceive));

        _afterMintWithVoucher(voucher);
    }

    /**
     * Execute the given (already validated) voucher
     *
     * @param voucher  The voucher to execute
     */
    function _executeWithdrawVoucher(Voucher memory voucher) private {
        _beforeWithdrawWithVoucher(voucher);

        WithdrawVoucher memory decodedVoucher = abi.decode(voucher.payload, (WithdrawVoucher));
        IERC20(token).transferFrom(decodedVoucher.from, address(this), decodedVoucher.peAmount);
        IPeronio(token).withdraw(decodedVoucher.to, PeQuantity.wrap(decodedVoucher.peAmount));

        _afterWithdrawWithVoucher(voucher);
    }

    /**
     * Hook called before the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _beforeMintWithVoucher(Voucher memory voucher) virtual internal {}

    /**
     * Hook called after the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _afterMintWithVoucher(Voucher memory voucher) virtual internal {}

    /**
     * Hook called before the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _beforeWithdrawWithVoucher(Voucher memory voucher) virtual internal {}

    /**
     * Hook called after the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _afterWithdrawWithVoucher(Voucher memory voucher) virtual internal {}
}
