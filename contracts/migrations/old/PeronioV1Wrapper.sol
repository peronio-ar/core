// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

import {SafeERC20} from "@openzeppelin/contracts_latest/token/ERC20/utils/SafeERC20.sol";
import {IPeronioV1} from "./IPeronioV1.sol";

import {IUniswapV2Pair} from "../../uniswap/interfaces/IUniswapV2Pair.sol";
import {IPeronioV1Wrapper} from "./IPeronioV1Wrapper.sol";

// QiDao
import {IFarm} from "../../qidao/IFarm.sol";

// Needed for Babylonian square-root & combined-multiplication-and-division
import {mulDiv} from "../../Utils.sol";

contract PeronioV1Wrapper is IPeronioV1Wrapper {
    using SafeERC20 for IERC20;

    // Peronio V1 Address
    address public immutable override peronioAddress;

    // USDC Token Address
    address public immutable override usdcAddress;
    // MAI Token Address
    address public immutable override maiAddress;

    // LP USDC/MAI Address from QuickSwap
    address public immutable override lpAddress;

    // QuickSwap Router
    address public immutable override quickSwapRouterAddress;

    // QiDao Farm
    address public immutable override qiDaoFarmAddress;
    // QI Token Address
    address public immutable override qiAddress;
    // QiDao Pool ID
    uint256 public immutable override qiDaoPoolId;

    /**
     * Construct a new Peronio contract
     *
     * @param _peronioAddress  Peronio V1 Address
     */
    constructor(address _peronioAddress) {
        // Peronio V1 Contract
        IPeronioV1 peronioContract = IPeronioV1(_peronioAddress);

        // Peronio V1 Address
        peronioAddress = _peronioAddress;

        // Stable coins
        usdcAddress = peronioContract.USDC_ADDRESS();
        maiAddress = peronioContract.MAI_ADDRESS();

        // LP USDC/MAI Address
        lpAddress = peronioContract.LP_ADDRESS();

        // Router
        quickSwapRouterAddress = peronioContract.QUICKSWAP_ROUTER_ADDRESS();

        // QiDao
        qiDaoFarmAddress = peronioContract.QIDAO_FARM_ADDRESS();
        qiAddress = peronioContract.QI_ADDRESS();
        qiDaoPoolId = peronioContract.QIDAO_POOL_ID();
    }

    /**
     * Retrieve the expected number of USDC tokens corresponding to the given number of PE tokens for withdrawal.
     *
     * @param pe  Number of PE tokens to quote for
     * @return usdc  Number of USDC tokens quoted for the given number of PE tokens
     */
    function quoteOut(uint256 pe) external view override returns (uint256 usdc) {
        uint256 totalSupply = _totalSupply(); // save gas

        (uint256 usdcReserves, uint256 maiReserves) = _getLpReserves();
        (uint256 stakedUsdc, uint256 stakedMai) = _stakedTokens();

        uint256 usdcAmount = mulDiv(pe, stakedUsdc, totalSupply);
        uint256 maiAmount = mulDiv(pe, stakedMai, totalSupply);

        (uint256 scaledMaiAmount, uint256 scaledMaiReserve) = (maiAmount * 997, maiReserves * 1000);
        usdc = usdcAmount + mulDiv(scaledMaiAmount, usdcReserves, scaledMaiAmount + scaledMaiReserve);
    }

    /**
     * Extract the given number of PE tokens as USDC tokens
     *
     * @param to  Address to deposit extracted USDC tokens into
     * @param peAmount  Number of PE tokens to withdraw
     * @return usdcTotal  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     */
    function withdraw(address to, uint256 peAmount) external override returns (uint256 usdcTotal) {
        uint256 oldUsdcBalance = IERC20(usdcAddress).balanceOf(to);
        IPeronioV1(peronioAddress).withdraw(to, peAmount);

        (bool success, ) = peronioAddress.delegatecall(abi.encodeWithSignature("withdraw(address,uint256)", to, peAmount));
        require(success, "Error delegating call");
        usdcTotal = IERC20(usdcAddress).balanceOf(to) - oldUsdcBalance;
    }

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function _getLpReserves() private view returns (uint256 usdcReserves, uint256 maiReserves) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(lpAddress).getReserves();
        (usdcReserves, maiReserves) = usdcAddress < maiAddress ? (uint256(reserve0), uint256(reserve1)) : (uint256(reserve1), uint256(reserve0));
    }

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function _totalSupply() private view returns (uint256) {
        return IERC20(peronioAddress).totalSupply();
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function _stakedTokens() private view returns (uint256 usdcAmount, uint256 maiAmount) {
        uint256 lpAmount = _stakedBalance();
        uint256 lpTotalSupply = IERC20(lpAddress).totalSupply();

        (uint256 usdcReserves, uint256 maiReserves) = _getLpReserves();

        usdcAmount = mulDiv(lpAmount, usdcReserves, lpTotalSupply);
        maiAmount = mulDiv(lpAmount, maiReserves, lpTotalSupply);
    }

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function _stakedBalance() private view returns (uint256 lpAmount) {
        lpAmount = IFarm(qiDaoFarmAddress).deposited(qiDaoPoolId, peronioAddress);
    }
}
