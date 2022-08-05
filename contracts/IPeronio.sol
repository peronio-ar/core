// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IPeronio {

    // --- Events ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Emitted upon initialization of the Peronio contract
     *
     * @param owner  The address initializing the contract
     * @param collateral  The number of USDC tokens used as collateral
     * @param startingRatio  The number of PE tokens per USDC token the vault is initialized with
     */
    event Initialized(address owner, uint256 collateral, uint256 startingRatio);

    /**
     * Emitted upon minting PE tokens
     *
     * @param to  The address where minted PE tokens get transferred to
     * @param collateralAmount  The number of USDC tokens used as collateral in this minting
     * @param tokenAmount  Amount of PE tokens minted
     */
    event Minted(address indexed to, uint256 collateralAmount, uint256 tokenAmount);

    /**
     * Emitted upon collateral withdrawal
     *
     * @param to  Address where the USDC token withdrawal is directed
     * @param collateralAmount  The number of USDC tokens withdrawn
     * @param tokenAmount  The number of PE tokens burnt
     */
    event Withdrawal(address indexed to, uint256 collateralAmount, uint256 tokenAmount);

    /**
     * Emitted upon liquidity withdrawal
     *
     * @param to  Address where the USDC token withdrawal is directed
     * @param lpAmount  The number of LP USDC/MAI tokens withdrawn
     * @param tokenAmount  The number of PE tokens burnt
     */
    event LiquidityWithdrawal(address indexed to, uint256 lpAmount, uint256 tokenAmount);

    /**
     * Emitted upon the markup fee being updated
     *
     * @param operator  Address of the one updating the markup fee
     * @param markup  New markup fee
     */
    event MarkupUpdated(address operator, uint256 markup);

    /**
     * Emitted upon compounding rewards from QiDao's Farm back into the vault
     *
     * @param qi  Number of awarded QI tokens
     * @param usdc  Equivalent number of USDC tokens
     * @param lp  Number of LP USDC/MAI tokens re-invested
     */
    event CompoundRewards(uint256 qi, uint256 usdc, uint256 lp);

    // --- Roles - Automatic ----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the hash identifying the role responsible for updating the markup fee
     *
     * @return roleId  The role hash in question
     */
    function MARKUP_ROLE() external view returns (bytes32 roleId);  // solhint-disable-line func-name-mixedcase

    /**
     * Return the hash identifying the role responsible for compounding rewards
     *
     * @return roleId  The role hash in question
     */
    function REWARDS_ROLE() external view returns (bytes32 roleId);  // solhint-disable-line func-name-mixedcase

    // --- Addresses - Automatic ------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the address used for the USDC tokens in vault
     *
     * @return  The address in question
     */
    function usdcAddress() external view returns (address);

    /**
     * Return the address used for the MAI tokens in vault
     *
     * @return  The address in question
     */
    function maiAddress() external view returns (address);

    /**
     * Return the address used for the LP USDC/MAI tokens in vault
     *
     * @return  The address in question
     */
    function lpAddress() external view returns (address);

    /**
     * Return the address used for the QI tokens in vault
     *
     * @return  The address in question
     */
    function qiAddress() external view returns (address);

    /**
     * Return the address of the QuickSwap Router to talk to
     *
     * @return  The address in question
     */
    function quickSwapRouterAddress() external view returns (address);

    /**
     * Return the address of the QiDao Farm to use
     *
     * @return  The address in question
     */
    function qiDaoFarmAddress() external view returns (address);

    /**
     * Return the pool ID within the QiDao Farm
     *
     * @return  The pool ID in question
     */
    function qiDaoPoolId() external view returns (uint256);

    // --- Fees - Automatic -----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the number of decimals the markup and swap fees are internally expressed with
     *
     * @return  Always 5
     */
    function markupDecimals() external view returns (uint8);

    /**
     * Return the markup fee the use, using `markupDecimals()` decimals implicitly
     *
     * @return  The markup fee to use
     */
    function markup() external view returns (uint256);

    /**
     * Return the swap fee the use, using `markupDecimals()` decimals implicitly
     *
     * @return  The swap fee to use
     */
    function swapFee() external view returns (uint256);

    // --- Status - Automatic ---------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return wether the Peronio contract has been initialized yet
     *
     * @return  True whenever the contract has already been initialized, false otherwise
     */
    function initialized() external view returns (bool);

    // --- Decimals -------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the number of decimals the PE token will work with
     *
     * @return decimals_  This will always be 6
     */
    function decimals() external view returns (uint8 decimals_);

    // --- Markup change --------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Set the markup fee to the given value (take into account that this will use `markupDecimals` decimals implicitly)
     *
     * @param newMarkup  New markup fee value
     * @return prevMarkup  Previous markup fee value
     * @custom:emit  MarkupUpdated
     */
    function setMarkup(uint256 newMarkup) external returns (uint256 prevMarkup);

    // --- Initialization -------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Initialize the PE token by providing collateral USDC tokens - initial conversion rate will be set at the given starting ratio
     *
     * @param usdcAmount  Number of collateral USDC tokens
     * @param startingRatio  Initial minting ratio in PE tokens per USDC tokens minted
     * @custom:emit  Initialized
     */
    function initialize(uint256 usdcAmount, uint256 startingRatio) external;

    // --- State views ----------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function getLpReserves() external view returns (uint256 usdcReserves, uint256 maiReserves);

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function stakedBalance() external view returns (uint256 lpAmount);

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function stakedTokens() external view returns (uint256 usdcAmount, uint256 maiAmount);

    /**
     * Return the equivalent number of USDC tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Total equivalent number of USDC token on stake
     */
    function stakedValue() external view returns (uint256 usdcAmount);

    /**
     * Return the _collateralized_ price in USDT tokens per PE token
     *
     * @return price  Collateralized price in USDT tokens per PE token
     */
    function usdcPrice() external view returns (uint256 price);

    /**
     * Return the effective _minting_ price in USDC tokens per PE token
     *
     * @return price  Minting price in USDT tokens per PE token
     */
    function buyingPrice() external view returns (uint256 price);

    /**
     * Return the ratio of total number of USDC tokens per PE token
     *
     * @return ratio  Ratio of USDC tokens per PE token, with `_decimal` decimals
     */
    function collateralRatio() external view returns (uint256 ratio);

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
    function mint(address to, uint256 usdcAmount, uint256 minReceive) external returns (uint256 peAmount);

    /**
     * Extract the given number of PE tokens as USDC tokens
     *
     * @param to  Address to deposit extracted USDC tokens into
     * @param peAmount  Number of PE tokens to withdraw
     * @return usdcTotal  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     */
    function withdraw(address to, uint256 peAmount) external returns (uint256 usdcTotal);

    /**
     * Extract the given number of PE tokens as LP USDC/MAI tokens
     *
     * @param to  Address to deposit extracted LP USDC/MAI tokens into
     * @param peAmount  Number of PE tokens to withdraw liquidity for
     * @return lpAmount  Number of LP USDC/MAI tokens extracted
     * @custom:emit LiquidityWithdrawal
     */
    function withdrawLiquidity(address to, uint256 peAmount) external returns (uint256 lpAmount);

    // --- Rewards --------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the rewards accrued by staking LP USDC/MAI tokens in QiDao's Farm (in QI tokens)
     *
     * @return qiAmount  Number of QI tokens accrued
     */
    function getPendingRewardsAmount() external view returns (uint256 qiAmount);

    /**
     * Claim QiDao's QI token rewards, and re-invest them in the QuickSwap liquidity pool and QiDao's Farm
     *
     * @return usdcAmount  The number of USDC tokens being re-invested
     * @return lpAmount  The number of LP USDC/MAI tokens being put on stake
     * @custom:emit CompoundRewards
     */
    function compoundRewards() external returns (uint256 usdcAmount, uint256 lpAmount);

    // --- Quotes ---------------------------------------------------------------------------------------------------------------------------------------------

    function quoteIn(uint256 usdc) external view returns (uint256 pe);

    function quoteOut(uint256 pe) external view returns (uint256 usdc);
}
