// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IPeronioV1} from "./IPeronioV1.sol";

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";

// Needed for Babylonian square-root & combined-multiplication-and-division
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

        (uint256 usdcReserves, uint256 maiReserves) = peronioContract.getLpReserves();
        (uint256 stakedUsdc, uint256 stakedMai) = _stakedTokens(peronioContract);

        uint256 usdcAmount = mulDiv(pe, stakedUsdc, totalSupply);
        uint256 maiAmount = mulDiv(pe, stakedMai, totalSupply);

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

        // peronioContract.withdraw(to, peAmount);

        (bool success, ) = address(peronioContract).delegatecall(abi.encodeWithSignature("withdraw(address,uint256)", to, peAmount));
        require(success, "Error delegating call");
        usdcTotal = IERC20(usdcAddress).balanceOf(to) - oldUsdcBalance;
    }

    /**
     * Return the number of USDC and MAI tokens on stake at QiDao's Farm
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
}
