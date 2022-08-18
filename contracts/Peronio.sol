// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// OpenZeppelin imports
import {AccessControl} from "@openzeppelin/contracts_latest/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {ERC20Permit} from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-ERC20Permit.sol";
import {ERC20Burnable} from "@openzeppelin/contracts_latest/token/ERC20/extensions/ERC20Burnable.sol";
import {SafeERC20} from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";

// QiDao
import {IFarm} from "./qidao/IFarm.sol";

// UniSwap
import {IUniswapV2Pair} from "./uniswap/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "./uniswap/interfaces/IUniswapV2Router02.sol";

// Needed for Babylonian square-root & combined-multiplication-and-division
import {min, mulDiv, sqrt256} from "./Utils.sol";

// Interface
import {IPeronio} from "./IPeronio.sol";

contract Peronio is IPeronio, ERC20, ERC20Burnable, ERC20Permit, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant override MARKUP_ROLE = keccak256("MARKUP_ROLE");
    bytes32 public constant override REWARDS_ROLE = keccak256("REWARDS_ROLE");

    // USDC Token Address
    address public immutable override usdcAddress;
    // MAI Token Address
    address public immutable override maiAddress;
    // LP USDC/MAI Address from QuickSwap
    address public immutable override lpAddress;
    // QI Token Address
    address public immutable override qiAddress;

    // QuickSwap Router Address
    address public immutable override quickSwapRouterAddress;

    // QiDao Farm Address
    address public immutable override qiDaoFarmAddress;
    // QiDao Pool ID
    uint256 public immutable override qiDaoPoolId;

    // Constant number of significant decimals
    uint8 private constant DECIMALS = 6;

    // Fees
    uint256 public override markupFee = 50000; // 5.00%
    uint256 public override swapFee = 1500; // 0.15%

    // Initialization can only be run once
    bool public override initialized;

    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    // --- Public Interface -----------------------------------------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Construct a new Peronio contract
     *
     * @param name  The name of the token being created ("Peronio")
     * @param symbol  Symbol to use for the token being created ("PE")
     * @param _usdcAddress  Address used for the USDC tokens in vault
     * @param _maiAddress  Address used for the MAI tokens in vault
     * @param _qiAddress  Address used for the QI tokens in vault
     * @param _quickSwapRouterAddress  Address of the QuickSwap Router to talk to
     * @param _qiDaoFarmAddress  Address of the QiDao Farm to use
     * @param _qiDaoPoolId  Pool ID within the QiDao Farm
     */
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
    ) ERC20(name, symbol) ERC20Permit(name) {
        // Stablecoin Addresses
        usdcAddress = _usdcAddress;
        maiAddress = _maiAddress;

        // LP USDC/MAI Address
        lpAddress = _lpAddress;

        // Router Address
        quickSwapRouterAddress = _quickSwapRouterAddress;

        // QiDao Data
        qiDaoFarmAddress = _qiDaoFarmAddress;
        qiDaoPoolId = _qiDaoPoolId;
        qiAddress = _qiAddress;

        // Grant roles
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MARKUP_ROLE, _msgSender());
        _setupRole(REWARDS_ROLE, _msgSender());
    }

    // --- Decimals -------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the number of decimals the PE token will work with
     *
     * @return decimals_  This will always be 6
     */
    function decimals() public view virtual override(ERC20, IPeronio) returns (uint8 decimals_) {
        decimals_ = DECIMALS;
    }

    // --- Markup fee change ----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Set the markup fee to the given value (take into account that this will use `DECIMALS` decimals implicitly)
     *
     * @param newMarkupFee  New markup fee value
     * @return prevMarkupFee  Previous markup fee value
     * @custom:emit  MarkupFeeUpdated
     */
    function setMarkupFee(uint256 newMarkupFee) external override onlyRole(MARKUP_ROLE) returns (uint256 prevMarkupFee) {
        (prevMarkupFee, markupFee) = (markupFee, newMarkupFee);

        emit MarkupFeeUpdated(_msgSender(), newMarkupFee);
    }

    // --- Initialization -------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Initialize the PE token by providing collateral USDC tokens - initial conversion rate will be set at the given starting ratio
     *
     * @param usdcAmount  Number of collateral USDC tokens
     * @param startingRatio  Initial minting ratio in PE tokens per USDC tokens minted
     * @custom:emit  Initialized
     */
    function initialize(uint256 usdcAmount, uint256 startingRatio) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        // Prevent double initialization
        require(!initialized, "Contract already initialized");
        initialized = true;

        // Transfer initial USDC amount from user to current contract
        IERC20(usdcAddress).safeTransferFrom(_msgSender(), address(this), usdcAmount);

        // Unlimited ERC20 approval for Router
        IERC20(maiAddress).approve(quickSwapRouterAddress, type(uint256).max);
        IERC20(usdcAddress).approve(quickSwapRouterAddress, type(uint256).max);
        IERC20(lpAddress).approve(quickSwapRouterAddress, type(uint256).max);
        IERC20(qiAddress).approve(quickSwapRouterAddress, type(uint256).max);

        // Commit the complete initial USDC amount
        _zapIn(usdcAmount);
        usdcAmount = _stakedValue();

        // Mints exactly startingRatio for each collateral USDC token
        _mint(_msgSender(), startingRatio * usdcAmount);

        emit Initialized(_msgSender(), usdcAmount, startingRatio);
    }

    // --- State views ----------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function getLpReserves() external view override returns (uint256 usdcReserves, uint256 maiReserves) {
        (usdcReserves, maiReserves) = _getLpReserves();
    }

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function stakedBalance() external view override returns (uint256 lpAmount) {
        lpAmount = _stakedBalance();
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function stakedTokens() external view override returns (uint256 usdcAmount, uint256 maiAmount) {
        (usdcAmount, maiAmount) = _stakedTokens();
    }

    /**
     * Return the equivalent number of USDC tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Total equivalent number of USDC token on stake
     */
    function stakedValue() external view override returns (uint256 usdcAmount) {
        usdcAmount = _stakedValue();
    }

    /**
     * Return the _collateralized_ price in USDC tokens per PE token
     *
     * @return price  Collateralized price in USDC tokens per PE token
     */
    function usdcPrice() external view override returns (uint256 price) {
        price = mulDiv(10**DECIMALS, totalSupply(), _stakedValue());
    }

    /**
     * Return the effective _minting_ price in USDC tokens per PE token
     *
     * @return price  Minting price in USDC tokens per PE token
     */
    function buyingPrice() external view override returns (uint256 price) {
        price = mulDiv(_collateralRatio(), 10**DECIMALS + markupFee, 10**DECIMALS);
    }

    /**
     * Return the ratio of total number of USDC tokens per PE token
     *
     * @return ratio  Ratio of USDC tokens per PE token, with `_decimal` decimals
     */
    function collateralRatio() external view override returns (uint256 ratio) {
        ratio = _collateralRatio();
    }

    // --- State changers -------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Mint PE tokens using the provided USDC tokens as collateral
     *
     * @param to  The address to transfer the minted PE tokens to
     * @param usdcAmount  Number of USDC tokens to use as collateral
     * @param minReceive  The minimum number of PE tokens to mint
     * @return peAmount  The number of PE tokens actually minted
     * @custom:emit  Minted
     */
    function mint(
        address to,
        uint256 usdcAmount,
        uint256 minReceive
    ) external override nonReentrant returns (uint256 peAmount) {
        // Transfer USDC tokens as collateral to this contract
        IERC20(usdcAddress).safeTransferFrom(_msgSender(), address(this), usdcAmount);

        // Remember the previously staked balance
        uint256 stakedAmount = _stakedBalance();

        // Commit USDC tokens, and discount fees totalling the markup fee
        uint256 lpAmount = mulDiv(_zapIn(usdcAmount), 10**DECIMALS - _totalMintFee(), 10**DECIMALS);

        // Calculate the number of PE tokens as the proportion of liquidity provided
        peAmount = mulDiv(lpAmount, totalSupply(), stakedAmount);

        require(minReceive <= peAmount, "Minimum required not met");

        // Actually mint the PE tokens
        _mint(to, peAmount);

        emit Minted(_msgSender(), usdcAmount, peAmount);
    }

    /**
     * Extract the given number of PE tokens as USDC tokens
     *
     * @param to  Address to deposit extracted USDC tokens into
     * @param peAmount  Number of PE tokens to withdraw
     * @return usdcTotal  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     */
    function withdraw(address to, uint256 peAmount) external override nonReentrant returns (uint256 usdcTotal) {
        // Calculate equivalent number of LP USDC/MAI tokens for the given burnt PE tokens
        uint256 lpAmount = mulDiv(peAmount, _stakedBalance(), totalSupply());

        // Extract the given number of LP USDC/MAI tokens as USDC tokens
        usdcTotal = _zapOut(lpAmount);

        // Transfer USDC tokens the the given address
        IERC20(usdcAddress).safeTransfer(to, usdcTotal);

        // Burn the given number of PE tokens
        _burn(_msgSender(), peAmount);

        emit Withdrawal(_msgSender(), usdcTotal, peAmount);
    }

    /**
     * Extract the given number of PE tokens as LP USDC/MAI tokens
     *
     * @param to  Address to deposit extracted LP USDC/MAI tokens into
     * @param peAmount  Number of PE tokens to withdraw liquidity for
     * @return lpAmount  Number of LP USDC/MAI tokens extracted
     * @custom:emit LiquidityWithdrawal
     */
    function withdrawLiquidity(address to, uint256 peAmount) external override nonReentrant returns (uint256 lpAmount) {
        // Burn the given number of PE tokens
        _burn(_msgSender(), peAmount);

        // Calculate equivalent number of LP USDC/MAI tokens for the given burnt PE tokens
        lpAmount = mulDiv(peAmount, _stakedBalance(), totalSupply());

        // Get LP USDC/MAI tokens out of QiDao's Farm
        _unstakeLP(lpAmount);

        // Transfer LP USDC/MAI tokens to the given address
        IERC20(lpAddress).safeTransfer(to, lpAmount);

        emit LiquidityWithdrawal(_msgSender(), lpAmount, peAmount);
    }

    // --- Rewards --------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the rewards accrued by staking LP USDC/MAI tokens in QiDao's Farm (in QI tokens)
     *
     * @return qiAmount  Number of QI tokens accrued
     */
    function getPendingRewardsAmount() external view override returns (uint256 qiAmount) {
        qiAmount = _getPendingRewardsAmount();
    }

    /**
     * Claim QiDao's QI token rewards, and re-invest them in the QuickSwap liquidity pool and QiDao's Farm
     *
     * @return usdcAmount  The number of USDC tokens being re-invested
     * @return lpAmount  The number of LP USDC/MAI tokens being put on stake
     * @custom:emit CompoundRewards
     */
    function compoundRewards() external override onlyRole(REWARDS_ROLE) returns (uint256 usdcAmount, uint256 lpAmount) {
        // Claim rewards from QiDao's Farm
        IFarm(qiDaoFarmAddress).deposit(qiDaoPoolId, 0);

        // Retrieve the number of QI tokens rewarded and swap them to USDC tokens
        uint256 amount = IERC20(qiAddress).balanceOf(address(this));
        _swapQItoUSDC(amount);

        // Commit all USDC tokens so converted to the QuickSwap liquidity pool
        usdcAmount = IERC20(usdcAddress).balanceOf(address(this));
        lpAmount = _zapIn(usdcAmount);

        emit CompoundRewards(amount, usdcAmount, lpAmount);
    }

    // --- Quotes ---------------------------------------------------------------------------------------------------------------------------------------------

    // NEEDS TESTING
    // TODO
    function quoteIn(uint256 usdc) external view override returns (uint256 pe) {
        uint256 stakedAmount = _stakedBalance();
        (uint256 usdcReserves, ) = _getLpReserves(); // $$$$ remove maiReserves

        uint256 amountToSwap = _calculateSwapInAmount(usdcReserves, usdc);

        uint256 usdcAmount = usdc - amountToSwap;

        uint256 lpAmount = mulDiv(usdcAmount, IERC20(lpAddress).totalSupply(), usdcReserves + amountToSwap);

        uint256 markup = mulDiv(lpAmount, markupFee - swapFee, 10**DECIMALS); // Calculate fee to subtract
        lpAmount = lpAmount - markup; // remove 5% fee

        // Compute %
        pe = mulDiv(lpAmount, totalSupply(), stakedAmount);
    }

    // NEEDS TESTING
    // TODO
    function quoteOut(uint256 pe) external view override returns (uint256 usdc) {
        (uint256 usdcReserves, uint256 maiReserves) = _getLpReserves();
        (uint256 stakedUsdc, uint256 stakedMai) = _stakedTokens();

        uint256 usdcAmount = mulDiv(pe, stakedUsdc, totalSupply());
        uint256 maiAmount = mulDiv(pe, stakedMai, totalSupply());

        usdc = usdcAmount + _getAmountOut(maiAmount, maiReserves, usdcReserves);
    }

    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    // --- Private Interface ----------------------------------------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function _getLpReserves() internal view returns (uint256 usdcReserves, uint256 maiReserves) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(lpAddress).getReserves();
        (usdcReserves, maiReserves) = usdcAddress < maiAddress ? (uint256(reserve0), uint256(reserve1)) : (uint256(reserve1), uint256(reserve0));
    }

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function _stakedBalance() internal view returns (uint256 lpAmount) {
        lpAmount = IFarm(qiDaoFarmAddress).deposited(qiDaoPoolId, address(this));
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function _stakedTokens() internal view returns (uint256 usdcAmount, uint256 maiAmount) {
        uint256 lpAmount = _stakedBalance();
        uint256 lpTotalSupply = IERC20(lpAddress).totalSupply();

        (uint256 usdcReserves, uint256 maiReserves) = _getLpReserves();

        usdcAmount = mulDiv(lpAmount, usdcReserves, lpTotalSupply);
        maiAmount = mulDiv(lpAmount, maiReserves, lpTotalSupply);
    }

    /**
     * Return the equivalent number of USDC tokens on stake at QiDao's Farm
     *
     * This method will return the equivalent number of USDC tokens for the number of USDC and MAI tokens on stake.
     *
     * @return totalUSDC  Total equivalent number of USDC token on stake
     */
    function _stakedValue() internal view returns (uint256 totalUSDC) {
        (uint256 usdcReserves, uint256 maiReserves) = _getLpReserves();
        (uint256 usdcAmount, uint256 maiAmount) = _stakedTokens();

        // Simulate Swap
        totalUSDC = usdcAmount + _getAmountOut(maiAmount, maiReserves, usdcReserves);
    }

    /**
     * Return the ratio of total number of USDC tokens per PE token
     *
     * @return ratio  Ratio of USDC tokens per PE token, with `_decimal` decimals
     */
    function _collateralRatio() internal view returns (uint256 ratio) {
        ratio = mulDiv(10**DECIMALS, _stakedValue(), totalSupply());
    }

    /**
     * Return the total minting fee to apply
     *
     * @return totalFee  The total fee to apply on minting
     */
    function _totalMintFee() internal view returns (uint256 totalFee) {
        // Retrieve the deposit fee from QiDao's Farm (this is always expressed with 4 decimals, as "basic points")
        // Convert these "basic points" to `DECIMALS` precision
        (, , , , uint16 depositFeeBP) = IFarm(qiDaoFarmAddress).poolInfo(qiDaoPoolId);
        uint256 depositFee = uint256(depositFeeBP) * 10**(DECIMALS - 4);

        // Calculate total fee to apply
        // (ie. the swapFee and the depositFee are included in the total markup fee, thus, we don't double charge for both the markup fee itself
        // and the swap and deposit fees)
        totalFee = markupFee - min(markupFee, swapFee + depositFee);
    }

    /**
     * Commit the given number of USDC tokens
     *
     * This method will:
     *   1. split the given USDC amount into USDC/MAI amounts so as to provide balanced liquidity,
     *   2. add the given amounts of USDC and MAI tokens to the liquidity pool, and obtain LP USDC/MAI tokens in return, and
     *   3. stake the given LP USDC/MAI tokens in QiDao's Farm so as to accrue rewards therein.
     *
     * @param usdcAmount  Number of USDC tokens to commit
     * @return lpAmount  Number of LP USDC/MAI tokens committed
     */
    function _zapIn(uint256 usdcAmount) internal returns (uint256 lpAmount) {
        uint256 maiAmount;

        (usdcAmount, maiAmount) = _splitUSDC(usdcAmount);
        lpAmount = _addLiquidity(usdcAmount, maiAmount);
        _stakeLP(lpAmount);
    }

    /**
     * Extract the given number of LP USDC/MAI tokens
     *
     * This method will:
     *   1. unstake the given number of LP USDC/MAI tokens from QuiDao's Farm,
     *   2. remove the liquidity provided by the given number of LP USDC/MAI tokens from the liquidity pool, and
     *   3. convert the MAI tokens back into USDC tokens.
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to extract
     * @return usdcAmount  Number of extracted USDC tokens
     */
    function _zapOut(uint256 lpAmount) internal returns (uint256 usdcAmount) {
        uint256 maiAmount;

        _unstakeLP(lpAmount);
        (usdcAmount, maiAmount) = _removeLiquidity(lpAmount);
        usdcAmount = _unsplitUSDC(usdcAmount, maiAmount);
    }

    /**
     * Given a USDC token amount, split a portion of it into MAI tokens so as to provide balanced liquidity
     *
     * @param amount  Number of USDC tokens to split
     * @return usdcAmount  Number of resulting USDC tokens
     * @return maiAmount  Number of resulting MAI tokens
     */
    function _splitUSDC(uint256 amount) internal returns (uint256 usdcAmount, uint256 maiAmount) {
        (uint256 usdcReserves, ) = _getLpReserves();
        uint256 amountToSwap = _calculateSwapInAmount(usdcReserves, amount);

        require(0 < amountToSwap, "Nothing to swap");

        maiAmount = _swapUSDCtoMAI(amountToSwap);
        usdcAmount = amount - amountToSwap;
    }

    /**
     * Given a USDC token amount and a MAI token amount, swap MAIs into USDCs and consolidate
     *
     * @param amount  Number of USDC tokens to consolidate with
     * @param maiAmount  Number of MAI tokens to consolidate in
     * @return usdcAmount  Consolidated USDC amount
     */
    function _unsplitUSDC(uint256 amount, uint256 maiAmount) internal returns (uint256 usdcAmount) {
        usdcAmount = amount + _swapMAItoUSDC(maiAmount);
    }

    /**
     * Add liquidity to the QuickSwap Liquidity Pool, as much as indicated by the given pair od USDC/MAI amounts
     *
     * @param usdcAmount  Number of USDC tokens to add
     * @param maiAmount  Number of MAI tokens to add
     * @return lpAmount  Number of LP USDC/MAI tokens obtained
     */
    function _addLiquidity(uint256 usdcAmount, uint256 maiAmount) internal returns (uint256 lpAmount) {
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

    /**
     * Remove liquidity from the QuickSwap Liquidity Pool, as much as indicated by the given amount of LP tokens
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to withdraw
     * @return usdcAmount  Number of USDC tokens withdrawn
     * @return maiAmount  Number of MAI tokens withdrawn
     */
    function _removeLiquidity(uint256 lpAmount) internal returns (uint256 usdcAmount, uint256 maiAmount) {
        (usdcAmount, maiAmount) = IUniswapV2Router02(quickSwapRouterAddress).removeLiquidity(
            usdcAddress,
            maiAddress,
            lpAmount,
            1,
            1,
            address(this),
            block.timestamp + 3600
        );
    }

    /**
     * Deposit the given number of LP tokens into QiDao's Farm
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to deposit into QiDao's Farm
     */
    function _stakeLP(uint256 lpAmount) internal {
        IERC20(lpAddress).approve(qiDaoFarmAddress, lpAmount);
        IFarm(qiDaoFarmAddress).deposit(qiDaoPoolId, lpAmount);
    }

    /**
     * Remove the given number of LP tokens from QiDao's Farm
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to remove from QiDao's Farm
     */
    function _unstakeLP(uint256 lpAmount) internal {
        IFarm(qiDaoFarmAddress).withdraw(qiDaoPoolId, lpAmount);
    }

    /**
     * Return the rewards accrued by staking LP USDC/MAI tokens in QiDao's Farm (in QI tokens)
     *
     * @return qiAmount  Number of QI tokens accrued
     */
    function _getPendingRewardsAmount() internal view returns (uint256 qiAmount) {
        // Get rewards on Farm
        qiAmount = IFarm(qiDaoFarmAddress).pending(qiDaoPoolId, address(this));
    }

    /**
     * Swap the given number of MAI tokens to USDC
     *
     * @param maiAmount  Number of MAI tokens to swap
     * @return usdcAmount  Number of USDC tokens obtained
     */
    function _swapMAItoUSDC(uint256 maiAmount) internal returns (uint256 usdcAmount) {
        usdcAmount = _swapTokens(maiAddress, usdcAddress, maiAmount);
    }

    /**
     * Swap the given number of USDC tokens to MAI
     *
     * @param usdcAmount  Number of USDC tokens to swap
     * @return maiAmount  Number of MAI tokens obtained
     */
    function _swapUSDCtoMAI(uint256 usdcAmount) internal returns (uint256 maiAmount) {
        maiAmount = _swapTokens(usdcAddress, maiAddress, usdcAmount);
    }

    /**
     * Swap the given number of QI tokens to USDC
     *
     * @param qiAmount  Number of QI tokens to swap
     * @return usdcAmount  Number of USDC tokens obtained
     */
    function _swapQItoUSDC(uint256 qiAmount) internal returns (uint256 usdcAmount) {
        usdcAmount = _swapTokens(qiAddress, usdcAddress, qiAmount);
    }

    /**
     * Swap the given amount of tokens from the given "from" address to the given "to" address via QuickSwap, and return the amount of "to" tokens swapped
     *
     * @param fromAddress  Address to get swap tokens from
     * @param toAddress  Address to get swap tokens to
     * @param amount  Amount of tokens to swap (from)
     * @return swappedAmount  Amount of tokens deposited in addressTo
     */
    function _swapTokens(
        address fromAddress,
        address toAddress,
        uint256 amount
    ) internal returns (uint256 swappedAmount) {
        address[] memory path = new address[](2);
        (path[0], path[1]) = (fromAddress, toAddress);

        swappedAmount = IUniswapV2Router02(quickSwapRouterAddress).swapExactTokensForTokens(amount, 1, path, address(this), block.timestamp + 3600)[1];
    }

    // --------------------------------------------------------------------------------------------------------------------------------------------------------
    // --- UniSwap Simulation ---------------------------------------------------------------------------------------------------------------------------------
    // --------------------------------------------------------------------------------------------------------------------------------------------------------

    function _calculateSwapInAmount(uint256 reserveIn, uint256 userIn) internal pure returns (uint256 amount) {
        amount = (sqrt256(reserveIn * ((userIn * 3988000) + (reserveIn * 3988009))) - (reserveIn * 1997)) / 1994;
    }

    //**  UNISWAP Library Functions Below **/
    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT"); // solhint-disable-line reason-string
        require(reserveIn > 0 && reserveOut > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY"); // solhint-disable-line reason-string
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
