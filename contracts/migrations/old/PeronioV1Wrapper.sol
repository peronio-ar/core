// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Peronio V1 Interface
import {IPeronioV1} from "./IPeronioV1.sol";

// ERC20 Interface
import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

// QiDao
import {IFarm} from "../../qidao/IFarm.sol";

// UniSwap
import {IUniswapV2Pair} from "../../uniswap/interfaces/IUniswapV2Pair.sol";
import {IERC20Uniswap} from "../../uniswap/interfaces/IERC20Uniswap.sol";

import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";

library PeronioV1Wrapper {
    /**
     * Retrieve the expected number of USDC tokens corresponding to the given number of PE tokens for withdrawal.
     *
     * @param peronioContract  Peronio contract interface
     * @param pe  Number of PE tokens to quote for
     * @return usdc  Number of USDC tokens quoted for the given number of PE tokens
     */
    function quoteOut(IPeronioV1 peronioContract, uint256 pe) internal view returns (uint256 usdc) {
        // --- Gas Saving -------------------------------------------------------------------------
        address _lpAddress = peronioContract.LP_ADDRESS();

        (uint256 usdcReserves, uint256 maiReserves) = peronioContract.getLpReserves();
        uint256 lpTotalSupply = IERC20(_lpAddress).totalSupply();

        // deal with LP minting when changing its K
        {
            uint256 rootK = Math.sqrt(usdcReserves * maiReserves);
            uint256 rootKLast = Math.sqrt(IUniswapV2Pair(_lpAddress).kLast());
            if (rootKLast < rootK) {
                lpTotalSupply += Math.mulDiv(lpTotalSupply, rootK - rootKLast, (rootK * 5) + rootKLast);
            }
        }

        // calculate LP values actually withdrawn
        uint256 lpAmount = IERC20Uniswap(_lpAddress).balanceOf(_lpAddress) +
            Math.mulDiv(pe, peronioContract.stakedBalance(), IERC20(address(peronioContract)).totalSupply());

        uint256 usdcAmount = Math.mulDiv(usdcReserves, lpAmount, lpTotalSupply);
        uint256 maiAmount = Math.mulDiv(maiReserves, lpAmount, lpTotalSupply);

        usdc = usdcAmount + _getAmountOut(maiAmount, maiReserves - maiAmount, usdcReserves - usdcAmount);
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

    function _getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        uint256 amountInWithFee = amountIn * 997;
        amountOut = Math.mulDiv(amountInWithFee, reserveOut, reserveIn * 1000 + amountInWithFee);
    }
}
