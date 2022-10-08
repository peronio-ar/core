// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ITipJar {
    event TipReceived(uint256 amount, address from);
    event StakeIncreased(uint256 amount, address user);
    event StakeDecreased(uint256 amount, address user);
    event Scrubbed(uint256 tipAmount, uint256 stakingAmount);

    function stakingToken() external view returns (address _stakingToken);

    function tippingToken() external view returns (address _tipsToken);

    function tipsLeftToDeal() external view returns (uint256 _tipsLeftToDeal);

    function tipsDealtPerBlock() external view returns (uint256 _tipsDealtPerBlock);

    function lastTipDealBlock() external view returns (uint256 _lastTipDealBlock);

    function accumulatedTipsPerShare() external view returns (uint256 _accumulatedTipsPerShare);

    function depositFeeBP() external view returns (uint16 _depositFeeBP);

    function feeAddress() external view returns (address _feeAddress);

    function stakedAmount(address user) external view returns (uint256 _stakedAmount);

    function tipsPaidOut(address user) external view returns (uint256 _stakedAmount);

    function tipsPending(address user) external view returns (uint256 _stakedAmount);

    function pendingTipsToPayOut(address user) external view returns (uint256 pendingAmount);

    function quickSwapRouterAddress() external view returns (address _quickSwapRouterAddress);

    function tip(uint256 amount) external returns (uint256 _tipsLeftToDeal);

    function tip(address from, uint256 amount) external returns (uint256 _tipsLeftToDeal);

    function stake(uint256 amount) external returns (uint256 _stakedAmount);

    function stake(address from, uint256 amount) external returns (uint256 _stakedAmount);

    function unstake() external returns (uint256 _stakedAmount);

    function unstake(address to) external returns (uint256 _stakedAmount);

    function unstake(uint256 amount) external returns (uint256 _stakedAmount);

    function unstake(uint256 amount, address to) external returns (uint256 _stakedAmount);

    function withdrawTips() external returns (uint256 _extractedAmount);

    function withdrawTips(address to) external returns (uint256 _extractedAmount);

    function withdrawTips(uint256 amount) external returns (uint256 _extractedAmount);

    function withdrawTips(uint256 amount, address to) external returns (uint256 _extractedAmount);

    function scrub() external returns (uint256 tipsAdjustment, uint256 stakesAdjustment);
}
