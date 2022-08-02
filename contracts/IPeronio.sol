// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IPeronio {

    // Events
    event Initialized(address owner, uint256 collateral, uint256 startingRatio);

    event Minted(address indexed to, uint256 collateralAmount, uint256 tokenAmount);

    event Withdrawal(address indexed to, uint256 collateralAmount, uint256 tokenAmount);

    event MarkupUpdated(address operator, uint256 markup);

    event CompoundRewards(uint256 qi, uint256 usdc, uint256 lp);

    event HarvestedMatic(uint256 wmatic, uint256 collateral);

    // Roles - automatic
    function MARKUP_ROLE() external view returns (bytes32 roleId);  // solhint-disable-line func-name-mixedcase

    function REWARDS_ROLE() external view returns (bytes32 roleId);  // solhint-disable-line func-name-mixedcase

    // Addresses - automatic
    function usdcAddress() external view returns (address);

    function maiAddress() external view returns (address);

    function lpAddress() external view returns (address);

    function qiAddress() external view returns (address);

    function quickSwapRouterAddress() external view returns (address);

    function qiDaoFarmAddress() external view returns (address);

    function qiDaoPoolId() external view returns (uint256);

    // Fees - automatic
    function markupDecimals() external view returns (uint8);

    function markup() external view returns (uint256 markup_);

    function swapFee() external view returns (uint256 fee);

    // Status - automatic
    function initialized() external view returns (bool isInitialized);

    // Decimals
    function decimals() external view returns (uint8 decimals_);

    // Markup change
    function setMarkup(uint256 newMarkup) external returns (uint256 prevMarkup);

    // Initialization
    function initialize(uint256 usdcAmount, uint256 startingRatio) external;

    // State views
    function stakedBalance() external view returns (uint256 lpAmount);

    function stakedValue() external view returns (uint256 usdcAmount);

    function stakedTokens() external view returns (uint256 usdcAmount, uint256 maiAmount);

    function usdcPrice() external view returns (uint256 price);

    function buyingPrice() external view returns (uint256 price);

    function collateralRatio() external view returns (uint256 ratio);

    function getLpReserves() external view returns (uint112 usdcReserves, uint112 maiReserves);

    // State changers
    function mint(address to, uint256 usdcAmount, uint256 minReceive) external returns (uint256 peAmount);

    function withdraw(address to, uint256 peAmount) external returns (uint256 usdcTotal);

    function withdrawLiquidity(address to, uint256 peAmount) external;

    // Rewards
    function getPendingRewardsAmount() external view returns (uint256 amount);

    function compoundRewards() external returns (uint256 usdcAmount, uint256 lpAmount);

    // Quotes
    function quoteIn(uint256 usdc) external view returns (uint256 pe);

    function quoteOut(uint256 pe) external view returns (uint256 usdc);
}
