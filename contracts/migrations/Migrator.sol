// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// OpenZeppelin imports
import {AccessControl} from "@openzeppelin/contracts_latest/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";

import {min, mulDiv, sqrt256} from "../Utils.sol";

import {IPeronioV1Wrapper} from "./old/IPeronioV1Wrapper.sol";
import {IPeronio} from "../IPeronio.sol";

// Needed for Babylonian square-root
import {sqrt256} from "../Utils.sol";

// Interface
import "./IMigrator.sol";

import {console} from "hardhat/console.sol";

contract Migrator is IMigrator, ReentrancyGuard {
    using SafeERC20 for IERC20;
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
        IPeronioV1Wrapper peronioV1 = IPeronioV1Wrapper(peronioV1Address);
        // Peronio V2 Contract
        IPeronio peronioV2 = IPeronio(peronioV2Address);

        // Calculate USDC to be received by Peronio V1
        usdc = peronioV1.quoteOut(amount);

        // Calculate PE to be minted by Peronio V2
        pe = peronioV2.quoteIn(usdc);
    }

    function migrate(uint256 amount) external override returns (uint256 usdc, uint256 pe) {
        // Peronio V1 Contract Wrapper
        IPeronioV1Wrapper peronioV1 = IPeronioV1Wrapper(peronioV1Address);
        // Peronio V2 Contract
        IPeronio peronioV2 = IPeronio(peronioV2Address);

        // Calculate USDC to be received by Peronio V1
        usdc = peronioV1.withdraw(address(this), amount);

        // Calculate PE to be minted by Peronio V2
        pe = peronioV2.mint(msg.sender, usdc, 1);
    }
}
