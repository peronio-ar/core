// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

interface IFarm {
  function add(
    uint256 _allocPoint,
    address _lpToken,
    bool _withUpdate,
    uint16 _depositFeeBP
  ) external;

  function deposit(uint256 _pid, uint256 _amount) external;

  function deposited(uint256 _pid, address _user)
    external
    view
    returns (uint256);

  function emergencyWithdraw(uint256 _pid) external;

  function endBlock() external view returns (uint256);

  function erc20() external view returns (address);

  function feeAddress() external view returns (address);

  function fund(uint256 _amount) external;

  function massUpdatePools() external;

  function owner() external view returns (address);

  function paidOut() external view returns (uint256);

  function pending(uint256 _pid, address _user) external view returns (uint256);

  function poolInfo(uint256)
    external
    view
    returns (
      address lpToken,
      uint256 allocPoint,
      uint256 lastRewardBlock,
      uint256 accERC20PerShare,
      uint16 depositFeeBP
    );

  function poolLength() external view returns (uint256);

  function renounceOwnership() external;

  function rewardPerBlock() external view returns (uint256);

  function set(
    uint256 _pid,
    uint256 _allocPoint,
    bool _withUpdate
  ) external;

  function setFeeAddress(address _feeAddress) external;

  function startBlock() external view returns (uint256);

  function totalAllocPoint() external view returns (uint256);

  function totalPending() external view returns (uint256);

  function transferOwnership(address newOwner) external;

  function updatePool(uint256 _pid) external;

  function userInfo(uint256, address)
    external
    view
    returns (uint256 amount, uint256 rewardDebt);

  function withdraw(uint256 _pid, uint256 _amount) external;
}
