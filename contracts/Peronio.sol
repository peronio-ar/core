// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// OpenZepellin imports
import "@openzeppelin/contracts_latest/utils/math/SafeMath.sol";
import "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts_latest/access/AccessControl.sol";
import "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts_latest/token/ERC20/extensions/ERC20Burnable.sol";

// QiDao
import "./qidao/StakingRewards.sol";

// UniSwap
import "./uniswap/interfaces/IUniswapV2Router02.sol";
import "./uniswap/interfaces/IUniswapV2Pair.sol";

// HARDHAT / REMOVE!!!
import "hardhat/console.sol";

// Interface
import "./IPeronio.sol";

contract Peronio is IPeronio, ERC20, ERC20Burnable, ERC20Permit, AccessControl {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // USDC Token Address
  address public immutable override USDC_ADDRESS;
  // MAI Token Address
  address public immutable override MAI_ADDRESS;

  // LP USDC/MAI Address
  address public immutable override LP_ADDRESS;

  // QuickSwap Router
  address public immutable override QUICKSWAP_ROUTER_ADDRESS;

  // QiDao Farm
  address public immutable override QIDAO_FARM_ADDRESS;
  // QI Token Address
  address public immutable override QI_ADDRESS;
  // QiDao Pool ID
  uint256 public immutable override QIDAO_POOL_ID;

  // Markup
  uint8 public constant override MARKUP_DECIMALS = 5;
  uint256 public override markup = 5 * 10**(MARKUP_DECIMALS - 2); // 5%
  uint256 public override swapFee = 15 * 10**(MARKUP_DECIMALS - 4); // 0.15%

  // Initialization can only be run once
  bool public override initialized = false;

  // Roles
  bytes32 public constant override MARKUP_ROLE = keccak256("MARKUP_ROLE");
  bytes32 public constant override REWARDS_ROLE = keccak256("REWARDS_ROLE");

  // Collateral without decimals
  constructor(
    string memory name,
    string memory symbol,
    address usdcAddress,
    address maiAddress,
    address lpAddress,
    address qiAddress,
    address quickswapRouterAddress,
    address qidaoFarmAddress,
    uint256 qidaoPoolId
  ) ERC20(name, symbol) ERC20Permit(name) {
    // Stablecoins
    USDC_ADDRESS = usdcAddress;
    MAI_ADDRESS = maiAddress;

    // LP USDC/MAI Address
    LP_ADDRESS = lpAddress;

    // Router
    QUICKSWAP_ROUTER_ADDRESS = quickswapRouterAddress;

    // QiDao
    QIDAO_FARM_ADDRESS = qidaoFarmAddress;
    QIDAO_POOL_ID = qidaoPoolId;
    QI_ADDRESS = qiAddress;

    // Grant roles
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(MARKUP_ROLE, _msgSender());
    _setupRole(REWARDS_ROLE, _msgSender());
  }

  // 6 Decimals
  function decimals()
    public
    view
    virtual
    override(ERC20, IPeronio)
    returns (uint8)
  {
    return 6;
  }

  // Sets initial minting. Can only be runned once
  function initialize(uint256 usdcAmount, uint256 startingRatio)
    external
    override
    onlyRole(DEFAULT_ADMIN_ROLE)
  {
    console.log("calling address", _msgSender());
    require(!initialized, "Contract already initialized");

    // Get USDT from user
    IERC20(USDC_ADDRESS).safeTransferFrom(
      _msgSender(),
      address(this),
      usdcAmount
    );

    // Zaps into amUSDT
    _zapIn(usdcAmount);

    console.log("to MINT:", startingRatio.mul(usdcAmount));
    _mint(_msgSender(), startingRatio.mul(usdcAmount));

    // Lock contract to prevent to be initialized twice
    initialized = true;
    emit Initialized(_msgSender(), usdcAmount, startingRatio);
  }

  // Sets markup for minting function
  function setMarkup(uint256 markup_) external override onlyRole(MARKUP_ROLE) {
    markup = markup_;
    emit MarkupUpdated(_msgSender(), markup_);
  }

  // Receive Collateral token and mints the proportional tokens
  function mint(
    address to,
    uint256 usdcAmount,
    uint256 minReceive
  ) external override returns (uint256 peAmount) {
    // Gets current staked LP Tokens
    uint256 stakedAmount = _stakedBalance();

    // Transfer Collateral Token (USDT) to this contract
    IERC20(USDC_ADDRESS).safeTransferFrom(
      _msgSender(),
      address(this),
      usdcAmount
    ); // Changed

    // Zaps USDC directly into MAI/USDC Vault
    uint256 lpAmount = _zapIn(usdcAmount);

    console.log("-- FEE");
    // Fee - Swap fee (+0.15% positive bonus)
    uint256 markupFee = lpAmount.mul(markup - swapFee).div(10**MARKUP_DECIMALS); // Calculate fee to substract
    lpAmount = lpAmount.sub(markupFee); // remove 5% fee

    console.log("-- COMPUTE");
    // Compute %
    uint256 ratio = lpAmount.mul(10e8).div(stakedAmount);
    peAmount = ratio.mul(totalSupply()).div(10e8);

    console.log("-- FINAL MINT");
    require(peAmount > minReceive, "Minimum required not met");
    _mint(to, peAmount);
    emit Minted(_msgSender(), usdcAmount, peAmount);
  }

  // Receives Main token burns it and returns Collateral Token proportionally
  function withdraw(address to, uint256 peAmount) external override {
    // Transfer collateral back to user wallet to current contract
    uint256 ratio = peAmount.mul(10e8).div(totalSupply());
    uint256 lpAmount = ratio.mul(_stakedBalance()).div(10e8);

    uint256 usdcAmount;
    uint256 maiAmount;

    (usdcAmount, maiAmount) = _zapOut(lpAmount);

    // Swap MAI into USDC
    uint256 usdcTotal = usdcAmount + _swapMAItoUSDC(maiAmount);

    // Transfer back Collateral Token (USDT) the user
    IERC20(USDC_ADDRESS).safeTransfer(to, usdcTotal);

    //Burn tokens
    _burn(_msgSender(), peAmount);

    emit Withdrawal(_msgSender(), usdcTotal, peAmount);
  }

  function claimRewards() external override onlyRole(REWARDS_ROLE) {
    Farm(QIDAO_FARM_ADDRESS).deposit(QIDAO_POOL_ID, 0);
  }

  function compoundRewards()
    external
    override
    onlyRole(REWARDS_ROLE)
    returns (uint256 usdcAmount, uint256 lpAmount)
  {
    uint256 amount = IERC20(QI_ADDRESS).balanceOf(address(this));
    address[] memory path = new address[](2);
    path[0] = QI_ADDRESS;
    path[1] = USDC_ADDRESS;

    uint256[] memory amounts = IUniswapV2Router02(QUICKSWAP_ROUTER_ADDRESS)
      .swapExactTokensForTokens(
        amount,
        1,
        path,
        address(this),
        block.timestamp + 3600
      );
    usdcAmount = amounts[0];
    lpAmount = _zapIn(usdcAmount);

    emit CompoundRewards(amount, usdcAmount, lpAmount);
  }

  function stakedBalance() public view override returns (uint256) {
    return _stakedBalance();
  }

  // Gets current staking value in USDC
  function stakedValue() public view override returns (uint256 totalUSDC) {
    uint256 usdcReserves;
    uint256 maiReserves;
    uint256 usdcAmount;
    uint256 maiAmount;
    (usdcReserves, maiReserves) = _getLpReserves();
    (usdcAmount, maiAmount) = _stakedTokens();

    // Simulate Swap
    totalUSDC = usdcAmount.add(
      _getAmountOut(maiAmount, maiReserves, usdcReserves)
    );
  }

  function stakedTokens()
    public
    view
    returns (uint256 usdcAmount, uint256 maiAmount)
  {
    return _stakedTokens();
  }

  function reservesValue() public view override returns (uint256 totalUSDC) {
    uint256 usdcReserves;
    uint256 maiReserves;
    (usdcReserves, maiReserves) = _getLpReserves();
    console.log("usdcReserves", usdcReserves);
    totalUSDC = usdcReserves.mul(2);
  }

  // Gets current ratio: Total Supply / Collateral USDC Balance in vault
  function usdcPrice() public view override returns (uint256) {
    return (this.totalSupply().mul(10**decimals())).div(stakedValue());
  }

  // Gets current ratio: collateralRatio + markup
  function buyingPrice() external view override returns (uint256) {
    uint256 basePrice = collateralRatio();
    uint256 fee = (basePrice.mul(markup)).div(10**MARKUP_DECIMALS);
    return basePrice + fee;
  }

  function collateralRatio() public view override returns (uint256) {
    return stakedValue().mul(10**decimals()).div(this.totalSupply());
  }

  function getPendingRewardsAmount()
    external
    view
    override
    returns (uint256 amount)
  {
    amount = _getPendingRewardsAmount();
  }

  function getLpReserves()
    external
    view
    override
    returns (uint112 usdcReserves, uint112 maiReserves)
  {
    return _getLpReserves();
  }

  function _getLpReserves()
    private
    view
    returns (uint112 usdcReserves, uint112 maiReserves)
  {
    uint112 reserve0;
    uint112 reserve1;
    (reserve0, reserve1, ) = IUniswapV2Pair(LP_ADDRESS).getReserves();
    (usdcReserves, maiReserves) = USDC_ADDRESS < MAI_ADDRESS
      ? (reserve0, reserve1)
      : (reserve1, reserve0);
  }

  function _stakedTokens()
    private
    view
    returns (uint256 usdcAmount, uint256 maiAmount)
  {
    uint256 lpAmount = _stakedBalance();
    // Add 6 precision decimals
    uint256 ratio = lpAmount.mul(10e18).div(IERC20(LP_ADDRESS).totalSupply());
    uint112 usdcReserves;
    uint112 maiReserves;

    (usdcReserves, maiReserves) = _getLpReserves();

    usdcAmount = ratio.mul(usdcReserves).div(10e18);
    maiAmount = ratio.mul(maiReserves).div(10e18);
  }

  function _stakedBalance() private view returns (uint256) {
    return Farm(QIDAO_FARM_ADDRESS).deposited(QIDAO_POOL_ID, address(this));
  }

  // Zaps USDC into MAI/USDC Pool and mint into QiDao Farm
  function _zapIn(uint256 amount) internal returns (uint256 lpAmount) {
    // Provide USDC Liquidity (MAI/USDC) and get LP Tokens in return
    uint256 amountToSwap = amount.div(2);
    uint256 usdcAmount = amount.sub(amountToSwap);
    uint256 maiAmount = _swapUSDCtoMAI(amountToSwap);

    console.log("remaining usdc", usdcAmount);
    console.log("swapped mai", maiAmount);

    lpAmount = _addLiquidity(usdcAmount, maiAmount);

    // Stake LP Tokens
    _stakeLP(lpAmount);

    console.log("Staked");
  }

  // Zaps out USDC from MAI/USDC Pool
  function _zapOut(uint256 lpAmount)
    internal
    returns (uint256 usdcAmount, uint256 maiAmount)
  {
    // Provide USDC Liquidity (MAI/USDC) and get LP Tokens in return
    _unstakeLP(lpAmount);

    (usdcAmount, maiAmount) = _removeLiquidity(lpAmount);
  }

  function _addLiquidity(uint256 usdcAmount, uint256 maiAmount)
    internal
    returns (uint256 lpAmount)
  {
    console.log("Adding Liquidity");
    console.log("usdcAmount:", usdcAmount);
    console.log("maiAmount:", maiAmount);

    uint256 token0;
    uint256 token1;

    console.log("approving USDC", usdcAmount);
    IERC20(USDC_ADDRESS).approve(QUICKSWAP_ROUTER_ADDRESS, usdcAmount);

    console.log("approving MAI", maiAmount);
    IERC20(MAI_ADDRESS).approve(QUICKSWAP_ROUTER_ADDRESS, maiAmount);

    // 5% Slippage
    uint256 minUSDCAmount = usdcAmount.mul(95).div(100);
    uint256 minMAIAmount = maiAmount.mul(95).div(100);

    (token0, token1, lpAmount) = IUniswapV2Router02(QUICKSWAP_ROUTER_ADDRESS)
      .addLiquidity(
        USDC_ADDRESS,
        MAI_ADDRESS,
        usdcAmount,
        maiAmount,
        minUSDCAmount,
        minMAIAmount,
        address(this),
        block.timestamp + 3600
      );

    console.log("token0", token0);
    console.log("token1", token1);
    console.log("lpAmount", lpAmount);
  }

  function _removeLiquidity(uint256 lpAmount)
    internal
    returns (uint256 usdcAmount, uint256 maiAmount)
  {
    console.log("Removing Liquidity");
    console.log("lpAmount:", lpAmount);

    // Approve LP transfer
    IERC20(LP_ADDRESS).approve(QUICKSWAP_ROUTER_ADDRESS, lpAmount);

    (usdcAmount, maiAmount) = IUniswapV2Router02(QUICKSWAP_ROUTER_ADDRESS)
      .removeLiquidity(
        USDC_ADDRESS,
        MAI_ADDRESS,
        lpAmount,
        1,
        1,
        address(this),
        block.timestamp + 3600
      );

    console.log("usdcAmount:", usdcAmount);
    console.log("maiAmount:", maiAmount);
  }

  function _swapMAItoUSDC(uint256 amount)
    internal
    returns (uint256 usdcAmount)
  {
    console.log("Swapping ");
    console.log("maiAmount:", amount);
    address[] memory path = new address[](2);
    path[0] = MAI_ADDRESS;
    path[1] = USDC_ADDRESS;

    // Approve MAI
    IERC20(MAI_ADDRESS).approve(QUICKSWAP_ROUTER_ADDRESS, amount);

    uint256[] memory amounts = IUniswapV2Router02(QUICKSWAP_ROUTER_ADDRESS)
      .swapExactTokensForTokens(
        amount,
        1,
        path,
        address(this),
        block.timestamp + 3600
      );
    usdcAmount = amounts[1];
    console.log("usdcAmount:", usdcAmount);
  }

  function _swapUSDCtoMAI(uint256 amount) internal returns (uint256 maiAmount) {
    console.log("Swapping ");
    console.log("usdcAmount:", amount);
    address[] memory path = new address[](2);
    path[0] = USDC_ADDRESS;
    path[1] = MAI_ADDRESS;

    // Approve USDC
    IERC20(USDC_ADDRESS).approve(QUICKSWAP_ROUTER_ADDRESS, amount);

    uint256[] memory amounts = IUniswapV2Router02(QUICKSWAP_ROUTER_ADDRESS)
      .swapExactTokensForTokens(
        amount,
        1,
        path,
        address(this),
        block.timestamp + 3600
      );
    maiAmount = amounts[1];
    console.log("maiAmount:", maiAmount);
  }

  function _stakeLP(uint256 lpAmount) internal {
    console.log("Stake LP Tokens");
    console.log("lpAmount:", lpAmount);
    // Approve LP Tokens for QiDao Farm
    IERC20(LP_ADDRESS).approve(QIDAO_FARM_ADDRESS, lpAmount);

    // Deposit LP Tokens into Farm
    Farm(QIDAO_FARM_ADDRESS).deposit(QIDAO_POOL_ID, lpAmount);
  }

  function _unstakeLP(uint256 lpAmount) internal {
    console.log("Unstake LP Tokens");
    console.log("lpAmount:", lpAmount);

    // Deposit LP Tokens into Farm
    Farm(QIDAO_FARM_ADDRESS).withdraw(QIDAO_POOL_ID, lpAmount);
  }

  function _getLPBalanceAmount() internal view returns (uint256 lpAmount) {
    // Get current LP Balance
    lpAmount = IERC20(LP_ADDRESS).balanceOf(address(this));
  }

  function _getPendingRewardsAmount() internal view returns (uint256 amount) {
    // Get rewards on Farm
    amount = Farm(QIDAO_FARM_ADDRESS).pending(QIDAO_POOL_ID, address(this));
  }

  function _getRewardsAmount() internal view returns (uint256 amount) {
    // Get QI Dao balanced minted
    amount = IERC20(QI_ADDRESS).balanceOf(address(this));
  }

  function _getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) internal pure returns (uint256 amountOut) {
    require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
    require(
      reserveIn > 0 && reserveOut > 0,
      "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
    );
    uint256 amountInWithFee = amountIn.mul(997);
    uint256 numerator = amountInWithFee.mul(reserveOut);
    uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
    amountOut = numerator / denominator;
  }
}
