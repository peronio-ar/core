// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// Peronio V1 Interface
import {IPeronioV1} from "./IPeronioV1.sol";

// ERC20 Interface
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

// QiDao
import "../../qidao/IFarm.sol";

// UniSwap
import "../../uniswap/interfaces/IUniswapV2Pair.sol";

// mulDiv
import {mulDiv} from "../../Utils.sol";

library PeronioV1Wrapper {
    /**
     * Retrieve the expected number of USDC tokens corresponding to the given number of PE tokens for withdrawal.
     *
     * @param peronioContract  Peronio contract interface
     * @param pe  Number of PE tokens to quote for
     * @return usdc  Number of USDC tokens quoted for the given number of PE tokens
     */
    function quoteOut(IPeronioV1 peronioContract, uint256 pe) internal view returns (uint256 usdc) {
        uint256 totalSupply = IERC20(address(peronioContract)).totalSupply(); // save gas
        uint256 lpTotalSupply = IERC20(peronioContract.LP_ADDRESS()).totalSupply(); // save gas

        // Transfer collateral back to user wallet to current contract
        uint256 ratio = (pe * 10e8) / totalSupply;
        uint256 lpAmount = (ratio * _stakedBalance(peronioContract)) / 10e8;

        (uint256 usdcReserves, uint256 maiReserves) = _getLpReserves(peronioContract);

        uint256 usdcAmount = mulDiv(lpAmount, usdcReserves, lpTotalSupply);
        uint256 maiAmount = mulDiv(lpAmount, maiReserves, lpTotalSupply);

        (uint256 scaledMaiAmount, uint256 scaledMaiReserve) = (maiAmount * 997, maiReserves * 1000);
        usdc = usdcAmount + mulDiv(scaledMaiAmount, usdcReserves, scaledMaiAmount + scaledMaiReserve);
    }

    /**
     * Extract the given number of PE tokens as USDC tokens
     *
     * @param peronioContract  Peronio contract interface
     * @param to  Address to deposit extracted USDC tokens into
     * @param peAmount  Number of PE tokens to withdraw
     * @return usdcTotal  Number of USDC tokens extracted
     * @custom:emit  Withdrawal
     */
    function withdrawV2(
        IPeronioV1 peronioContract,
        address to,
        uint256 peAmount
    ) internal returns (uint256 usdcTotal) {
        address usdcAddress = peronioContract.USDC_ADDRESS();
        uint256 oldUsdcBalance = IERC20(usdcAddress).balanceOf(to);

        peronioContract.withdraw(to, peAmount);

        usdcTotal = IERC20(usdcAddress).balanceOf(to) - oldUsdcBalance;
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
     *
     * @param peronioContract  Peronio contract interface
     * @return usdcAmount  Number of USDC tokens on stake
     * @return maiAmount  Number of MAI tokens on stake
     */
    function _stakedTokens(IPeronioV1 peronioContract) private view returns (uint256 usdcAmount, uint256 maiAmount) {
        uint256 lpAmount = peronioContract.stakedBalance();
        address lpAddress = peronioContract.LP_ADDRESS();
        uint256 lpTotalSupply = IERC20(lpAddress).totalSupply();

        (uint256 usdcReserves, uint256 maiReserves) = peronioContract.getLpReserves();

        usdcAmount = mulDiv(lpAmount, usdcReserves, lpTotalSupply);
        maiAmount = mulDiv(lpAmount, maiReserves, lpTotalSupply);
    }

    /**
     * Return the number of LP USDC/MAI tokens on stake at QiDao's Farm
     *
     * @param peronioContract  Peronio contract interface
     * @return lpAmount  Number of LP USDC/MAI token on stake
     */
    function _stakedBalance(IPeronioV1 peronioContract) internal view returns (uint256 lpAmount) {
        lpAmount = IFarm(peronioContract.QIDAO_FARM_ADDRESS()).deposited(peronioContract.QIDAO_POOL_ID(), address(peronioContract));
    }

    /**
     * Return the USDC and MAI token reserves present in QuickSwap
     *
     * @param peronioContract  Peronio contract interface
     * @return usdcReserves  Number of USDC tokens in reserve
     * @return maiReserves  Number of MAI tokens in reserve
     */
    function _getLpReserves(IPeronioV1 peronioContract) internal view returns (uint112 usdcReserves, uint112 maiReserves) {
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, ) = IUniswapV2Pair(peronioContract.LP_ADDRESS()).getReserves();
        (usdcReserves, maiReserves) = peronioContract.USDC_ADDRESS() < peronioContract.MAI_ADDRESS() ? (reserve0, reserve1) : (reserve1, reserve0);
    }
}
