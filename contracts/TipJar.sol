// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";
import {SafeERC20} from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";

import {ERC165} from "@openzeppelin/contracts_latest/utils/introspection/ERC165.sol";

import {Context} from "@openzeppelin/contracts_latest/utils/Context.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";
import {Multicall} from "@openzeppelin/contracts_latest/utils/Multicall.sol";

import {IUniswapV2Router02} from "./uniswap/interfaces/IUniswapV2Router02.sol";

import {ILinearTipJar, ITipJar} from "./ITipJar.sol";

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
 *     - this will make any tips sent to the tip jar address by any means other than the "tip()" method to be available for dealing
 *     - additionally, any staking token sent by means other than the "stake()" method are swapped to the tipping token and made available
 *   - if the fee address is the same as the tip jar's address, stakes will be dealt with as if being received outside of "stake()" (ie. swapped and made into tips)
 *   - the tipping and staking tokens can safely be the same, any extra amounts (in the sense above) need not be swapped, but everything works as expected
 *   - the actual distribution of tips can be controlled by overriding the "_getTipsToDistribute()" method
 *   - deposit fees can have an arbitrary number of decimals (up to 77, otherwise 256 bits fail to represent it)
 */
abstract contract TipJar is Context, ERC165, ITipJar, Multicall, ReentrancyGuard {
    // TODO: unchecked!!!
    using SafeERC20 for IERC20;

    // The address of the token to use for staking
    address public immutable override stakingToken;

    // The number of staking tokens entered into the contract via the defined interfaces herein
    uint256 public override stakesIn;

    // The number of staking tokens withdrawn from the contract via the defined interfaces herein
    uint256 public override stakesOut;

    // The address of the token to use for tips accumulation and distribution
    address public immutable override tippingToken;

    // The number of tipping tokens entered into the contract via the defined interfaces herein
    uint256 public override tipsIn;

    // The number of tipping tokens withdrawn from the contract via the defined interfaces herein
    uint256 public override tipsOut;

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
    uint256 public override depositFee; // Deposit fee in basis points

    uint8 public override depositFeeDecimals;

    // The address to which
    address public override feeAddress;

    constructor(
        address _stakingToken,
        address _tippingToken,
        uint256 _depositFee,
        uint8 _depositFeeDecimals,
        address _feeAddress,
        address _quickSwapRouterAddress
    ) {
        require(depositFeeDecimals < 78, "TipJar: deposit fee decimals too big");

        (stakingToken, tippingToken) = (_stakingToken, _tippingToken);

        quickSwapRouterAddress = _quickSwapRouterAddress;
        IERC20(stakingToken).safeApprove(quickSwapRouterAddress, type(uint256).max);

        depositFee = _depositFee;
        depositFeeDecimals = _depositFeeDecimals;
        feeAddress = _feeAddress;

        // Setting these to 1 instead of 0 makes the deploy slightly more expensive, but all subsequent increments will be at constant cost
        stakesIn = stakesOut = 1;
        tipsIn = tipsOut = 1;

        lastTipDealBlock = block.number;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ITipJar).interfaceId;
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

    function unstake() external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(stakedAmount[_msgSender()], _msgSender());
    }

    function unstake(address to) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(stakedAmount[_msgSender()], to);
    }

    function unstake(uint256 amount) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(amount, _msgSender());
    }

    function unstake(uint256 amount, address to) external override nonReentrant returns (uint256 _stakedAmount) {
        _stakedAmount = _unstake(amount, to);
    }

    function withdrawTips() external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(_pendingTipsToPayOut(_msgSender()), _msgSender());
    }

    function withdrawTips(address to) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(_pendingTipsToPayOut(_msgSender()), to);
    }

    function withdrawTips(uint256 amount) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(amount, _msgSender());
    }

    function withdrawTips(uint256 amount, address to) external override nonReentrant returns (uint256 _extractedAmount) {
        _extractedAmount = _withdrawTips(amount, to);
    }

    function scrub() external override nonReentrant returns (uint256 tipsAdjustment, uint256 stakesAdjustment) {
        (tipsAdjustment, stakesAdjustment) = _scrub();
    }

    function _getTipsToDistribute() internal view virtual returns (uint256 tipsToDistribute);

    function _pendingTipsToPayOut(address user) internal view returns (uint256 pendingAmount) {
        require(lastTipDealBlock <= block.number, "TipJar: last tip deal block in the future");

        uint256 _accumulatedTipsPerShare = accumulatedTipsPerShare;
        uint256 stakeSupply = stakesIn - stakesOut;
        if (stakeSupply != 0) {
            _accumulatedTipsPerShare += Math.min(tipsLeftToDeal, _getTipsToDistribute()) / stakeSupply;
        }

        uint256 userStakedAmount = stakedAmount[user];
        if (userStakedAmount != 0) {
            pendingAmount = tipsPending[user] + userStakedAmount * _accumulatedTipsPerShare - tipsPaidOut[user];
        }
    }

    function _tip(address from, uint256 amount) internal returns (uint256 _tipsLeftToDeal) {
        _dealTips(address(0));

        _transferTipIn(from, amount);

        _tipsLeftToDeal = tipsLeftToDeal += amount;

        emit TipReceived(amount, from);
    }

    function _stake(address from, uint256 amount) internal returns (uint256 _stakedAmount) {
        _dealTips(from);

        if (0 < amount) {
            _transferStakeIn(from, amount);

            stakedAmount[from] += amount;

            if (0 < depositFee) {
                uint256 depositFeeAmount = Math.mulDiv(amount, depositFee, 10**depositFeeDecimals);
                _transferStakeOut(depositFeeAmount, feeAddress);
                stakedAmount[from] -= depositFeeAmount;
            }
        }

        _stakedAmount = stakedAmount[from];

        emit StakeIncreased(amount, from);
    }

    function _unstake(
        uint256 amount,
        address to
    ) internal returns (uint256 _stakedAmount) {
        address from = _msgSender();

        require(amount <= stakedAmount[from], "TipJar: can't withdraw more than staked amount");

        _dealTips(to);

        _transferStakeOut(amount, to);

        _stakedAmount = stakedAmount[from] -= amount;

        emit StakeDecreased(amount, from);
    }

    function _withdrawTips(
        uint256 amount,
        address to
    ) internal returns (uint256 _extractedAmount) {
        address from = _msgSender();

        _dealTips(from);

        require(amount <= tipsPending[from], "TipJar: can't extract more than pending amount");

        _transferTipOut(amount, to);

        tipsPending[from] -= amount;
        tipsPaidOut[from] += amount;

        _extractedAmount = amount;
    }

    function _scrub() internal returns (uint256 tipsAdjustment, uint256 stakesAdjustment) {
        if (tippingToken == stakingToken) {
            uint256 inToken = IERC20(tippingToken).balanceOf(address(this));
            require(inToken <= (tipsIn + stakesIn) - (tipsOut + stakesOut), "TipJar: balance leak detected, aborting!");

            tipsAdjustment = inToken - ((tipsIn + stakesIn) - (tipsOut + stakesOut));
            if (tipsAdjustment != 0) {
                tipsLeftToDeal += tipsAdjustment;
                tipsIn += tipsAdjustment;
            }
        } else {
            {
                uint256 stakesInToken = IERC20(stakingToken).balanceOf(address(this));
                require(stakesInToken <= stakesIn - stakesOut, "TipJar: stakes balance leak detected, aborting!");

                stakesAdjustment = stakesInToken - (stakesIn - stakesOut);
                if (stakesAdjustment != 0) {
                    _swapStakingToTips(stakesAdjustment);
                }
            }

            {
                uint256 tipsInToken = IERC20(tippingToken).balanceOf(address(this));
                require(tipsInToken <= tipsIn - tipsOut, "TipJar: tip balance leak detected, aborting!");

                tipsAdjustment = tipsInToken - (tipsIn - tipsOut);
                if (tipsAdjustment != 0) {
                    tipsLeftToDeal += tipsAdjustment;
                    tipsIn += tipsAdjustment;
                }
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
            uint256 tipsToDistribute = Math.min(tipsLeftToDeal, _getTipsToDistribute());
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

contract LinearTipJar is ILinearTipJar, TipJar {
    // Number of tip tokens dealt each block
    uint256 public immutable override tipsDealtPerBlock;

    constructor(
        address _stakingToken,
        address _tippingToken,
        uint256 _depositFee,
        uint8 _depositFeeDecimals,
        address _feeAddress,
        address _quickSwapRouterAddress,
        uint256 _tipsDealtPerBlock
    ) TipJar(_stakingToken, _tippingToken, _depositFee, _depositFeeDecimals, _feeAddress, _quickSwapRouterAddress) {
        tipsDealtPerBlock = _tipsDealtPerBlock;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(ILinearTipJar).interfaceId;
    }

    function _getTipsToDistribute() internal view override returns (uint256 tipsToDistribute) {
        tipsToDistribute = (block.number - lastTipDealBlock) * tipsDealtPerBlock;
    }
}
