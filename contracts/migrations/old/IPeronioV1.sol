// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IPeronioV1 {
    function USDC_ADDRESS() external view returns (address);

    function MAI_ADDRESS() external view returns (address);

    function LP_ADDRESS() external view returns (address);

    function QUICKSWAP_ROUTER_ADDRESS() external view returns (address);

    function QIDAO_FARM_ADDRESS() external view returns (address);

    function QI_ADDRESS() external view returns (address);

    function QIDAO_POOL_ID() external view returns (uint256);

    // Markup
    function MARKUP_DECIMALS() external view returns (uint8);

    function markup() external view returns (uint256);

    function swapFee() external view returns (uint256);

    // Initialization can only be run once
    function initialized() external view returns (bool);

    // Roles
    function MARKUP_ROLE() external view returns (bytes32);

    function REWARDS_ROLE() external view returns (bytes32);

    // Events
    event Initialized(address owner, uint256 collateral, uint256 startingRatio);
    event Minted(address indexed to, uint256 collateralAmount, uint256 tokenAmount);
    event Withdrawal(address indexed to, uint256 collateralAmount, uint256 tokenAmount);
    event MarkupUpdated(address operator, uint256 markup);
    event CompoundRewards(uint256 qi, uint256 usdc, uint256 lp);
    event HarvestedMatic(uint256 wmatic, uint256 collateral);

    function decimals() external view returns (uint8);

    function initialize(uint256 usdcAmount, uint256 startingRatio) external;

    function setMarkup(uint256 markup_) external;

    function mint(
        address to,
        uint256 usdcAmount,
        uint256 minReceive
    ) external returns (uint256 peAmount);

    function withdraw(address to, uint256 peAmount) external;

    function claimRewards() external;

    function compoundRewards() external returns (uint256 usdcAmount, uint256 lpAmount);

    function stakedBalance() external view returns (uint256);

    function stakedValue() external view returns (uint256 totalUSDC);

    function usdcPrice() external view returns (uint256);

    function buyingPrice() external view returns (uint256);

    function collateralRatio() external view returns (uint256);

    function getPendingRewardsAmount() external view returns (uint256 amount);

    function getLpReserves() external view returns (uint112 usdcReserves, uint112 maiReserves);
}
