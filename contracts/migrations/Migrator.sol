// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {PeronioV1Wrapper} from "./old/PeronioV1Wrapper.sol";
import {IPeronioV1} from "./old/IPeronioV1.sol";
import {IPeronio} from "../IPeronio.sol";

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

// Interface
import {IMigrator} from "./IMigrator.sol";

contract Migrator is IMigrator {
    using PeronioV1Wrapper for IPeronioV1;

    // Peronio V1 Address
    address public immutable peronioV1Address;

    // Peronio V2 Address
    address public immutable peronioV2Address;

    /**
     * Construct a new Peronio migrator
     *
     * @param _peronioV1Address  The address of the old PE contract
     * @param _peronioV2Address  The address of the new PE contract
     */
    constructor(address _peronioV1Address, address _peronioV2Address) {
        // Peronio Addresses
        peronioV1Address = _peronioV1Address;
        peronioV2Address = _peronioV2Address;

        // Unlimited USDC Approve to Peronio V2 contract
        IERC20(IPeronioV1(_peronioV1Address).USDC_ADDRESS()).approve(_peronioV2Address, type(uint256).max);
    }

    /**
     * Retrieve the number of USDC tokens to withdraw from the old contract, and the number of OE tokens to mint on the new one
     *
     * @param amount  The number of PE tokens to withdraw from the old contract
     * @return usdc  The number of USDC tokens to withdraw from the old contract
     * @return pe  The number of PE tokens to mint on the new contract
     */
    function quote(uint256 amount) external view override returns (uint256 usdc, uint256 pe) {
        // Calculate USDC to be received by Peronio V1
        usdc = IPeronioV1(peronioV1Address).quoteOut(amount);

        // Calculate PE to be minted by Peronio V2
        pe = IPeronio(peronioV2Address).quoteIn(usdc);
    }

    /**
     * Migrate the given number of PE tokens from the old contract to the new one
     *
     * @param amount  The number of PE tokens to withdraw from the old contract
     * @return usdc  The number of USDC tokens withdrawn from the old contract
     * @return pe  The number of PE tokens minted on the new contract
     * @custom:emit  Migrated
     */
    function migrate(uint256 amount) external override returns (uint256 usdc, uint256 pe) {
        // Peronio V1 Contract Wrapper
        IPeronioV1 peronioV1 = IPeronioV1(peronioV1Address);
        // Peronio V2 Contract
        IPeronio peronioV2 = IPeronio(peronioV2Address);

        // Transfer PE V1 to this contract
        IERC20(peronioV1Address).transferFrom(msg.sender, address(this), amount);

        // Calculate USDC to be received by Peronio V1
        usdc = peronioV1.withdrawV2(address(this), amount);
        // Calculate PE to be minted by Peronio V2
        pe = peronioV2.mint(msg.sender, usdc, 1);

        // Emit Migrated event
        emit Migrated(block.timestamp, amount, usdc, pe);
    }
}
