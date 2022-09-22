// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// OpenZeppelin imports
import {AccessControl} from "@openzeppelin/contracts_latest/access/AccessControl.sol";
import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {ERC20} from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-ERC20Permit.sol";

// Interfaces
import "./ICumpa.sol";
import "./IPeronio.sol";

string constant NAME = "Cumpa";
string constant SYMBOL = "CUM";
uint256 constant MINIMUM_PERIOD = 12 hours;

contract Cumpa is AccessControl, ICumpa, ERC20, ERC20Permit {
    // Roles
    bytes32 public constant override MINTER_ROLE = keccak256("MINTER_ROLE");

    address public peronio;

    modifier onlyMinterRole() {
        _checkRole(MINTER_ROLE);
        _;
    }

    /**
     * Construct a new Cumpa contract
     *
     * @param _peronio  The Peronio contract to reap rewards for
     */
    constructor(address _peronio) ERC20(NAME, SYMBOL) ERC20Permit(NAME) {
        peronio = _peronio;

        _setupRole(MINTER_ROLE, _msgSender());
    }

    /**
     * Expose ERC20's _mint() function
     *
     * @param to  Address to mint the CUM tokens to
     * @param amount  Number of CUM tokens to mint
     */
    function mint(address to, uint256 amount) external onlyMinterRole {
        _mint(to, amount);
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
     * Compound Peronio rewards, and get CUMs in return
     *
     * @return cumpaAmount  Number of CUM tokens awarded
     */
    function compoundRewards() external override returns (CumpaQuantity cumpaAmount) {
        (, LpQuantity lpAmount) = IPeronio(peronio).compoundRewards();

        cumpaAmount = CumpaQuantity.wrap(LpQuantity.unwrap(lpAmount));

        // TODO: determine factor
        _mint(_msgSender(), CumpaQuantity.unwrap(cumpaAmount));
    }
}
