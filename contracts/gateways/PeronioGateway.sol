// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {IPeronioGateway} from "./IPeronioGateway.sol";

import {IPeronio, PeQuantity, UsdcQuantity} from "../IPeronio.sol";

// ------------------------------------------------------------------------------------------------
// --- BEGIN REMOVE -------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------
struct Voucher {
    bytes payload;
}
struct HandlerEntry {
    function(Voucher memory) view returns (string memory) message;
    function(Voucher memory) view returns (address) signer;
    function(Voucher memory) execute;
}

function _addHandler(uint32, HandlerEntry memory) {}

function toString(address) pure returns (string memory) {
    return "";
}

function toString(uint256, uint8) pure returns (string memory) {
    return "";
}

// ------------------------------------------------------------------------------------------------
// --- END REMOVE ---------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------

abstract contract PeronioGateway is IPeronioGateway {
    // typehash associated to the mintWithVoucher() method
    uint32 public constant override MINT_VOUCHER_TAG = uint32(bytes4(keccak256("MintVoucher(address from,address to,uint256 usdcAmount,uint256 minReceive)")));

    // typehash associated to the mintWithVoucher() method
    uint32 public constant override WITHDRAW_VOUCHER_TAG = uint32(bytes4(keccak256("WithdrawVoucher(address from,address to,uint256 peAmount)")));

    // address of the Peronio contract
    address public immutable peronio;

    // symbol used for Peronio tokens
    string internal peSymbol;

    // symbol used for USDC tokens
    string internal usdcSymbol;

    // number of decimals used for Peronio tokens
    uint8 internal peDecimals;

    // number of decimals used for USDC tokens
    uint8 internal usdcDecimals;

    /**
     * Build a new PeronioGateway from the given Peronio address
     *
     * @param _peronio  Peronio address to use
     */
    constructor(address _peronio) {
        peronio = _peronio;

        IERC20Metadata peMetadata = IERC20Metadata(peronio);
        IERC20Metadata usdcMetadata = IERC20Metadata(IPeronio(peronio).usdcAddress());

        (peSymbol, peDecimals) = (peMetadata.symbol(), peMetadata.decimals());
        (usdcSymbol, usdcDecimals) = (usdcMetadata.symbol(), usdcMetadata.decimals());

        _addHandler(MINT_VOUCHER_TAG, HandlerEntry({message: _generateMintVoucherMessage, signer: _extractMintVoucherSigner, execute: _executeMintVoucher}));
        _addHandler(
            WITHDRAW_VOUCHER_TAG,
            HandlerEntry({message: _generateWithdrawVoucherMessage, signer: _extractWithdrawVoucherSigner, execute: _executeWithdrawVoucher})
        );
    }

    // --------------------------------------------------------------------------------------------
    // --- BEGIN UNCOMMENT ------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------------
    // /**
    //  * Implementation of the IERC165 interface
    //  *
    //  * @param interfaceId  Interface ID to check against
    //  * @return  Whether the provided interface ID is supported
    //  */
    // function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
    //     return interfaceId == type(IPeronioGateway).interfaceId || super.supportsInterface(interfaceId);
    // }
    // --------------------------------------------------------------------------------------------
    // --- END UNCOMMENT --------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------------

    /**
     * Generate the user-readable message from the given voucher
     *
     * @param voucher  Voucher to generate the user-readable message of
     * @return message  The voucher's generated user-readable message
     */
    function _generateMintVoucherMessage(Voucher memory voucher) internal view returns (string memory message) {
        MintVoucher memory decodedVoucher = abi.decode(voucher.payload, (MintVoucher));
        message = string.concat(
            "Mint",
            "\n",
            "from: ",
            toString(decodedVoucher.from),
            "\n",
            "to: ",
            toString(decodedVoucher.to),
            "\n",
            "usdcAmount: ",
            usdcSymbol,
            " ",
            toString(UsdcQuantity.unwrap(decodedVoucher.usdcAmount), usdcDecimals),
            "\n",
            "minReceive: ",
            peSymbol,
            " ",
            toString(PeQuantity.unwrap(decodedVoucher.minReceive), peDecimals),
            "\n"
        );
    }

    /**
     * Generate the user-readable message from the given voucher
     *
     * @param voucher  Voucher to generate the user-readable message of
     * @return message  The voucher's generated user-readable message
     */
    function _generateWithdrawVoucherMessage(Voucher memory voucher) internal view returns (string memory message) {
        WithdrawVoucher memory decodedVoucher = abi.decode(voucher.payload, (WithdrawVoucher));
        message = string.concat(
            "Withdraw",
            "\n",
            "from: ",
            toString(decodedVoucher.from),
            "\n",
            "to: ",
            toString(decodedVoucher.to),
            "\n",
            "peAmount: ",
            peSymbol,
            " ",
            toString(PeQuantity.unwrap(decodedVoucher.peAmount), peDecimals),
            "\n"
        );
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
        IERC20(IPeronio(peronio).usdcAddress()).transferFrom(decodedVoucher.from, address(this), UsdcQuantity.unwrap(decodedVoucher.usdcAmount));
        IPeronio(peronio).mint(decodedVoucher.to, decodedVoucher.usdcAmount, decodedVoucher.minReceive);

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
        IERC20(peronio).transferFrom(decodedVoucher.from, address(this), PeQuantity.unwrap(decodedVoucher.peAmount));
        IPeronio(peronio).withdraw(decodedVoucher.to, decodedVoucher.peAmount);

        _afterWithdrawWithVoucher(voucher);
    }

    /**
     * Hook called before the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _beforeMintWithVoucher(Voucher memory voucher) internal virtual {}

    /**
     * Hook called after the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _afterMintWithVoucher(Voucher memory voucher) internal virtual {}

    /**
     * Hook called before the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _beforeWithdrawWithVoucher(Voucher memory voucher) internal virtual {}

    /**
     * Hook called after the actual permit() call is executed
     *
     * @param voucher  The voucher being executed
     */
    function _afterWithdrawWithVoucher(Voucher memory voucher) internal virtual {}
}
