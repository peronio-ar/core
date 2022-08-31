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
import {IERC20Uniswap} from "./uniswap/interfaces/IERC20Uniswap.sol";
import {IUniswapV2Pair} from "./uniswap/interfaces/IUniswapV2Pair.sol";
import {IUniswapV2Router02} from "./uniswap/interfaces/IUniswapV2Router02.sol";

// Needed for Babylonian square-root & combined-multiplication-and-division
import {max, min, mulDiv, sqrt256} from "./Utils.sol";

// Interface
import "./IPeronio.sol";

// User-defined value types --- implementation-specific
import "./PeronioSupport.sol";

contract Peronio is IPeronio, ERC20, ERC20Burnable, ERC20Permit, AccessControl, ReentrancyGuard {
    using SafeERC20 for IERC20;

    // Roles
    RoleId public constant override MARKUP_ROLE = RoleId.wrap(keccak256("MARKUP_ROLE"));
    RoleId public constant override REWARDS_ROLE = RoleId.wrap(keccak256("REWARDS_ROLE"));
    RoleId public constant override MIGRATOR_ROLE = RoleId.wrap(keccak256("MIGRATOR_ROLE"));

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

    // Rational constant one
    RatioWith6Decimals private constant ONE = RatioWith6Decimals.wrap(10**DECIMALS);

    // Fees
    RatioWith6Decimals public override markupFee = RatioWith6Decimals.wrap(50000); // 5.00%
    RatioWith6Decimals public override swapFee = RatioWith6Decimals.wrap(1500); // 0.15%

    // Initialization can only be run once
    bool public override initialized;

    /**
     * Allow execution by the default admin only
     *
     */
    modifier onlyAdminRole() {
        _checkRole(DEFAULT_ADMIN_ROLE);
        _;
    }

    /**
     * Allow execution by the markup-setter only
     *
     */
    modifier onlyMarkupRole() {
        _checkRole(RoleId.unwrap(MARKUP_ROLE));
        _;
    }

    /**
     * Allow execution by the rewards-reaper only
     *
     */
    modifier onlyRewardsRole() {
        _checkRole(RoleId.unwrap(REWARDS_ROLE));
        _;
    }

    /**
     * Allow execution by the migrator only
     *
     */
    modifier onlyMigratorRole() {
        _checkRole(RoleId.unwrap(MIGRATOR_ROLE));
        _;
    }

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
     * @param _lpAddress  LP Address for MAI/USDC
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
        // --- Gas Saving -------------------------------------------------------------------------
        address sender = _msgSender();

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
        _setupRole(DEFAULT_ADMIN_ROLE, sender);
        _setupRole(RoleId.unwrap(MARKUP_ROLE), sender);
        _setupRole(RoleId.unwrap(REWARDS_ROLE), sender);
        _setupRole(RoleId.unwrap(MIGRATOR_ROLE), sender);
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
    function setMarkupFee(RatioWith6Decimals newMarkupFee) external override onlyMarkupRole returns (RatioWith6Decimals prevMarkupFee) {
        (prevMarkupFee, markupFee) = (markupFee, newMarkupFee);

        emit MarkupFeeUpdated(_msgSender(), newMarkupFee);
    }

    // --- Initialization -------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Initialize the PE token by providing collateral USDC tokens - initial conversion rate will be set at the given starting ratio
     *
     * @param usdcAmount  Number of collateral USDC tokens
     * @param startingRatio  Initial minting ratio in PE tokens per USDC tokens minted (including DECIMALS)
     * @custom:emit  Initialized
     */
    function initialize(UsdcQuantity usdcAmount, PePerUsdcQuantity startingRatio) external override onlyAdminRole {
        // Prevent double initialization
        require(!initialized, "Contract already initialized");
        initialized = true;

        // --- Gas Saving -------------------------------------------------------------------------
        IERC20 maiERC20 = IERC20(maiAddress);
        IERC20 usdcERC20 = IERC20(usdcAddress);
        IERC20 lpERC20 = IERC20(lpAddress);
        IERC20 qiERC20 = IERC20(qiAddress);
        address sender = _msgSender();
        address _quickSwapRouterAddress = quickSwapRouterAddress;
        uint256 maxVal = type(uint256).max;

        // Transfer initial USDC amount from user to current contract
        usdcERC20.safeTransferFrom(sender, address(this), UsdcQuantity.unwrap(usdcAmount));

        // Unlimited ERC20 approval for Router
        maiERC20.approve(_quickSwapRouterAddress, maxVal);
        usdcERC20.approve(_quickSwapRouterAddress, maxVal);
        lpERC20.approve(_quickSwapRouterAddress, maxVal);
        qiERC20.approve(_quickSwapRouterAddress, maxVal);

        // Commit the complete initial USDC amount
        _zapIn(usdcAmount);
        usdcAmount = _stakedValue();

        // Mints exactly startingRatio for each collateral USDC token
        _mint(sender, PeQuantity.unwrap(mulDiv(usdcAmount, startingRatio, ONE)));

        emit Initialized(sender, usdcAmount, startingRatio);
    }

    // --- State views ----------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function getLpReserves() external view override returns (UsdcQuantity usdcReserves, MaiQuantity maiReserves) {
        (usdcReserves, maiReserves) = _getLpReserves();
    }

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function stakedBalance() external view override returns (LpQuantity lpAmount) {
        lpAmount = _stakedBalance();
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function stakedTokens() external view override returns (UsdcQuantity usdcAmount, MaiQuantity maiAmount) {
        (usdcAmount, maiAmount) = _stakedTokens();
    }

    /**
     * Return the equivalent number of USDC tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Total equivalent number of USDC token on stake
     */
    function stakedValue() external view override returns (UsdcQuantity usdcAmount) {
        usdcAmount = _stakedValue();
    }

    /**
     * Return the _collateralized_ price in USDC tokens per PE token
     *
     * @return price  Collateralized price in USDC tokens per PE token
     */
    function usdcPrice() external view override returns (PePerUsdcQuantity price) {
        price = mulDiv(ONE, PeQuantity.wrap(totalSupply()), _stakedValue());
    }

    /**
     * Return the effective _minting_ price in USDC tokens per PE token
     *
     * @return price  Minting price in USDC tokens per PE token
     */
    function buyingPrice() external view override returns (UsdcPerPeQuantity price) {
        price = mulDiv(_collateralRatio(), add(ONE, markupFee), ONE);
    }

    /**
     * Return the ratio of total number of USDC tokens per PE token
     *
     * @return ratio  Ratio of USDC tokens per PE token, with `_decimal` decimals
     */
    function collateralRatio() external view override returns (UsdcPerPeQuantity ratio) {
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
        UsdcQuantity usdcAmount,
        PeQuantity minReceive
    ) external override nonReentrant returns (PeQuantity peAmount) {
        peAmount = _mintPe(to, usdcAmount, minReceive, markupFee);
    }

    /**
     * Mint PE tokens using the provided USDC tokens as collateral --- used by the migrators in order not to incur normal fees
     *
     * @param to  The address to transfer the minted PE tokens to
     * @param usdcAmount  Number of USDC tokens to use as collateral
     * @param minReceive  The minimum number of PE tokens to mint
     * @return peAmount  The number of PE tokens actually minted
     * @custom:emit  Minted
     */
    function mintForMigration(
        address to,
        UsdcQuantity usdcAmount,
        PeQuantity minReceive
    ) external override nonReentrant onlyMigratorRole returns (PeQuantity peAmount) {
        peAmount = _mintPe(to, usdcAmount, minReceive, RatioWith6Decimals.wrap(0));
    }

    /**
     * Extract the given number of PE tokens as USDC tokens
     *
     * @param to  Address to deposit extracted USDC tokens into
     * @param peAmount  Number of PE tokens to withdraw
     * @return usdcTotal  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     */
    function withdraw(address to, PeQuantity peAmount) external override nonReentrant returns (UsdcQuantity usdcTotal) {
        // --- Gas Saving -------------------------------------------------------------------------
        address sender = _msgSender();

        // Calculate equivalent number of LP USDC/MAI tokens for the given burnt PE tokens
        LpQuantity lpAmount = mulDiv(peAmount, _stakedBalance(), PeQuantity.wrap(totalSupply()));

        // Extract the given number of LP USDC/MAI tokens as USDC tokens
        usdcTotal = _zapOut(lpAmount);

        // Transfer USDC tokens the the given address
        IERC20(usdcAddress).safeTransfer(to, UsdcQuantity.unwrap(usdcTotal));

        // Burn the given number of PE tokens
        _burn(sender, PeQuantity.unwrap(peAmount));

        emit Withdrawal(sender, usdcTotal, peAmount);
    }

    /**
     * Extract the given number of PE tokens as LP USDC/MAI tokens
     *
     * @param to  Address to deposit extracted LP USDC/MAI tokens into
     * @param peAmount  Number of PE tokens to withdraw liquidity for
     * @return lpAmount  Number of LP USDC/MAI tokens extracted
     * @custom:emit LiquidityWithdrawal
     */
    function withdrawLiquidity(address to, PeQuantity peAmount) external override nonReentrant returns (LpQuantity lpAmount) {
        // --- Gas Saving -------------------------------------------------------------------------
        address sender = _msgSender();

        // Calculate equivalent number of LP USDC/MAI tokens for the given burnt PE tokens
        lpAmount = mulDiv(peAmount, _stakedBalance(), PeQuantity.wrap(totalSupply()));

        // Get LP USDC/MAI tokens out of QiDao's Farm
        _unstakeLP(lpAmount);

        // Transfer LP USDC/MAI tokens to the given address
        IERC20(lpAddress).safeTransfer(to, LpQuantity.unwrap(lpAmount));

        // Burn the given number of PE tokens
        _burn(sender, PeQuantity.unwrap(peAmount));

        emit LiquidityWithdrawal(sender, lpAmount, peAmount);
    }

    // --- Rewards --------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the rewards accrued by staking LP USDC/MAI tokens in QiDao's Farm (in QI tokens)
     *
     * @return qiAmount  Number of QI tokens accrued
     */
    function getPendingRewardsAmount() external view override returns (QiQuantity qiAmount) {
        qiAmount = _getPendingRewardsAmount();
    }

    /**
     * Claim QiDao's QI token rewards, and re-invest them in the QuickSwap liquidity pool and QiDao's Farm
     *
     * @return usdcAmount  The number of USDC tokens being re-invested
     * @return lpAmount  The number of LP USDC/MAI tokens being put on stake
     * @custom:emit CompoundRewards
     */
    function compoundRewards() external override onlyRewardsRole returns (UsdcQuantity usdcAmount, LpQuantity lpAmount) {
        // Claim rewards from QiDao's Farm
        IFarm(qiDaoFarmAddress).deposit(qiDaoPoolId, 0);

        // Retrieve the number of QI tokens rewarded and swap them to USDC tokens
        QiQuantity amount = QiQuantity.wrap(IERC20(qiAddress).balanceOf(address(this)));
        _swapTokens(amount);

        // Commit all USDC tokens so converted to the QuickSwap liquidity pool
        usdcAmount = UsdcQuantity.wrap(IERC20(usdcAddress).balanceOf(address(this)));
        lpAmount = _zapIn(usdcAmount);

        emit CompoundRewards(amount, usdcAmount, lpAmount);
    }

    // --- Quotes ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Retrieve the expected number of PE tokens corresponding to the given number of USDC tokens for minting.
     *
     * @dev This method was obtained by _inlining_ the call to mint() across contracts, and cleaning up the result.
     *
     * @param usdc  Number of USDC tokens to quote for
     * @return pe  Number of PE tokens quoted for the given number of USDC tokens
     */
    function quoteIn(UsdcQuantity usdc) external view override returns (PeQuantity pe) {
        // --- Gas Saving -------------------------------------------------------------------------
        address _lpAddress = lpAddress;

        // retrieve LP state (simulations will modify these)
        (UsdcQuantity usdcReserves, MaiQuantity maiReserves) = _getLpReserves();
        LpQuantity lpTotalSupply = LpQuantity.wrap(IERC20(_lpAddress).totalSupply());

        // -- SPLIT -------------------------------------------------------------------------------
        UsdcQuantity usdcAmount = _calculateSwapInAmount(usdcReserves, usdc);
        MaiQuantity maiAmount = _getAmountOut(usdcAmount, usdcReserves, maiReserves);

        // simulate LP state update
        usdcReserves = add(usdcReserves, usdcAmount);
        maiReserves = subtract(maiReserves, maiAmount);

        // -- SWAP --------------------------------------------------------------------------------

        // calculate actual values swapped
        {
            MaiQuantity amountMaiOptimal = mulDiv(subtract(usdc, usdcAmount), maiReserves, usdcReserves);
            if (lte(amountMaiOptimal, maiAmount)) {
                (usdcAmount, maiAmount) = (subtract(usdc, usdcAmount), amountMaiOptimal);
            } else {
                UsdcQuantity amountUsdcOptimal = mulDiv(maiAmount, usdcReserves, maiReserves);
                (usdcAmount, maiAmount) = (amountUsdcOptimal, maiAmount);
            }
        }

        // deal with LP minting when changing its K
        {
            UniSwapRootKQuantity rootK = sqrt256(prod(usdcReserves, maiReserves));
            UniSwapRootKQuantity rootKLast = sqrt256(UniSwapKQuantity.wrap(IUniswapV2Pair(_lpAddress).kLast()));
            if (lt(rootKLast, rootK)) {
                lpTotalSupply = add(lpTotalSupply, mulDiv(lpTotalSupply, subtract(rootK, rootKLast), add(prod(rootK, 5), rootKLast)));
            }
        }

        // calculate LP values actually provided
        LpQuantity zapInLps;
        {
            LpQuantity maiCandidate = mulDiv(maiAmount, lpTotalSupply, maiReserves);
            LpQuantity usdcCandidate = mulDiv(usdcAmount, lpTotalSupply, usdcReserves);
            zapInLps = min(maiCandidate, usdcCandidate);
        }

        // -- PERONIO -----------------------------------------------------------------------------
        LpQuantity lpAmount = mulDiv(zapInLps, subtract(ONE, _totalMintFee(markupFee)), ONE);
        pe = mulDiv(lpAmount, PeQuantity.wrap(totalSupply()), _stakedBalance());
    }

    /**
     * Retrieve the expected number of USDC tokens corresponding to the given number of PE tokens for withdrawal.
     *
     * @dev This method was obtained by _inlining_ the call to withdraw() across contracts, and cleaning up the result.
     *
     * @param pe  Number of PE tokens to quote for
     * @return usdc  Number of USDC tokens quoted for the given number of PE tokens
     */
    function quoteOut(PeQuantity pe) external view override returns (UsdcQuantity usdc) {
        // --- Gas Saving -------------------------------------------------------------------------
        address _lpAddress = lpAddress;

        (UsdcQuantity usdcReserves, MaiQuantity maiReserves) = _getLpReserves();
        LpQuantity lpTotalSupply = LpQuantity.wrap(IERC20(_lpAddress).totalSupply());

        // deal with LP minting when changing its K
        {
            UniSwapRootKQuantity rootK = sqrt256(prod(usdcReserves, maiReserves));
            UniSwapRootKQuantity rootKLast = sqrt256(UniSwapKQuantity.wrap(IUniswapV2Pair(_lpAddress).kLast()));
            if (lt(rootKLast, rootK)) {
                lpTotalSupply = add(lpTotalSupply, mulDiv(lpTotalSupply, subtract(rootK, rootKLast), add(prod(rootK, 5), rootKLast)));
            }
        }

        // calculate LP values actually withdrawn
        LpQuantity lpAmount = add(
            LpQuantity.wrap(IERC20Uniswap(_lpAddress).balanceOf(_lpAddress)),
            mulDiv(pe, _stakedBalance(), PeQuantity.wrap(totalSupply()))
        );

        UsdcQuantity usdcAmount = mulDiv(usdcReserves, lpAmount, lpTotalSupply);
        MaiQuantity maiAmount = mulDiv(maiReserves, lpAmount, lpTotalSupply);

        usdc = add(usdcAmount, _getAmountOut(maiAmount, subtract(maiReserves, maiAmount), subtract(usdcReserves, usdcAmount)));
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
    function _getLpReserves() internal view returns (UsdcQuantity usdcReserves, MaiQuantity maiReserves) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(lpAddress).getReserves();
        (usdcReserves, maiReserves) = usdcAddress < maiAddress
            ? (UsdcQuantity.wrap(reserve0), MaiQuantity.wrap(reserve1))
            : (UsdcQuantity.wrap(reserve1), MaiQuantity.wrap(reserve0));
    }

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function _stakedBalance() internal view returns (LpQuantity lpAmount) {
        lpAmount = LpQuantity.wrap(IFarm(qiDaoFarmAddress).deposited(qiDaoPoolId, address(this)));
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function _stakedTokens() internal view returns (UsdcQuantity usdcAmount, MaiQuantity maiAmount) {
        LpQuantity lpAmount = _stakedBalance();
        LpQuantity lpTotalSupply = LpQuantity.wrap(IERC20(lpAddress).totalSupply());

        (UsdcQuantity usdcReserves, MaiQuantity maiReserves) = _getLpReserves();

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
    function _stakedValue() internal view returns (UsdcQuantity totalUSDC) {
        (UsdcQuantity usdcReserves, MaiQuantity maiReserves) = _getLpReserves();
        (UsdcQuantity usdcAmount, MaiQuantity maiAmount) = _stakedTokens();

        // Simulate Swap
        totalUSDC = add(usdcAmount, _getAmountOut(maiAmount, maiReserves, usdcReserves));
    }

    /**
     * Return the ratio of total number of USDC tokens per PE token
     *
     * @return ratio  Ratio of USDC tokens per PE token, with `_decimal` decimals
     */
    function _collateralRatio() internal view returns (UsdcPerPeQuantity ratio) {
        ratio = mulDiv(ONE, _stakedValue(), PeQuantity.wrap(totalSupply()));
    }

    /**
     * Return the total minting fee to apply
     *
     * @return totalFee  The total fee to apply on minting
     */
    function _totalMintFee(RatioWith6Decimals _markupFee) internal view returns (RatioWith6Decimals totalFee) {
        // Retrieve the deposit fee from QiDao's Farm (this is always expressed with 4 decimals, as "basic points")
        // Convert these "basic points" to `DECIMALS` precision
        (, , , , uint16 depositFeeBP) = IFarm(qiDaoFarmAddress).poolInfo(qiDaoPoolId);
        RatioWith6Decimals depositFee = ratio4to6(RatioWith4Decimals.wrap(depositFeeBP));

        // Calculate total fee to apply
        // (ie. the swapFee and the depositFee are included in the total markup fee, thus, we don't double charge for both the markup fee itself
        // and the swap and deposit fees)
        totalFee = max(_markupFee, add(swapFee, depositFee));
    }

    /**
     * Actually mint PE tokens using the provided USDC tokens as collateral, applying the given markup fee
     *
     * @param to  The address to transfer the minted PE tokens to
     * @param usdcAmount  Number of USDC tokens to use as collateral
     * @param minReceive  The minimum number of PE tokens to mint
     * @param _markupFee  The markup fee to apply
     * @return peAmount  The number of PE tokens actually minted
     * @custom:emit  Minted
     */
    function _mintPe(
        address to,
        UsdcQuantity usdcAmount,
        PeQuantity minReceive,
        RatioWith6Decimals _markupFee
    ) internal returns (PeQuantity peAmount) {
        // --- Gas Saving -------------------------------------------------------------------------
        address sender = _msgSender();

        // Transfer USDC tokens as collateral to this contract
        IERC20(usdcAddress).safeTransferFrom(sender, address(this), UsdcQuantity.unwrap(usdcAmount));

        // Remember the previously staked balance
        LpQuantity stakedAmount = _stakedBalance();

        // Commit USDC tokens, and discount fees totalling the markup fee
        LpQuantity lpAmount = mulDiv(_zapIn(usdcAmount), subtract(ONE, _totalMintFee(_markupFee)), ONE);

        // Calculate the number of PE tokens as the proportion of liquidity provided
        peAmount = mulDiv(lpAmount, PeQuantity.wrap(totalSupply()), stakedAmount);

        require(lte(minReceive, peAmount), "Minimum required not met");

        // Actually mint the PE tokens
        _mint(to, PeQuantity.unwrap(peAmount));

        emit Minted(sender, usdcAmount, peAmount);
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
    function _zapIn(UsdcQuantity usdcAmount) internal returns (LpQuantity lpAmount) {
        MaiQuantity maiAmount;

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
    function _zapOut(LpQuantity lpAmount) internal returns (UsdcQuantity usdcAmount) {
        MaiQuantity maiAmount;

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
    function _splitUSDC(UsdcQuantity amount) internal returns (UsdcQuantity usdcAmount, MaiQuantity maiAmount) {
        (UsdcQuantity usdcReserves, ) = _getLpReserves();
        UsdcQuantity amountToSwap = _calculateSwapInAmount(usdcReserves, amount);

        require(lt(UsdcQuantity.wrap(0), amountToSwap), "Nothing to swap");

        maiAmount = _swapTokens(amountToSwap);
        usdcAmount = subtract(amount, amountToSwap);
    }

    /**
     * Given a USDC token amount and a MAI token amount, swap MAIs into USDCs and consolidate
     *
     * @param amount  Number of USDC tokens to consolidate with
     * @param maiAmount  Number of MAI tokens to consolidate in
     * @return usdcAmount  Consolidated USDC amount
     */
    function _unsplitUSDC(UsdcQuantity amount, MaiQuantity maiAmount) internal returns (UsdcQuantity usdcAmount) {
        usdcAmount = add(amount, _swapTokens(maiAmount));
    }

    /**
     * Add liquidity to the QuickSwap Liquidity Pool, as much as indicated by the given pair od USDC/MAI amounts
     *
     * @param usdcAmount  Number of USDC tokens to add
     * @param maiAmount  Number of MAI tokens to add
     * @return lpAmount  Number of LP USDC/MAI tokens obtained
     */
    function _addLiquidity(UsdcQuantity usdcAmount, MaiQuantity maiAmount) internal returns (LpQuantity lpAmount) {
        (, , uint256 _lpAmount) = IUniswapV2Router02(quickSwapRouterAddress).addLiquidity(
            usdcAddress,
            maiAddress,
            UsdcQuantity.unwrap(usdcAmount),
            MaiQuantity.unwrap(maiAmount),
            1,
            1,
            address(this),
            block.timestamp + 3600
        );
        lpAmount = LpQuantity.wrap(_lpAmount);
    }

    /**
     * Remove liquidity from the QuickSwap Liquidity Pool, as much as indicated by the given amount of LP tokens
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to withdraw
     * @return usdcAmount  Number of USDC tokens withdrawn
     * @return maiAmount  Number of MAI tokens withdrawn
     */
    function _removeLiquidity(LpQuantity lpAmount) internal returns (UsdcQuantity usdcAmount, MaiQuantity maiAmount) {
        (uint256 _usdcAmount, uint256 _maiAmount) = IUniswapV2Router02(quickSwapRouterAddress).removeLiquidity(
            usdcAddress,
            maiAddress,
            LpQuantity.unwrap(lpAmount),
            1,
            1,
            address(this),
            block.timestamp + 3600
        );
        (usdcAmount, maiAmount) = (UsdcQuantity.wrap(_usdcAmount), MaiQuantity.wrap(_maiAmount));
    }

    /**
     * Deposit the given number of LP tokens into QiDao's Farm
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to deposit into QiDao's Farm
     */
    function _stakeLP(LpQuantity lpAmount) internal {
        // --- Gas Saving -------------------------------------------------------------------------
        address _qiDaoFarmAddress = qiDaoFarmAddress;

        IERC20(lpAddress).approve(_qiDaoFarmAddress, LpQuantity.unwrap(lpAmount));
        IFarm(_qiDaoFarmAddress).deposit(qiDaoPoolId, LpQuantity.unwrap(lpAmount));
    }

    /**
     * Remove the given number of LP tokens from QiDao's Farm
     *
     * @param lpAmount  Number of LP USDC/MAI tokens to remove from QiDao's Farm
     */
    function _unstakeLP(LpQuantity lpAmount) internal {
        IFarm(qiDaoFarmAddress).withdraw(qiDaoPoolId, LpQuantity.unwrap(lpAmount));
    }

    /**
     * Return the rewards accrued by staking LP USDC/MAI tokens in QiDao's Farm (in QI tokens)
     *
     * @return qiAmount  Number of QI tokens accrued
     */
    function _getPendingRewardsAmount() internal view returns (QiQuantity qiAmount) {
        // Get rewards on Farm
        qiAmount = QiQuantity.wrap(IFarm(qiDaoFarmAddress).pending(qiDaoPoolId, address(this)));
    }

    /**
     * Swap the given number of MAI tokens to USDC
     *
     * @param maiAmount  Number of MAI tokens to swap
     * @return usdcAmount  Number of USDC tokens obtained
     */
    function _swapTokens(MaiQuantity maiAmount) internal returns (UsdcQuantity usdcAmount) {
        usdcAmount = UsdcQuantity.wrap(_swapTokens(maiAddress, usdcAddress, MaiQuantity.unwrap(maiAmount)));
    }

    /**
     * Swap the given number of USDC tokens to MAI
     *
     * @param usdcAmount  Number of USDC tokens to swap
     * @return maiAmount  Number of MAI tokens obtained
     */
    function _swapTokens(UsdcQuantity usdcAmount) internal returns (MaiQuantity maiAmount) {
        maiAmount = MaiQuantity.wrap(_swapTokens(usdcAddress, maiAddress, UsdcQuantity.unwrap(usdcAmount)));
    }

    /**
     * Swap the given number of QI tokens to USDC
     *
     * @param qiAmount  Number of QI tokens to swap
     * @return usdcAmount  Number of USDC tokens obtained
     */
    function _swapTokens(QiQuantity qiAmount) internal returns (UsdcQuantity usdcAmount) {
        usdcAmount = UsdcQuantity.wrap(_swapTokens(qiAddress, usdcAddress, QiQuantity.unwrap(qiAmount)));
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

    function _calculateSwapInAmount(UsdcQuantity reserveIn, UsdcQuantity userIn) internal pure returns (UsdcQuantity amount) {
        amount = subtract(sqrt256(mulDiv(add(prod(3988009, reserveIn), prod(3988000, userIn)), reserveIn, 3976036)), mulDiv(reserveIn, 1997, 1994));
    }

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 997;
        amountOut = mulDiv(amountInWithFee, reserveOut, reserveIn * 1000 + amountInWithFee);
    }

    function _getAmountOut(
        MaiQuantity amountIn,
        MaiQuantity reserveIn,
        UsdcQuantity reserveOut
    ) internal pure returns (UsdcQuantity) {
        return UsdcQuantity.wrap(_getAmountOut(MaiQuantity.unwrap(amountIn), MaiQuantity.unwrap(reserveIn), UsdcQuantity.unwrap(reserveOut)));
    }

    function _getAmountOut(
        UsdcQuantity amountIn,
        UsdcQuantity reserveIn,
        MaiQuantity reserveOut
    ) internal pure returns (MaiQuantity amountOut) {
        return MaiQuantity.wrap(_getAmountOut(UsdcQuantity.unwrap(amountIn), UsdcQuantity.unwrap(reserveIn), MaiQuantity.unwrap(reserveOut)));
    }
}
