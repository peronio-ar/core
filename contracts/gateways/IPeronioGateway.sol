// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PeQuantity, UsdcQuantity} from "../IPeronio.sol";

interface IPeronioGateway {
    /**
     * mint() voucher
     *
     * @custom:member from  The address from which to transfer USDC collateral
     * @custom:member to  The address to which minted PE tokens are transferred
     * @custom:member usdcAmount  The number of USDC tokens to provide as collateral
     * @custom:member minReceive  The minimum number of PE tokens to mint
     */
    struct MintVoucher {
        address from;
        address to;
        UsdcQuantity usdcAmount;
        PeQuantity minReceive;
    }

    /**
     * withdraw() voucher
     *
     * @custom:member from  The address from which to burn extracted PE tokens
     * @custom:member to  The address to which extracted USDC tokens are transferred
     * @custom:member peAmount  The number of PE tokens to burn
     */
    struct WithdrawVoucher {
        address from;
        address to;
        PeQuantity peAmount;
    }

    /**
     * Return the tag associated to the MintVoucher voucher itself
     *
     * @return  The tag associated to the MintVoucher voucher itself
     */
    function MINT_VOUCHER_TAG() external view returns (uint32);

    /**
     * Return the tag associated to the WithdrawVoucher voucher itself
     *
     * @return  The tag associated to the WithdrawVoucher voucher itself
     */
    function WITHDRAW_VOUCHER_TAG() external view returns (uint32);
}
