// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import { ERC20 } from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import { ERC20Burnable } from "@openzeppelin/contracts_latest/token/ERC20/extensions/ERC20Burnable.sol";

import { console } from "hardhat/console.sol";

contract ERC20Mock is ERC20Burnable {
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    constructor(string memory name, string memory symbol, uint amount) ERC20(name, symbol) {
        _mint(msg.sender, amount);
    }

    function mint(address account, uint256 amount) public {
        console.log('Minting', account, amount);
        _mint(account, amount);
    }
}
