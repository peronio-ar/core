// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * Type representing an USDC token quantity
 *
 */
type UsdcQuantity is uint256;

/**
 * Type representing a MAI token quantity
 *
 */
type MaiQuantity is uint256;

/**
 * Type representing an LP USDC/MAI token quantity
 *
 */
type LpQuantity is uint256;

/**
 * Type representing a PE token quantity
 *
 */
type PeQuantity is uint256;

/**
 * Type representing a QI token quantity
 *
 */
type QiQuantity is uint256;

/**
 * Type representing a ratio of PE/USD tokens (always represented using `DECIMALS` decimals)
 *
 */
type PePerUsdcQuantity is uint256;

/**
 * Type representing a ratio of USD/PE tokens (always represented using `DECIMALS` decimals)
 *
 */
type UsdcPerPeQuantity is uint256;

/**
 * Type representing an adimensional ratio, expressed with 6 decimals
 *
 */
type RatioWith6Decimals is uint256;

/**
 * Type representing a role ID
 *
 */
type RoleId is bytes32;

/**
 * Permit voucher
 *
 * @custom:member from  The address granting allowance
 * @custom:member usdcAmount  The number of USDC tokens being allowed
 * @custom:member deadline  The maximum block timestamp this voucher is valid until
 * @custom:member v  The "v" part of an ERC20Permit signature
 * @custom:member r  The "r" part of an ERC20Permit signature
 * @custom:member s  The "s" part of an ERC20Permit signature
 * @custom:member fee  The number of USDC tokens awarded to the delegate for executing the transaction
 * @custom:member nonce  The voucher nonce to use
 */
struct PermitVoucher {
    address from;
    UsdcQuantity usdcAmount;
    uint256 deadline;
    uint8 v;
    bytes32 r;
    bytes32 s;
    //
    UsdcQuantity fee;
    uint256 nonce;
}

/**
 * Mint voucher
 *
 * @custom:member from  The address providing USDC collateral
 * @custom:member to  The address to which minted PE tokens will be transferred
 * @custom:member usdcAmount  The number of USDC tokens being provided as collateral
 * @custom:member deadline  The maximum block timestamp this voucher is valid until
 * @custom:member fee  The number of PE tokens awarded to the delegate for executing the transaction
 * @custom:member nonce  The voucher nonce to use
 */
struct MintVoucher {
    address from;
    address to;
    UsdcQuantity usdcAmount;
    PeQuantity minReceive;
    uint256 deadline;
    //
    PeQuantity fee;
    uint256 nonce;
}

/**
 * Withdraw voucher
 *
 * @custom:member from  The address from whence to extract PE tokens
 * @custom:member to  The address to which extracted USDC tokens will be transferred
 * @custom:member peAmount  The number of PE tokens being extracted
 * @custom:member deadline  The maximum block timestamp this voucher is valid until
 * @custom:member fee  The number of PE tokens awarded to the delegate for executing the transaction
 * @custom:member nonce  The voucher nonce to use
 */
struct WithdrawVoucher {
    address from;
    address to;
    PeQuantity peAmount;
    uint256 deadline;
    //
    PeQuantity fee;
    uint256 nonce;
}

interface IPeronio {
    // --- Events ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Emitted upon initialization of the Peronio contract
     *
     * @param owner  The address initializing the contract
     * @param collateral  The number of USDC tokens used as collateral
     * @param startingRatio  The number of PE tokens per USDC token the vault is initialized with
     */
    event Initialized(address owner, UsdcQuantity collateral, PePerUsdcQuantity startingRatio);

    /**
     * Emitted upon minting PE tokens
     *
     * @param to  The address where minted PE tokens get transferred to
     * @param collateralAmount  The number of USDC tokens used as collateral in this minting
     * @param tokenAmount  Amount of PE tokens minted
     */
    event Minted(address indexed to, UsdcQuantity collateralAmount, PeQuantity tokenAmount);

    /**
     * Emitted upon collateral withdrawal
     *
     * @param to  Address where the USDC token withdrawal is directed
     * @param collateralAmount  The number of USDC tokens withdrawn
     * @param tokenAmount  The number of PE tokens burnt
     */
    event Withdrawal(address indexed to, UsdcQuantity collateralAmount, PeQuantity tokenAmount);

