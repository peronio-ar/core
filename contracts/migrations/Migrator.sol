// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {PeronioV1Wrapper} from "./old/PeronioV1Wrapper.sol";
import {IPeronioV1} from "./old/IPeronioV1.sol";
import {IPeronio} from "../IPeronio.sol";

// Interface
import "./IMigrator.sol";

contract Migrator is IMigrator {
    using PeronioV1Wrapper for IPeronioV1;

    // Peronio V1 Wrapper Address
    address public immutable peronioV1Address;

    // Peronio V2 Wrapper Address
    address public immutable peronioV2Address;

    constructor(address _peronioV1Address, address _peronioV2Address) {
        // Peronio Addresses
        peronioV1Address = _peronioV1Address;
        peronioV2Address = _peronioV2Address;
    }

    function quote(uint256 amount) external view override returns (uint256 usdc, uint256 pe) {
        // Peronio V1 Contract Wrapper
        IPeronioV1 peronioV1 = IPeronioV1(peronioV1Address);
        // Peronio V2 Contract
        IPeronio peronioV2 = IPeronio(peronioV2Address);

        // Calculate USDC to be received by Peronio V1
        usdc = peronioV1.quoteOut(amount);

        // Calculate PE to be minted by Peronio V2
        pe = peronioV2.quoteIn(usdc);
    }

    function migrate(uint256 amount) external override returns (uint256 usdc, uint256 pe) {
        // Peronio V1 Contract Wrapper
        IPeronioV1 peronioV1 = IPeronioV1(peronioV1Address);
        // Peronio V2 Contract
        IPeronio peronioV2 = IPeronio(peronioV2Address);

        // Calculate USDC to be received by Peronio V1
        usdc = peronioV1.withdrawV2(address(this), amount);

        // Calculate PE to be minted by Peronio V2
        pe = peronioV2.mint(msg.sender, usdc, 1);
    }
}
