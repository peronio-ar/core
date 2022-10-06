// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";

import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";
import {Multicall} from "@openzeppelin/contracts_latest/utils/Multicall.sol";

import {IUniswapV2Router02} from "./uniswap/interfaces/IUniswapV2Router02.sol";

import {ITipJar} from "./ITipJar.sol";

/**
 * This contract implements a Tip Jar, distributing the tipping tokens accumulated amongst the participants in proportion to each's staking tokens staked.
 *
 * This implementation is inspired by https://raw.githubusercontent.com/0xlaozi/qidao/main/contracts/StakingRewards.sol, but it has been
 * thoroughly modified thus:
 *   - a pre-existing bug has been fixed: this could allow for incorrect amounts being awarded both in excess and deficiency
 *   - the farm can be re-started when its funds are exhausted upon re-funding with more tips (this is so that newly acquired tips can be put to use immediately)
 *   - tips are not transferred eagerly, but rather need to be withdrawn explicitly (this is so that individual transactions need not be performed each time)
 *   - tips can be directed to an address of one's choice (this is so as to avoid a subsequent transfer therein)
 *   - mechanisms have been added so as to prevent funds transferred outside of the "prescribed" interfaces to be lost (this is implemented via "scrubbing")
 *
 */
contract TipJar is Context, ITipJar, Multicall, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // The address of the token to use for staking
    address public immutable override stakingToken;

    // The number of staking tokens entered into the contract via the defined interfaces herein
    uint256 private stakesIn;

    // The number of staking tokens withdrawn from the contract via the defined interfaces herein
    uint256 private stakesOut;

    // The address of the token to use for tips accumulation and distribution
    address public immutable override tippingToken;

    // The number of tipping tokens entered into the contract via the defined interfaces herein
    uint256 private tipsIn;

    // The number of tipping tokens withdrawn from the contract via the defined interfaces herein
    uint256 private tipsOut;

    // Number of tip tokens dealt each block
    uint256 public override tipsDealtPerBlock;

    // Last block number on which an actual tip dealing took place
    uint256 public override lastTipDealBlock;

    // Number of tip tokens assigned so far per staking share
    uint256 public override accumulatedTipsPerShare; // times 1e12.

    // Number of tip tokens yet to be dealt
    uint256 public override tipsLeftToDeal;

    // Number of staking tokens belonging to a given user
    mapping(address => uint256) public override stakedAmount;

    // Number of tipping tokens paid out and withdrawn by a given user
    mapping(address => uint256) public override tipsPaidOut;

    // Number of tipping tokens dealt but not yet paid out to a given user
    mapping(address => uint256) public override tipsPending;

    // The address of the QuickSwap router used for converting scrubbed staking tokens to tipping tokens
    address public immutable override quickSwapRouterAddress;

    // The deposit fee exerted on staking
    uint16 public override depositFeeBP; // Deposit fee in basis points

    // The address to which
    address public override feeAddress;

    constructor(
        address _stakingToken,
        address _tippingToken,
        uint256 _tipsDealtPerBlock,
        uint16 _depositFeeBP,
        address _feeAddress,
        address _quickSwapRouterAddress
    ) {
        require(_depositFeeBP <= 10000, "TipJar: invalid deposit fee basis points");

        (stakingToken, tippingToken) = (_stakingToken, _tippingToken);

        tipsDealtPerBlock = _tipsDealtPerBlock;
        lastTipDealBlock = block.number;

        quickSwapRouterAddress = _quickSwapRouterAddress;
        IERC20(stakingToken).safeApprove(quickSwapRouterAddress, type(uint256).max);

        depositFeeBP = _depositFeeBP;
        feeAddress = _feeAddress;
    }

    function pendingTipsToPayOut(address user) external view override returns (uint256 pendingAmount) {
        pendingAmount = _pendingTipsToPayOut(user);
    }

    function tip(uint256 amount) external override nonReentrant returns (uint256 _tipsLeftToDeal) {
        _tipsLeftToDeal = _tip(_msgSender(), amount);
    }

    function tip(address from, uint256 amount) external override nonReentrant returns (uint256 _tipsLeftToDeal) {
        _tipsLeftToDeal = _tip(from, amount);
    }

    function stake(uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _stake(_msgSender(), amount);
    }

    function stake(address from, uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _stake(from, amount);
    }

    function unstake(uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(_msgSender(), amount, _msgSender());
    }

    function unstake(uint256 amount, address to) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(_msgSender(), amount, to);
    }

    function withdrawTips() external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(_msgSender(), _pendingTipsToPayOut(_msgSender()), _msgSender());
    }

    function withdrawTips(address to) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(_msgSender(), _pendingTipsToPayOut(_msgSender()), to);
    }

    function withdrawTips(uint256 amount) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(_msgSender(), amount, _msgSender());
    }

    function withdrawTips(uint256 amount, address to) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(_msgSender(), amount, to);
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

    function _tip(address from, uint256 amount) internal returns (uint256 _tipsLeftToDeal) {
        _dealTips(from);

        _transferTipIn(from, amount);

        _tipsLeftToDeal = tipsLeftToDeal += amount;

        emit TipReceived(amount, from);
    }

    function _stake(address from, uint256 amount) internal returns (uint256 _stakedAmount) {
        _dealTips(from);

        if (0 < amount) {
            _transferStakeIn(from, amount);

            stakedAmount[from] += amount;

            if (0 < depositFeeBP) {
                uint256 depositFee = (amount * depositFeeBP) / 10000;
                _transferStakeOut(depositFee, feeAddress);
                stakedAmount[from] -= depositFee;
            }
        }

        _stakedAmount = stakedAmount[from];

        emit StakeIncreased(amount, from);
    }

    function _unstake(
        address from,
        uint256 amount,
        address to
    ) internal returns (uint256 _stakedAmount) {
        require(amount <= stakedAmount[from], "TipJar: can't withdraw more than staked amount");

        _dealTips(to);

        _transferStakeOut(amount, to);

        _stakedAmount = stakedAmount[from] -= amount;

        emit StakeDecreased(amount, from);
    }

    function _withdrawTips(
        address from,
        uint256 amount,
        address to
    ) internal returns (uint256 _extractedAmount) {
        _dealTips(from);

        require(amount <= tipsPending[from], "TipJar: can't extract more than pending amount");

        _transferTipOut(amount, to);

        tipsPending[from] -= amount;
        tipsPaidOut[from] += amount;

        _extractedAmount = amount;
    }

    function _scrub() internal returns (uint256 tipsAdjustment, uint256 stakesAdjustment) {
        {
            uint256 tipsInToken = IERC20(tippingToken).balanceOf(address(this));
            require(tipsInToken <= tipsIn - tipsOut, "TipJar: tip balance leak detected, aborting!");

            tipsAdjustment = tipsInToken - (tipsIn - tipsOut);
            if (tipsAdjustment != 0) {
                tipsLeftToDeal += tipsAdjustment;
                tipsIn += tipsAdjustment;
            }
        }

        {
            uint256 stakesInToken = IERC20(stakingToken).balanceOf(address(this));
            require(stakesInToken <= stakesIn - stakesOut, "TipJar: stakes balance leak detected, aborting!");

            stakesAdjustment = stakesInToken - (stakesIn - stakesOut);
            if (stakesAdjustment != 0) {
                uint256 convertedAmount = _swapStakingToTips(stakesAdjustment);
                tipsLeftToDeal += convertedAmount;
                tipsIn += convertedAmount;
            }
        }

        if (tipsAdjustment != 0 || stakesAdjustment != 0) {
            emit Scrubbed(tipsAdjustment, stakesAdjustment);
        }
    }

    function _swapStakingToTips(uint256 amountToConvert) internal returns (uint256 convertedAmount) {
        if (stakingToken != tippingToken) {
            address[] memory path = new address[](2);
            (path[0], path[1]) = (stakingToken, tippingToken);
            convertedAmount = IUniswapV2Router02(quickSwapRouterAddress).swapExactTokensForTokens(amountToConvert, 1, path, address(this), block.timestamp)[1];
        } else {
            convertedAmount = amountToConvert;
        }
    }

    function _dealTips(address user) internal {
        require(lastTipDealBlock <= block.number, "TipJar: last tip-deal block in the future");

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
        if (from != address(this)) {
            IERC20(tippingToken).safeTransferFrom(from, address(this), amount);
        }
        tipsIn += amount;
    }

    function _transferTipOut(uint256 amount, address to) internal {
        if (address(this) != to) {
            IERC20(tippingToken).safeTransfer(to, amount);
        }
        tipsOut += amount;
    }

    function _transferStakeIn(address from, uint256 amount) internal {
        if (from != address(this)) {
            IERC20(stakingToken).safeTransferFrom(from, address(this), amount);
        }
        stakesIn += amount;
    }

    function _transferStakeOut(uint256 amount, address to) internal {
        if (address(this) != to) {
            IERC20(stakingToken).safeTransfer(to, amount);
        }
        stakesOut += amount;
    }
}
