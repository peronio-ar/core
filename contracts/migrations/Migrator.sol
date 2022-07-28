// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// OpenZepellin imports
import { ERC20 } from "@openzeppelin/contracts_latest/token/ERC20/ERC20.sol";
import { IERC20 } from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";
import { AccessControl } from "@openzeppelin/contracts_latest/access/AccessControl.sol";
import { ERC20Permit } from "@openzeppelin/contracts_latest/token/ERC20/extensions/draft-ERC20Permit.sol";
import { ERC20Burnable } from "@openzeppelin/contracts_latest/token/ERC20/extensions/ERC20Burnable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts_latest/security/ReentrancyGuard.sol";

// QiDao
import { IFarm } from "../qidao/IFarm.sol";

// UniSwap
import { IUniswapV2Router02 } from "../uniswap/interfaces/IUniswapV2Router02.sol";
import { IUniswapV2Pair } from "../uniswap/interfaces/IUniswapV2Pair.sol";

// Needed for Babylonian square-root
import { sqrt256 } from "../Utils.sol";

// Interface
import "./IMigrator.sol";


contract Migrator is IMigrator, ReentrancyGuard {
  using SafeERC20 for IERC20;

  // USDC Token Address
  address public immutable override USDC_ADDRESS;
  // MAI Token Address
  address public immutable override MAI_ADDRESS;

  // LP USDC/MAI Address from QuickSwap
  address public immutable override LP_ADDRESS;

  // QuickSwap Router
  address public immutable override QUICKSWAP_ROUTER_ADDRESS;

  // QiDao Farm
  address public immutable override QIDAO_FARM_ADDRESS;
  // QI Token Address
  address public immutable override QI_ADDRESS;
  // QiDao Pool ID
  uint256 public immutable override QIDAO_POOL_ID;

  constructor(
    address usdcAddress,
    address maiAddress,
    address lpAddress,
    address qiAddress,
    address quickswapRouterAddress,
    address qidaoFarmAddress,
    uint256 qidaoPoolId
  ) {
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
  }

  // PENDING
  function quoteV1(uint256 pe)
    external
    view
    override
    returns (uint256 usdc, uint256 p)
  {
    // uint256 stakedAmount = _stakedBalance();
    // (uint112 usdcReserves, ) = _getLpReserves();
    // uint256 amountToSwap = _calculateSwapInAmount(usdcReserves, usdc);
    // uint256 usdcAmount = usdc - amountToSwap;
    // uint256 lpAmount = usdcAmount.mul(10e18).div(usdcReserves);
    // uint256 markupFee = lpAmount.mul(markup - swapFee).div(10**MARKUP_DECIMALS); // Calculate fee to substract
    // lpAmount = lpAmount.sub(markupFee); // remove 5% fee
    // // Compute %
    // uint256 ratio = lpAmount.mul(10e8).div(stakedAmount);
    // pe = ratio.mul(totalSupply()).div(10e8);
  }

  // NEEDS TESTING
  function migrateV1(uint256 pe)
    external
    view
    override
    returns (uint256 usdc, uint256 p)
  {
    // (uint112 usdcReserves, uint112 maiReserves) = _getLpReserves();
    // uint256 ratio = pe.mul(10e8).div(totalSupply());
    // (uint256 stakedUsdc, uint256 stakedMai) = _stakedTokens();
    // uint256 usdcAmount = stakedUsdc.mul(ratio).div(10e8);
    // uint256 maiAmount = stakedMai.mul(ratio).div(10e8);
    // usdc = usdcAmount.sum(_getAmountOut(maiAmount, maiReserves, usdcReserves));
  }

  //**  UNISWAP Library Functions Below **/
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
    uint256 amountInWithFee = amountIn * 997;
    uint256 numerator = amountInWithFee * reserveOut;
    uint256 denominator = (reserveIn * 1000) + amountInWithFee;
    amountOut = numerator / denominator;
  }
}
