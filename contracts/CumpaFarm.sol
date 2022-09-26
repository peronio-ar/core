// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";

import {Cumpa} from "./Cumpa.sol";
import {Peronio} from "./Peronio.sol";

contract Farm is ReentrancyGuard {
    Cumpa public cumpa; // Address of CUM token contract.
    Peronio public peronio;

    uint256 public rewardPerBlock;
    uint256 public lastRewardBlock; // Last block number that P distribution occurs.

    uint256 public accumulatedPeroniosPerShare; // Accumulated Ps per share, times 1e12.

    uint256 public paidOut;

    uint256 public startBlock;
    uint256 public endBlock;

    uint16 public depositFeeBP; // Deposit fee in basis points
    address public feeAddress;

    struct UserInfo {
        uint256 amount; // How many CUM tokens the user has provided.
        uint256 rewarded; // Reward debt. See explanation below.
    }

    mapping(address => UserInfo) public userInfo;

    constructor(
        Cumpa _cumpa,
        Peronio _peronio,
        uint256 _rewardPerBlock,
        uint256 _startBlock,
        uint16 _depositFeeBP,
        address _feeAddress
    ) {
        require(_depositFeeBP <= 10000, "Farm: invalid deposit fee basis points");

        cumpa = _cumpa;
        peronio = _peronio;

        rewardPerBlock = _rewardPerBlock;
        lastRewardBlock = Math.max(block.number, startBlock);

        startBlock = _startBlock;
        endBlock = _startBlock;

        depositFeeBP = _depositFeeBP;
        feeAddress = _feeAddress;
    }

    // Fund Ps
    function fund(uint256 amount) external {
        require(block.number < endBlock, "Farm: too late, the farm is closed");

        peronio.transferFrom(msg.sender, address(this), amount);
        endBlock += amount / rewardPerBlock;
    }

    function deposited(address _user) external view returns (uint256 amount) {
        amount = userInfo[_user].amount;
    }

    function pending(address _user) external view returns (uint256 amount) {
        UserInfo storage user = userInfo[_user];
        uint256 _accumulatedPeroniosPerShare = accumulatedPeroniosPerShare;
        uint256 cumpaSupply = cumpa.balanceOf(address(this));

        if (lastRewardBlock < block.number && cumpaSupply != 0) {
            uint256 lastBlock = Math.min(block.number, endBlock);
            uint256 peronioReward = (lastBlock - lastRewardBlock) * rewardPerBlock;
            _accumulatedPeroniosPerShare += (peronioReward * 1e12) / cumpaSupply;
        }

        amount = (user.amount * _accumulatedPeroniosPerShare) / 1e12 - user.rewarded;
    }

    function totalPending() external view returns (uint256 amount) {
        if (block.number <= startBlock) {
            return 0;
        }

        uint256 lastBlock = Math.min(block.number, endBlock);
        amount = rewardPerBlock * (lastBlock - startBlock) - paidOut;
    }

    function deposit(uint256 amount) public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];

        _transferRewards();

        if (0 < amount) {
            cumpa.transferFrom(msg.sender, address(this), amount);
            user.amount += amount;
            if (0 < depositFeeBP) {
                uint256 depositFee = (amount * depositFeeBP) / 10000;
                cumpa.transfer(feeAddress, depositFee);
                user.amount -= depositFee;
            }
        }
    }

    function withdraw(uint256 amount) public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        require(amount <= user.amount, "Farm: can't withdraw more than deposit");

        _transferRewards();

        user.amount -= amount;
        cumpa.transfer(msg.sender, amount);
    }

    function emergencyWithdraw() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        cumpa.transfer(msg.sender, user.amount);
        user.amount = 0;
        user.rewarded = 0;
    }

    function _transferRewards() internal {
        _updatePool();

        UserInfo storage user = userInfo[msg.sender];
        if (0 == user.amount) {
            return;
        }

        uint256 pendingAmount = (user.amount * accumulatedPeroniosPerShare) / 1e12 - user.rewarded;
        peronio.transfer(msg.sender, pendingAmount);
        user.rewarded += pendingAmount;
        paidOut += pendingAmount;
    }

    function _updatePool() internal {
        uint256 lastBlock = Math.min(block.number, endBlock);

        if (lastBlock <= lastRewardBlock) {
            return;
        }

        uint256 cumpaSupply = cumpa.balanceOf(address(this));
        if (cumpaSupply == 0) {
            lastRewardBlock = lastBlock;
            return;
        }

        uint256 peronioReward = (lastBlock - lastRewardBlock) * rewardPerBlock;
        accumulatedPeroniosPerShare += (peronioReward * 1e12) / cumpaSupply;

        lastRewardBlock = block.number;
    }
}
