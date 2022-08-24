// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {PeronioV1Wrapper} from "./old/PeronioV1Wrapper.sol";
import {IPeronioV1} from "./old/IPeronioV1.sol";
import {IPeronio} from "../IPeronio.sol";

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

// Interface
import "./IMigrator.sol";

contract Migrator is IMigrator {
    using PeronioV1Wrapper for IPeronioV1;

    // Peronio V1 Address
    address public immutable peronioV1Address;

    // Peronio V2 Address
    address public immutable peronioV2Address;

    // USDC Address
    address public immutable usdcAddress;

    constructor(
        address _peronioV1Address,
        address _peronioV2Address,
        address _usdcAddress
    ) {
        // Peronio Addresses
        peronioV1Address = _peronioV1Address;
        peronioV2Address = _peronioV2Address;

        // USDC Address
        usdcAddress = _usdcAddress;

        // Unlimited USDC Approve to Peronio V2 contract
        IERC20(_usdcAddress).approve(_peronioV2Address, type(uint256).max);
    }

    function quote(uint256 amount) external view override returns (uint256 usdc, uint256 pe) {
        // Calculate USDC to be received by Peronio V1
        usdc = IPeronioV1(peronioV1Address).quoteOut(amount);

        // Calculate PE to be minted by Peronio V2
        pe = IPeronio(peronioV2Address).quoteIn(usdc);
    }

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
