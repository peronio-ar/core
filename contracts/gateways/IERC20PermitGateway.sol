// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-IERC20Permit.sol";

import {IERC20Gateway} from "./IERC20Gateway.sol";

interface IERC20PermitGateway is IERC20Gateway {
    /**
     * permit() voucher
     *
     * @custom:member owner  The address of the owner of the funds
     * @custom:member spender  The address of the spender being permitted to move the funds
     * @custom:member value  The number of tokens to allow transfer of
     * @custom:member v  The permit's signature "v" value
     * @custom:member r  The permit's signature "r" value
     * @custom:member s  The permit's signature "s" value
     */
    struct PermitVoucher {
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /**
     * Return the tag associated to the PermitVoucher voucher itself
     *
     * @return  The tag associated to the PermitVoucher voucher itself
     */
    function PERMIT_VOUCHER_TAG() external view returns (uint32);
}
