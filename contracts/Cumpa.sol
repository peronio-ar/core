// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// OpenZeppelin imports
import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {ERC20} from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// Interfaces
import "./ICumpa.sol";
import "./IPeronio.sol";

string constant NAME = "Cumpa";
string constant SYMBOL = "CUM";
uint256 constant MINIMUM_PERIOD = 12 * 60 * 60;

contract Cumpa is Context, ICumpa, IERC20, ERC20Permit, ERC165 {

    IPeronio internal peronio;

    uint256 public lastExecuted;

    /**
     * Construct a new Cumpa contract
     *
     * @param _peronio  The Peronio contract to reap rewards for
     */
    constructor(address _peronio) ERC20(NAME, SYMBOL) ERC20Permit(NAME) {
        peronio = IPeronio(_peronio);
    }

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ICumpa).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * Reap Peronio rewards, and get CUMs in return
     *
     * @return cumpaAmount  Number of CUM tokens awarded
     */
    function reap() external override returns (CumpaQuantity cumpaAmount) {
        require(MINIMUM_PERIOD < block.timestamp - lastExecuted, "Cumpa: Time not elapsed");

        lastExecuted = block.timestamp;
        (, LpQuantity lpAmount) = peronio.compoundRewards();

        cumpaAmount = CumpaQuantity.wrap(LpQuantity.unwrap(lpAmount));

        _mint(_msgSender(), CumpaQuantity.unwrap(cumpaAmount));
    }
}