    /**
     * Emitted upon liquidity withdrawal
     *
     * @param to  Address where the USDC token withdrawal is directed
     * @param lpAmount  The number of LP USDC/MAI tokens withdrawn
     * @param tokenAmount  The number of PE tokens burnt
     */
    event LiquidityWithdrawal(address indexed to, LpQuantity lpAmount, PeQuantity tokenAmount);

    /**
     * Emitted upon the markup fee being updated
     *
     * @param operator  Address of the one updating the markup fee
     * @param markupFee  New markup fee
     */
    event MarkupFeeUpdated(address operator, RatioWith6Decimals markupFee);

    /**
     * Emitted upon compounding rewards from QiDao's Farm back into the vault
     *
     * @param qi  Number of awarded QI tokens
     * @param usdc  Equivalent number of USDC tokens
     * @param lp  Number of LP USDC/MAI tokens re-invested
     */
    event CompoundRewards(QiQuantity qi, UsdcQuantity usdc, LpQuantity lp);

    /**
     * Emitted upon a voucher being served
     *
     * @param voucherNonce  The voucher nonce served
     * @param voucherHash  The voucher hash served
     * @param delegate  The delegate serving the voucher
     */
    event VoucherServed(uint256 indexed voucherNonce, bytes32 voucherHash, address delegate);

    // --- Roles - Automatic ----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the hash identifying the role responsible for updating the markup fee
     *
     * @return roleId  The role hash in question
     */
    function MARKUP_ROLE() external view returns (RoleId roleId); // solhint-disable-line func-name-mixedcase

    /**
     * Return the hash identifying the role responsible for compounding rewards
     *
     * @return roleId  The role hash in question
     */
    function REWARDS_ROLE() external view returns (RoleId roleId); // solhint-disable-line func-name-mixedcase

    /**
     * Return the hash identifying the role responsible for migrating between versions
     *
     * @return roleId  The role hash in question
     */
    function MIGRATOR_ROLE() external view returns (RoleId roleId); // solhint-disable-line func-name-mixedcase

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
     * Return the markup fee the use, using `_decimals()` decimals implicitly
     *
     * @return  The markup fee to use
     */
    function markupFee() external view returns (RatioWith6Decimals);

    /**
     * Return the swap fee the use, using `_decimals()` decimals implicitly
     *
     * @return  The swap fee to use
     */
    function swapFee() external view returns (RatioWith6Decimals);

    // --- Status - Automatic ---------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return wether the Peronio contract has been initialized yet
     *
     * @return  True whenever the contract has already been initialized, false otherwise
     */
    function initialized() external view returns (bool);

    /**
     * Determine whether the given voucher hash has been already served
     *
     * @param voucherHash  The voucher hash to check
     * @return  True whenever the given voucher hash has already been served
     */
    function voucherServed(bytes32 voucherHash) external view returns (bool);

    // --- Decimals -------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the number of decimals the PE token will work with
     *
     * @return decimals_  This will always be 6
     */
    function decimals() external view returns (uint8);

    // --- Markup fee change ----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Set the markup fee to the given value (take into account that this will use `_decimals` decimals implicitly)
     *
     * @param newMarkupFee  New markup fee value
     * @return prevMarkupFee  Previous markup fee value
     * @custom:emit  MarkupFeeUpdated
     */
    function setMarkupFee(RatioWith6Decimals newMarkupFee) external returns (RatioWith6Decimals prevMarkupFee);

    // --- Initialization -------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Initialize the PE token by providing collateral USDC tokens - initial conversion rate will be set at the given starting ratio
     *
     * @param usdcAmount  Number of collateral USDC tokens
     * @param startingRatio  Initial minting ratio in PE tokens per USDC tokens minted
     * @custom:emit  Initialized
     */
    function initialize(UsdcQuantity usdcAmount, PePerUsdcQuantity startingRatio) external;

    // --- State views ----------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function getLpReserves() external view returns (UsdcQuantity usdcReserves, MaiQuantity maiReserves);

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function stakedBalance() external view returns (LpQuantity lpAmount);

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function stakedTokens() external view returns (UsdcQuantity usdcAmount, MaiQuantity maiAmount);

    /**
     * Return the equivalent number of USDC tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Total equivalent number of USDC token on stake
     */
    function stakedValue() external view returns (UsdcQuantity usdcAmount);

    /**
     * Return the _collateralized_ price in USDC tokens per PE token
     *
     * @return price  Collateralized price in USDC tokens per PE token
     */
    function usdcPrice() external view returns (PePerUsdcQuantity price);

