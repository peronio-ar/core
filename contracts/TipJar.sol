// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";

import {IUniswapV2Router02} from "./uniswap/interfaces/IUniswapV2Router02.sol";

import {ITipJar} from "./ITipJar2.sol";

// Inspired by: https://raw.githubusercontent.com/0xlaozi/qidao/main/contracts/StakingRewards.sol
contract TipJar is ITipJar, ReentrancyGuard {
    address public immutable override stakingToken;
    address public immutable override tipsToken;

    uint256 public override tipsLeftToDeal;
    uint256 public override tipsDealtPerBlock;
    uint256 public override lastTipDealBlock;

    uint256 public override accumulatedTipsPerShare;  // Accumulated tips per share, times 1e12.

    uint16 public override depositFeeBP;  // Deposit fee in basis points
    address public override feeAddress;

    mapping(address => uint256) public override stakedAmount;
    mapping(address => uint256) public override tipsPaidOut;
    mapping(address => uint256) public override tipsPending;

    uint256 private tipsIn;
    uint256 private tipsOut;

    uint256 private stakesIn;
    uint256 private stakesOut;

    address public immutable override quickSwapRouterAddress;

    constructor(
        address _stakingToken,
        address _tipsToken,
        uint256 _tipsDealtPerBlock,
        uint16 _depositFeeBP,
        address _feeAddress,
        address _quickSwapRouterAddress
    ) {
        require(_depositFeeBP <= 10000, "TipJar: invalid deposit fee basis points");

        (stakingToken, tipsToken) = (_stakingToken, _tipsToken);

        tipsDealtPerBlock = _tipsDealtPerBlock;
        lastTipDealBlock = block.number;

        depositFeeBP = _depositFeeBP;
        feeAddress = _feeAddress;

        quickSwapRouterAddress = _quickSwapRouterAddress;
        IERC20(stakingToken).approve(quickSwapRouterAddress, type(uint256).max);
    }

    function pendingTipsToPayOut(address user) external view override returns (uint256 pendingAmount) {
        pendingAmount = _pendingTipsToPayOut(user);
    }

    function tip(uint256 amount) external override nonReentrant returns (uint256 _tipsLeftToDeal) {
        _tipsLeftToDeal = _tip(amount, msg.sender);
    }

    function tip(address from, uint256 amount) external override nonReentrant returns (uint256 _tipsLeftToDeal) {
        _tipsLeftToDeal = _tip(amount, from);
    }

    function stake(uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _stake(amount, msg.sender);
    }

    function stake(address from, uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _stake(amount, from);
    }

    function unstake(uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(msg.sender, amount, msg.sender);
    }

    function unstake(uint256 amount, address to) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(msg.sender, amount, to);
    }

    function withdrawTips() external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(msg.sender, _pendingTipsToPayOut(msg.sender), msg.sender);
    }

    function withdrawTips(address to) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(msg.sender, _pendingTipsToPayOut(msg.sender), to);
    }

    function withdrawTips(uint256 amount) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(msg.sender, amount, msg.sender);
    }

    function withdrawTips(uint256 amount, address to) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(msg.sender, amount, to);
    }

    function scrub() external override nonReentrant returns (uint256 tipsAdjustment, uint256 stakesAdjustment) {
        (tipsAdjustment, stakesAdjustment) = _scrub();
    }

    function _pendingTipsToPayOut(address user) internal view returns (uint256 pendingAmount) {
        require(lastTipDealBlock <= block.number, "TipJar: last tip deal block in the future");

        uint256 _accumulatedTipsPerShare = accumulatedTipsPerShare;
        uint256 stakeSupply = stakesIn - stakesOut;
        if (stakeSupply != 0) {
            _accumulatedTipsPerShare += Math.min(tipsLeftToDeal, (block.number - lastTipDealBlock) * tipsDealtPerBlock) / stakeSupply;
        }

        uint256 userStakedAmount = stakedAmount[user];
        if (userStakedAmount != 0) {
            pendingAmount = tipsPending[user] + userStakedAmount * _accumulatedTipsPerShare - tipsPaidOut[user];
        }
    }

    function _tip(uint256 amount, address from) internal returns (uint256 _tipsLeftToDeal) {
        _dealTips(from);

        _transferTipIn(from, amount);

        tipsLeftToDeal += amount;
        _tipsLeftToDeal = tipsLeftToDeal;

        emit TipReceived(amount, from);
    }

    function _stake(uint256 amount, address from) internal returns (uint256 _stakedAmount) {
        _dealTips(from);

        if (0 < amount) {
            _transferStakeIn(from, amount);

            stakedAmount[from] += amount;

            if (0 < depositFeeBP) {
                uint256 depositFee = (amount * depositFeeBP) / 10000;
                _transferStakeOut(feeAddress, depositFee);
                stakedAmount[from] -= depositFee;
            }
        }

        _stakedAmount = stakedAmount[from];

        emit StakeIncreased(amount, from);
    }

    function _unstake(address from, uint256 amount, address to) internal returns (uint256 _stakedAmount) {
        require(amount <= stakedAmount[from], "TipJar: can't withdraw more than staked amount");

        _dealTips(to);

        _transferStakeOut(to, amount);

        stakedAmount[from] -= amount;
        _stakedAmount = stakedAmount[from];

        emit StakeDecreased(amount, from);
    }

    function _withdrawTips(address from, uint256 amount, address to) internal returns (uint256 _extractedAmount) {
        _dealTips(from);

        require(amount <= tipsPending[from], "TipJar: can't extract more than pending amount");

        _transferTipOut(to, amount);

        tipsPending[from] -= amount;
        tipsPaidOut[from] += amount;

        _extractedAmount = amount;
    }

    function _scrub() internal returns (uint256 tipsAdjustment, uint256 stakesAdjustment) {
        uint256 tipsInToken = IERC20(tipsToken).balanceOf(address(this));
        require(tipsInToken <= tipsIn - tipsOut, "TipJar: tip balance leak detected, aborting!");

        tipsAdjustment = tipsInToken - (tipsIn - tipsOut);
        if (tipsAdjustment != 0) {
            tipsLeftToDeal += tipsAdjustment;
            tipsIn += tipsAdjustment;
        }

        uint256 stakesInToken = IERC20(stakingToken).balanceOf(address(this));
        require(stakesInToken <= stakesIn - stakesOut, "TipJar: stakes balance leak detected, aborting!");

        stakesAdjustment = stakesInToken - (stakesIn - stakesOut);
        if (stakesAdjustment != 0) {
            address[] memory path = new address[](2);
            (path[0], path[1]) = (stakingToken, tipsToken);
            uint256 swappedAmount = IUniswapV2Router02(quickSwapRouterAddress).swapExactTokensForTokens(stakesAdjustment, 1, path, address(this), block.timestamp + 1 hours)[1];
            tipsLeftToDeal += swappedAmount;
            tipsIn += swappedAmount;
        }

        if (tipsAdjustment != 0 || stakesAdjustment != 0) {
            emit Scrubbed(tipsAdjustment, stakesAdjustment);
        }
    }

    function _dealTips(address user) internal {
        require(lastTipDealBlock <= block.number, "TipJar: last tip deal block in the future");

        uint256 stakeSupply = stakesIn - stakesOut;
        if (stakeSupply != 0) {
            uint256 tipsToDistribute = Math.min(tipsLeftToDeal, (block.number - lastTipDealBlock) * tipsDealtPerBlock);
            accumulatedTipsPerShare += tipsToDistribute / stakeSupply;
            tipsLeftToDeal -= tipsToDistribute;
            lastTipDealBlock = block.number;
        }

        uint256 userStakedAmount = stakedAmount[user];
        if (userStakedAmount != 0) {
            tipsPending[user] += userStakedAmount * accumulatedTipsPerShare - tipsPaidOut[user];
        }
    }

    function _transferTipIn(address from, uint256 amount) internal {
        IERC20(tipsToken).transferFrom(from, address(this), amount);
        tipsIn += amount;
    }

    function _transferTipOut(address to, uint256 amount) internal {
        IERC20(tipsToken).transfer(to, amount);
        tipsOut += amount;
    }

    function _transferStakeIn(address from, uint256 amount) internal {
        IERC20(stakingToken).transferFrom(from, address(this), amount);
        stakesIn += amount;
    }

    function _transferStakeOut(address to, uint256 amount) internal {
        IERC20(stakingToken).transfer(to, amount);
        stakesOut += amount;
    }
}
