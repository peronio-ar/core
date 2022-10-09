// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ITipJar {
    event TipReceived(uint256 amount, address from);
    event StakeIncreased(uint256 amount, address user);
    event StakeDecreased(uint256 amount, address user);
    event Scrubbed(uint256 tipAmount, uint256 stakingAmount);

    function stakingToken() external view returns (address _stakingToken);

    function stakesIn() external view returns (uint256 _stakesIn);

    function stakesOut() external view returns (uint256 _stakesOut);

    function tippingToken() external view returns (address _tippingToken);

    function tipsIn() external view returns (uint256 _tipsIn);

    function tipsOut() external view returns (uint256 _tipsOut);

    function tipsLeftToDeal() external view returns (uint256 _tipsLeftToDeal);

    function lastTipDealBlock() external view returns (uint256 _lastTipDealBlock);

    function accumulatedTipsPerShare() external view returns (uint256 _accumulatedTipsPerShare);

    function stakedAmount(address user) external view returns (uint256 _stakedAmount);

    function tipsAwarded(address user) external view returns (uint256 _tipsAwarded);

    function tipsPaidOut(address user) external view returns (uint256 _tipsPaidOut);

    function quickSwapRouterAddress() external view returns (address _quickSwapRouterAddress);

    function depositFee() external view returns (uint256 _depositFee);

    function depositFeeDecimals() external view returns (uint8 _depositFeeDecimals);

    function feeAddress() external view returns (address _feeAddress);

    function pendingTipsToPayOut(address user) external view returns (uint256 pendingAmount);

    function tip(uint256 amount) external returns (uint256 newTipsLeftToDeal);

    function tip(address from, uint256 amount) external returns (uint256 newTipsLeftToDeal);

    function stake(uint256 amount) external returns (uint256 newStakedAmount);

    function stake(address from, uint256 amount) external returns (uint256 newStakedAmount);

    function unstake() external returns (uint256 newStakedAmount);

    function unstake(address to) external returns (uint256 newStakedAmount);

    function unstake(uint256 amount) external returns (uint256 newStakedAmount);

    function unstake(uint256 amount, address to) external returns (uint256 newStakedAmount);

    function withdrawTips() external returns (uint256 extractedAmount);

    function withdrawTips(address to) external returns (uint256 extractedAmount);

    function withdrawTips(uint256 amount) external returns (uint256 extractedAmount);

    function withdrawTips(uint256 amount, address to) external returns (uint256 extractedAmount);

    function scrub() external returns (uint256 tipsAdjustment, uint256 stakesAdjustment);
}

interface ILinearTipJar is ITipJar {
    function tipsDealtPerBlock() external view returns (uint256 _tipsDealtPerBlock);

    function tipsDealtPerBlockDecimals() external view returns (uint8 _tipsDealtPerBlockDecimals);
}
