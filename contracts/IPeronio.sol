// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IPeronio {
    function USDC_ADDRESS() external view returns (address usdcAddress);  // solhint-disable-line func-name-mixedcase

    function MAI_ADDRESS() external view returns (address maiAddress);  // solhint-disable-line func-name-mixedcase

    function LP_ADDRESS() external view returns (address lpAddress);  // solhint-disable-line func-name-mixedcase

    function QI_ADDRESS() external view returns (address qiAddress);  // solhint-disable-line func-name-mixedcase

    function QUICKSWAP_ROUTER_ADDRESS() external view returns (address quickSwapRouterAddress);  // solhint-disable-line func-name-mixedcase

    function QIDAO_FARM_ADDRESS() external view returns (address qiDaoFarmAddress);  // solhint-disable-line func-name-mixedcase

    function QIDAO_POOL_ID() external view returns (uint256 qiDaoPoolId);  // solhint-disable-line func-name-mixedcase

    // Markup
    function MARKUP_DECIMALS() external view returns (uint8 decimals_);  // solhint-disable-line func-name-mixedcase

    function markup() external view returns (uint256 markup_);

    function swapFee() external view returns (uint256 fee);

    // Initialization can only be run once
    function initialized() external view returns (bool initialized_);

    // Roles
    function MARKUP_ROLE() external view returns (bytes32 roleId);  // solhint-disable-line func-name-mixedcase

    function REWARDS_ROLE() external view returns (bytes32 roleId);  // solhint-disable-line func-name-mixedcase

    // Events
    event Initialized(address owner, uint256 collateral, uint256 startingRatio);

    event Minted(address indexed to, uint256 collateralAmount, uint256 tokenAmount);

    event Withdrawal(address indexed to, uint256 collateralAmount, uint256 tokenAmount);

    event MarkupUpdated(address operator, uint256 markup);

    event CompoundRewards(uint256 qi, uint256 usdc, uint256 lp);

    event HarvestedMatic(uint256 wmatic, uint256 collateral);

    function decimals() external view returns (uint8 decimals_);

    function initialize(uint256 usdcAmount, uint256 startingRatio) external;

    function setMarkup(uint256 markup_) external;

    function mint(address to, uint256 usdcAmount, uint256 minReceive) external returns (uint256 peAmount);

    function withdraw(address to, uint256 peAmount) external returns (uint256 usdcTotal);

    function claimRewards() external;

    function compoundRewards() external returns (uint256 usdcAmount, uint256 lpAmount);

    function stakedBalance() external view returns (uint256 lpAmount);

    function stakedValue() external view returns (uint256 usdcAmount);

    function usdcPrice() external view returns (uint256 price);

    function buyingPrice() external view returns (uint256 price);

    function collateralRatio() external view returns (uint256 ratio);

    function getPendingRewardsAmount() external view returns (uint256 amount);

    function getLpReserves() external view returns (uint112 usdcReserves, uint112 maiReserves);

    // Version 2
    function quoteIn(uint256 usdc) external view returns (uint256 pe);

    function quoteOut(uint256 pe) external view returns (uint256 usdc);
}