    /**
     * Return the effective _minting_ price in USDC tokens per PE token
     *
     * @return price  Minting price in USDC tokens per PE token
     */
    function buyingPrice() external view returns (UsdcPerPeQuantity price);

    /**
     * Return the ratio of total number of USDC tokens per PE token
     *
     * @return ratio  Ratio of USDC tokens per PE token, with `_decimal` decimals
     */
    function collateralRatio() external view returns (UsdcPerPeQuantity ratio);

    // --- State changers -------------------------------------------------------------------------------------------------------------------------------------

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
    ) external returns (PeQuantity peAmount);

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
    ) external returns (PeQuantity peAmount);

    /**
     * Extract the given number of PE tokens as USDC tokens
     *
     * @param to  Address to deposit extracted USDC tokens into
     * @param peAmount  Number of PE tokens to withdraw
     * @return usdcAmount  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     */
    function withdraw(address to, PeQuantity peAmount) external returns (UsdcQuantity usdcAmount);

    /**
     * Extract the given number of PE tokens as LP USDC/MAI tokens
     *
     * @param to  Address to deposit extracted LP USDC/MAI tokens into
     * @param peAmount  Number of PE tokens to withdraw liquidity for
     * @return lpAmount  Number of LP USDC/MAI tokens extracted
     * @custom:emit LiquidityWithdrawal
     */
    function withdrawLiquidity(address to, PeQuantity peAmount) external returns (LpQuantity lpAmount);

    // --- Voucher operations ---------------------------------------------------------------------------------------------------------------------------------

    /**
     * Execute an ERC20Permit call (with the current contract as beneficiary) --- using a pre-signed voucher
     *
     * @param permitVoucher  The `PermitVoucher` to serve
     * @param signature  The signature, issued by the `from` address
     * @custom:emit  Minted
     * @custom:emit  VoucherServed
     */
    function permitWithVoucher(PermitVoucher memory permitVoucher, bytes memory signature) external;

    /**
     * Mint PE tokens using the provided USDC tokens as collateral --- using a pre-signed voucher
     *
     * @param mintVoucher  The `MintVoucher` to serve
     * @param signature  The signature, issued by the `from` address
     * @return peAmount  The number of PE tokens actually minted
     * @custom:emit  Minted
     * @custom:emit  VoucherServed
     */
    function mintWithVoucher(MintVoucher memory mintVoucher, bytes memory signature) external returns (PeQuantity peAmount);

    /**
     * Extract the given number of PE tokens as USDC tokens --- using a pre-signed voucher
     *
     * @param withdrawVoucher  The `WithdrawVoucher` to serve
     * @param signature  The signature, issued by the `from` address
     * @return usdcAmount  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     * @custom:emit  VoucherServed
     */
    function withdrawWithVoucher(WithdrawVoucher memory withdrawVoucher, bytes memory signature) external returns (UsdcQuantity usdcAmount);

    // --- Rewards --------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Return the rewards accrued by staking LP USDC/MAI tokens in QiDao's Farm (in QI tokens)
     *
     * @return qiAmount  Number of QI tokens accrued
     */
    function getPendingRewardsAmount() external view returns (QiQuantity qiAmount);

    /**
     * Claim QiDao's QI token rewards, and re-invest them in the QuickSwap liquidity pool and QiDao's Farm
     *
     * @return usdcAmount  The number of USDC tokens being re-invested
     * @return lpAmount  The number of LP USDC/MAI tokens being put on stake
     * @custom:emit CompoundRewards
     */
    function compoundRewards() external returns (UsdcQuantity usdcAmount, LpQuantity lpAmount);

    // --- Quotes ---------------------------------------------------------------------------------------------------------------------------------------------

    /**
     * Retrieve the expected number of PE tokens corresponding to the given number of USDC tokens for minting.
     *
     * @param usdc  Number of USDC tokens to quote for
     * @return pe  Number of PE tokens quoted for the given number of USDC tokens
     */
    function quoteIn(UsdcQuantity usdc) external view returns (PeQuantity pe);

    /**
     * Retrieve the expected number of USDC tokens corresponding to the given number of PE tokens for withdrawal.
     *
     * @param pe  Number of PE tokens to quote for
     * @return usdc  Number of USDC tokens quoted for the given number of PE tokens
     */
    function quoteOut(PeQuantity pe) external view returns (UsdcQuantity usdc);
}
