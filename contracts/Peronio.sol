// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// OpenZepellin imports
import { AccessControl } from "@openzeppelin/contracts_latest/access/AccessControl.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";
import { ERC20 } from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-ERC20Permit.sol";
import { ERC20Burnable } from "@openzeppelin/contracts_latest/token/ERC20/extensions/ERC20Burnable.sol";
import { SafeERC20 } from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";

// QiDao
import { IFarm } from "./qidao/IFarm.sol";

// UniSwap
import { IUniswapV2Pair } from "./uniswap/interfaces/IUniswapV2Pair.sol";
import { IUniswapV2Router02 } from "./uniswap/interfaces/IUniswapV2Router02.sol";

// Needed for Babylonian square-root
import { sqrt256 } from "./Utils.sol";

// Interface
import { IPeronio } from "./IPeronio.sol";


import { console } from "hardhat/console.sol";


contract Peronio is
    IPeronio,
    ERC20,
    ERC20Burnable,
    ERC20Permit,
    AccessControl,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;

    // USDC Token Address
    address public immutable override usdcAddress;
    // MAI Token Address
    address public immutable override maiAddress;
    // LP USDC/MAI Address from QuickSwap
    address public immutable override lpAddress;
    // QI Token Address
    address public immutable override qiAddress;

    // QuickSwap Router
    address public immutable override quickSwapRouterAddress;

    // QiDao Farm
    address public immutable override qiDaoFarmAddress;
    // QiDao Pool ID
    uint256 public immutable override qiDaoPoolId;

    // Markup
    uint8 public immutable override markupDecimals;
    uint256 public override markup = 5000; // 5.00%
    uint256 public override swapFee = 150; // 0.15%

    // Initialization can only be run once
    bool public override initialized;

    // Roles
    bytes32 public constant override  MARKUP_ROLE = keccak256("MARKUP_ROLE");
    bytes32 public constant override REWARDS_ROLE = keccak256("REWARDS_ROLE");

    constructor(
        string memory name,
        string memory symbol,
        address _usdcAddress,
        address _maiAddress,
        address _lpAddress,
        address _qiAddress,
        address _quickSwapRouterAddress,
        address _qiDaoFarmAddress,
        uint256 _qiDaoPoolId
    )
        ERC20(name, symbol)
        ERC20Permit(name)
    {
        // Stablecoins
        usdcAddress = _usdcAddress;
        maiAddress = _maiAddress;

        // LP USDC/MAI Address
        lpAddress = _lpAddress;

        // Router
        quickSwapRouterAddress = _quickSwapRouterAddress;

        // QiDao
        qiDaoFarmAddress = _qiDaoFarmAddress;
        qiDaoPoolId = _qiDaoPoolId;
        qiAddress = _qiAddress;

        // Markup
        markupDecimals = 5;

        // Grant roles
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MARKUP_ROLE, _msgSender());
        _setupRole(REWARDS_ROLE, _msgSender());
    }

    // Fixed 6 Decimals
    function decimals()
        public
        view
        virtual
        override(ERC20, IPeronio)
        returns (uint8 decimals_)
    {
        return 6;
    }

    // Sets initial minting. Can be runned just once
    function initialize(
        uint256 usdcAmount,
        uint256 startingRatio
    )
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // Lock contract to prevent to be initialized twice
        require(!initialized, "Contract already initialized");
        initialized = true;

        // Get USDC from user
        IERC20(usdcAddress).safeTransferFrom(_msgSender(), address(this), usdcAmount);

        // Unlmited ERC20 approval for Router
        IERC20(maiAddress).approve(quickSwapRouterAddress, type(uint256).max);
        IERC20(usdcAddress).approve(quickSwapRouterAddress, type(uint256).max);
        IERC20(lpAddress).approve(quickSwapRouterAddress, type(uint256).max);
        IERC20(qiAddress).approve(quickSwapRouterAddress, type(uint256).max);

        // Zaps into MAI/USDC LP
        _zapIn(usdcAmount);
        usdcAmount = _stakedValue();

        // Mints exactly startingRatio for each USDC deposit
        _mint(_msgSender(), startingRatio * usdcAmount);

        emit Initialized(_msgSender(), usdcAmount, startingRatio);
    }

    // Sets markup for minting function
    function setMarkup(
        uint256 markup_
    )
        external
        override
        onlyRole(MARKUP_ROLE)
    {
        markup = markup_;
        emit MarkupUpdated(_msgSender(), markup_);
    }

    // Mints new tokens providing proportional collateral (USDC)
    function mint(
        address to,
        uint256 usdcAmount,
        uint256 minReceive
    )
        external
        override
        nonReentrant
        returns (uint256 peAmount)
    {
        console.log("-- mint:");

        // Gets current staked LP Tokens
        uint256 stakedAmount = _stakedBalance();

        // Transfer Collateral Token (USDC) to this contract
        IERC20(usdcAddress).safeTransferFrom(_msgSender(), address(this), usdcAmount); // Changed

        // Zaps USDC directly into MAI/USDC Vault
        uint256 lpAmount = _zapIn(usdcAmount);

        // Fee - Swap fee (+0.15% positive bonus)
        uint256 markupFee = (lpAmount * (markup - swapFee)) / 10**markupDecimals; // Calculate fee to substract
        lpAmount -= markupFee; // remove 5% fee

        // Compute %
        uint256 ratio = (lpAmount * 10e8) / stakedAmount;
        peAmount = (ratio * totalSupply()) / 10e8;

        require(peAmount > minReceive, "Minimum required not met");
        _mint(to, peAmount);
        emit Minted(_msgSender(), usdcAmount, peAmount);
    }

    // Receives Main token burns it and returns Collateral Token proportionally
    function withdraw(
        address to,
        uint256 peAmount
    )
        external
        override
        nonReentrant
        returns (uint256 usdcTotal)
    {
        // Burn tokens
        _burn(_msgSender(), peAmount);

        // Transfer collateral back to user wallet to current contract
        uint256 ratio = (peAmount * 10e8) / totalSupply();
        uint256 lpAmount = (ratio * _stakedBalance()) / 10e8;

        uint256 usdcAmount;

        (usdcAmount, ) = _zapOut(lpAmount);

        uint256 maiAmount = IERC20(maiAddress).balanceOf(address(this));

        // Swap MAI into USDC
        usdcTotal = usdcAmount + _swapMAItoUSDC(maiAmount);

        // Transfer back Collateral Token (USDC) the user
        IERC20(usdcAddress).safeTransfer(to, usdcTotal);

        emit Withdrawal(_msgSender(), usdcTotal, peAmount);
    }

    // Receives Main token burns it and returns LP tokens
    function withdrawLiquidity(
        address to,
        uint256 peAmount
    )
        external
        nonReentrant
    {
        // Burn tokens
        _burn(_msgSender(), peAmount);

        uint256 ratio = (peAmount * 10e8) / totalSupply();
        uint256 lpAmount = (ratio * _stakedBalance()) / 10e8;

        // Get LP tokens out of the Farm
        _unstakeLP(lpAmount);

        // Transfer LP to user
        IERC20(lpAddress).safeTransfer(to, lpAmount);
    }

    // Claim QI rewards from Farm
    function claimRewards()
        external
        override
        onlyRole(REWARDS_ROLE)
    {
        IFarm(qiDaoFarmAddress).deposit(qiDaoPoolId, 0);
    }

    // Reinvest the QI into the Farm
    function compoundRewards()
        external
        override
        onlyRole(REWARDS_ROLE)
        returns (uint256 usdcAmount, uint256 lpAmount)
    {
        uint256 amount = IERC20(qiAddress).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = qiAddress;
        path[1] = usdcAddress;

        IUniswapV2Router02(quickSwapRouterAddress).swapExactTokensForTokens(
            amount,
            1,
            path,
            address(this),
            block.timestamp + 3600
        );
        // Sweep all remaining USDC in the contract
        usdcAmount = IERC20(usdcAddress).balanceOf(address(this));
        lpAmount = _zapIn(usdcAmount);

        emit CompoundRewards(amount, usdcAmount, lpAmount);
    }

    // Returns LP Amount staked in the Farm
    function stakedBalance()
        external
        view
        override
        returns (uint256 lpAmount)
    {
        return _stakedBalance();
    }

    // Returns current staking value in USDC
    function stakedValue()
        external
        view
        override
        returns (uint256 usdcAmount)
    {
        return _stakedValue();
    }

    // Returns current USDC and MAI token balances in the FARM
    function stakedTokens()
        external
        view
        returns (uint256 usdcAmount, uint256 maiAmount)
    {
        return _stakedTokens();
    }

    // Gets current ratio: Total Supply / Collateral USDC Balance in vault
    function usdcPrice()
        external
        view
        override
        returns (uint256 price)
    {
        return (this.totalSupply() * 10**decimals()) / _stakedValue();
    }

    // Gets current ratio: collateralRatio + markup
    function buyingPrice()
        external
        view
        override
        returns (uint256 price)
    {
        uint256 basePrice = _collateralRatio();
        uint256 fee = (basePrice * markup) / 10**markupDecimals;
        return basePrice + fee;
    }

    // Gets current ratio: Collateral USDC Balance / Total Supply
    function collateralRatio()
        external
        view
        override
        returns (uint256 ratio)
    {
        return _collateralRatio();
    }

    // Fetch pending rewards (QI) from Mai Farm
    function getPendingRewardsAmount()
        external
        view
        override
        returns (uint256 amount)
    {
        amount = _getPendingRewardsAmount();
    }

    // Return all QuickSwap Liquidity Pool (MAI/USDC) reserves
    function getLpReserves()
        external
        view
        override
        returns (uint112 usdcReserves, uint112 maiReserves)
    {
        return _getLpReserves();
    }

    // NEEDS TESTING
    function quoteIn(
        uint256 usdc
    )
        external
        view
        override
        returns (uint256 pe)
    {
        console.log("-- quoteIn:");
        uint256 stakedAmount = _stakedBalance();
        (uint112 usdcReserves, uint112 maiReserves) = _getLpReserves(); // $$$$ remove maiReserves

        uint256 amountToSwap = _calculateSwapInAmount(usdcReserves, usdc);
        console.log("amountToSwap", amountToSwap);

        uint256 maiAmount = _getAmountOut(amountToSwap, usdcReserves, maiReserves);

        uint256 usdcAmount = usdc - amountToSwap;

        console.log("usdcAmount", usdcAmount);

        console.log("totalSupply before", IERC20(lpAddress).totalSupply());

        uint256 lpAmount = (usdcAmount * IERC20(lpAddress).totalSupply()) / (usdcReserves + amountToSwap);
        uint256 lpAmount2 = (maiAmount * IERC20(lpAddress).totalSupply()) / (maiReserves - maiAmount);

        console.log("lpAmount", lpAmount);

        console.log("lpAmount2", lpAmount2);

        uint256 markupFee = (lpAmount * (markup - swapFee)) / 10**markupDecimals; // Calculate fee to substract
        lpAmount = lpAmount - markupFee; // remove 5% fee

        // Compute %
        uint256 ratio = (lpAmount * 10e8) / stakedAmount;
        pe = (ratio * totalSupply()) / 10e8;
    }

    // NEEDS TESTING
    function quoteOut(
        uint256 pe
    )
        external
        view
        override
        returns (uint256 usdc)
    {
        (uint112 usdcReserves, uint112 maiReserves) = _getLpReserves();

        uint256 ratio = (pe * 10e8) / totalSupply();

        (uint256 stakedUsdc, uint256 stakedMai) = _stakedTokens();
        uint256 usdcAmount = (stakedUsdc * ratio) / 10e8;
        uint256 maiAmount = (stakedMai * ratio) / 10e8;

        usdc = usdcAmount + _getAmountOut(maiAmount, maiReserves, usdcReserves);
    }

    // Collateral USDC Balance / Total Supply
    function _collateralRatio()
        internal
        view
        returns (uint256 ratio)
    {
        return (_stakedValue() * 10**decimals()) / this.totalSupply();
    }

    // Returns current staking value in USDC
    function _stakedValue()
        internal
        view
        returns (uint256 totalUSDC)
    {
        uint256 usdcReserves;
        uint256 maiReserves;
        uint256 usdcAmount;
        uint256 maiAmount;
        (usdcReserves, maiReserves) = _getLpReserves();
        (usdcAmount, maiAmount) = _stakedTokens();

        // Simulate Swap
        totalUSDC = usdcAmount + _getAmountOut(maiAmount, maiReserves, usdcReserves);
    }

    // Return all QuickSwap Liquidity Pool (MAI/USDC) reserves
    function _getLpReserves()
        internal
        view
        returns (uint112 usdcReserves, uint112 maiReserves)
    {
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = IUniswapV2Pair(lpAddress).getReserves();
        (usdcReserves, maiReserves) = usdcAddress < maiAddress
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // Returns current USDC and MAI token balances in the FARM
    function _stakedTokens()
        internal
        view
        returns (uint256 usdcAmount, uint256 maiAmount)
    {
        uint256 lpAmount = _stakedBalance();
        // Add 18 precision decimals
        uint256 ratio = (lpAmount * 10e18) / IERC20(lpAddress).totalSupply();
        uint112 usdcReserves;
        uint112 maiReserves;

        (usdcReserves, maiReserves) = _getLpReserves();

        // Remove 18 precision decimals
        usdcAmount = (ratio * usdcReserves) / 10e18;
        maiAmount = (ratio * maiReserves) / 10e18;
    }

    // Returns LP Amount staked in the QiDao Farm
    function _stakedBalance()
        internal
        view
        returns (uint256 lpAmount)
    {
        return IFarm(qiDaoFarmAddress).deposited(qiDaoPoolId, address(this));
    }

    // Zaps USDC into MAI/USDC Pool and mint into QiDao Farm
    function _zapIn(
        uint256 amount
    )
        internal
        returns (uint256 lpAmount)
    {
        // Provide USDC Liquidity (MAI/USDC) and get LP Tokens in return
        uint256 usdcAmount;
        uint256 maiAmount;

        (usdcAmount, maiAmount) = _splitUSDC(amount);

        console.log("totalSupply before", IERC20(lpAddress).totalSupply());

        lpAmount = _addLiquidity(usdcAmount, maiAmount);

        console.log("totalSupply after", IERC20(lpAddress).totalSupply());

        console.log("lpAmount", lpAmount);

        // Stake LP Tokens
        _stakeLP(lpAmount);
    }

    // Zaps out USDC from MAI/USDC Pool
    function _zapOut(
        uint256 lpAmount
    )
        internal
        returns (uint256 usdcAmount, uint256 maiAmount)
    {
        // Get LP tokens out of the Farm
        _unstakeLP(lpAmount);

        (usdcAmount, maiAmount) = _removeLiquidity(lpAmount);
    }

    // Adds liquidity into the Quickswap pool MAI/USDC
    function _addLiquidity(
        uint256 usdcAmount,
        uint256 maiAmount
    )
        internal
        returns (uint256 lpAmount)
    {
        (, , lpAmount) = IUniswapV2Router02(quickSwapRouterAddress).addLiquidity(
            usdcAddress,
            maiAddress,
            usdcAmount,
            maiAmount,
            1,
            1,
            address(this),
            block.timestamp + 3600
        );
    }

    // Removes liquidity from Quickswap pool MAI/USDC
    function _removeLiquidity(
        uint256 lpAmount
    )
        internal
        returns (uint256 usdcAmount, uint256 maiAmount)
    {
        (usdcAmount, maiAmount) = IUniswapV2Router02(quickSwapRouterAddress)
            .removeLiquidity(
                usdcAddress,
                maiAddress,
                lpAmount,
                1,
                1,
                address(this),
                block.timestamp + 3600
            );
    }

    // Swaps MAI token into USDC on QuickSwap pool
    function _swapMAItoUSDC(
        uint256 amount
    )
        internal
        returns (uint256 usdcAmount)
    {
        address[] memory path = new address[](2);
        path[0] = maiAddress;
        path[1] = usdcAddress;

        uint256[] memory amounts = IUniswapV2Router02(quickSwapRouterAddress)
            .swapExactTokensForTokens(
                amount,
                1,
                path,
                address(this),
                block.timestamp + 3600
            );
        usdcAmount = amounts[1];
    }

    // Splits USDC into USDC/MAI for Quickswap LP
    function _splitUSDC(
        uint256 amount
    )
        internal
        returns (uint256 usdcAmount, uint256 maiAmount)
    {
        (uint112 usdcReserves, ) = _getLpReserves();
        uint256 amountToSwap = _calculateSwapInAmount(usdcReserves, amount);

        console.log("amountToSwap", amountToSwap);

        require(amountToSwap > 0, "Nothing to swap");

        address[] memory path = new address[](2);
        path[0] = usdcAddress;
        path[1] = maiAddress;

        uint256[] memory amounts = IUniswapV2Router02(quickSwapRouterAddress)
            .swapExactTokensForTokens(
                amountToSwap,
                1,
                path,
                address(this),
                block.timestamp + 3600
            );
        maiAmount = amounts[1];
        usdcAmount = amount - amountToSwap;

        console.log("usdcAmount", usdcAmount);
    }

    // Stake LP tokens (MAI/USDC) into QiDAO Farm
    function _stakeLP(
        uint256 lpAmount
    )
        internal
    {
        // Approve LP Tokens for QiDao Farm
        IERC20(lpAddress).approve(qiDaoFarmAddress, lpAmount);

        // Deposit LP Tokens into Farm
        IFarm(qiDaoFarmAddress).deposit(qiDaoPoolId, lpAmount);
    }

    // Unstake LP tokens (MAI/USDC) into QiDAO Farm
    function _unstakeLP(
        uint256 lpAmount
    )
        internal
    {
        // Deposit LP Tokens into Farm
        IFarm(qiDaoFarmAddress).withdraw(qiDaoPoolId, lpAmount);
    }

    // Returns LP Balance
    function _getLPBalanceAmount()
        internal
        view
        returns (uint256 lpAmount)
    {
        // Get current LP Balance
        lpAmount = IERC20(lpAddress).balanceOf(address(this));
    }

    // Returns pending rewards (QI) amount from Mai Farm
    function _getPendingRewardsAmount()
        internal
        view
        returns (uint256 amount)
    {
        // Get rewards on Farm
        amount = IFarm(qiDaoFarmAddress).pending(qiDaoPoolId, address(this));
    }

    // Returns QI Balance in the contract
    function _getRewardsAmount()
        internal
        view
        returns (uint256 amount)
    {
        // Get QI Dao balanced minted
        amount = IERC20(qiAddress).balanceOf(address(this));
    }

    function _calculateSwapInAmount(
        uint256 reserveIn,
        uint256 userIn
    )
        internal
        pure
        returns (uint256 amount)
    {
        return
            (sqrt256(
                reserveIn * ((userIn * 3988000) + (reserveIn * 3988009))
            ) - (reserveIn * 1997)) / 1994;
    }

    //**  UNISWAP Library Functions Below **/
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    )
        internal
        pure
        returns (uint256 amountOut)
    {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");  // solhint-disable-line reason-string
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");  // solhint-disable-line reason-string
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
