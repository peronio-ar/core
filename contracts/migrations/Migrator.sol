// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {PeronioV1Wrapper} from "./old/PeronioV1Wrapper.sol";
import {IPeronioV1} from "./old/IPeronioV1.sol";
import "../IPeronio.sol";

import {min, mulDiv, sqrt256} from "../Utils.sol";
import {IUniswapV2Pair} from "../uniswap/interfaces/IUniswapV2Pair.sol";
import {IFarm} from "../qidao/IFarm.sol";

import {IERC20} from "@openzeppelin/contracts_latest/token/ERC20/IERC20.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

// Interface
import {IMigrator} from "./IMigrator.sol";

contract Migrator is IMigrator, ERC165 {
    using PeronioV1Wrapper for IPeronioV1;

    // Peronio V1 Address
    address public immutable peronioV1Address;

    // Peronio V2 Address
    address public immutable peronioV2Address;

    /**
     * Construct a new Peronio migrator
     *
     * @param _peronioV1Address  The address of the old PE contract
     * @param _peronioV2Address  The address of the new PE contract
     */
    constructor(address _peronioV1Address, address _peronioV2Address) {
        // Peronio Addresses
        peronioV1Address = _peronioV1Address;
        peronioV2Address = _peronioV2Address;

        // Unlimited USDC Approve to Peronio V2 contract
        IERC20(IPeronioV1(_peronioV1Address).USDC_ADDRESS()).approve(_peronioV2Address, type(uint256).max);
    }

    /**
     * Implementation of the IERC165 interface
     *
     * @param interfaceId  Interface ID to check against
     * @return  Whether the provided interface ID is supported
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IMigrator).interfaceId || super.supportsInterface(interfaceId);
    }

    // --- Migration Proper -----------------------------------------------------------------------------------------------------------------------------------

    /**
     * Migrate the given number of PE tokens from the old contract to the new one
     *
     * @param amount  The number of PE tokens to withdraw from the old contract
     * @return usdc  The number of USDC tokens withdrawn from the old contract
     * @return pe  The number of PE tokens minted on the new contract
     * @custom:emit  Migrated
     */
    function migrate(uint256 amount) external override returns (uint256 usdc, uint256 pe) {
        // Peronio V1 Contract Wrapper
        IPeronioV1 peronioV1 = IPeronioV1(peronioV1Address);
        // Peronio V2 Contract
        IPeronio peronioV2 = IPeronio(peronioV2Address);

        // Transfer PE V1 to this contract
        IERC20(peronioV1Address).transferFrom(msg.sender, address(this), amount);

        // Calculate USDC to be received by Peronio V1
        usdc = peronioV1.withdrawV2(address(this), amount);
        // Calculate PE to be minted by Peronio V2
        pe = PeQuantity.unwrap(peronioV2.mintForMigration(msg.sender, UsdcQuantity.wrap(usdc), PeQuantity.wrap(1)));

        // Emit Migrated event
        emit Migrated(block.timestamp, amount, usdc, pe);
    }

    // --- Quote ----------------------------------------------------------------------------------------------------------------------------------------------
    //
    // Quote is created by inlining the call to migrate, and discarding state-changing statements
    //

    /**
     * Retrieve the number of USDC tokens to withdraw from the old contract, and the number of OE tokens to mint on the new one
     *
     * @param amount  The number of PE tokens to withdraw from the old contract
     * @return usdc  The number of USDC tokens to withdraw from the old contract
     * @return pe  The number of PE tokens to mint on the new contract
     */
    function quote(uint256 amount) external view override returns (uint256 usdc, uint256 pe) {
        uint256 usdcReserves;
        uint256 maiReserves;
        {
            (uint112 _usdcReserves, uint112 _maiReserves) = IPeronioV1(peronioV1Address).getLpReserves();
            (usdcReserves, maiReserves) = (uint256(_usdcReserves), uint256(_maiReserves));
        }

        uint256 lpTotalSupply = IERC20(IPeronioV1(peronioV1Address).LP_ADDRESS()).totalSupply();
        uint256 kLast = IUniswapV2Pair(IPeronioV1(peronioV1Address).LP_ADDRESS()).kLast();

        {
            uint256 rootKLast = sqrt256(kLast);
            uint256 rootK = sqrt256(usdcReserves * maiReserves);
            if (rootKLast < rootK) {
                lpTotalSupply += (lpTotalSupply * (rootK - rootKLast)) / (5 * rootK + rootKLast);
            }
        }

        {
            uint256 usdcAmount;
            uint256 maiAmount;
            {
                uint256 newLpBalance = IERC20(IPeronioV1(peronioV1Address).LP_ADDRESS()).balanceOf(IPeronioV1(peronioV1Address).LP_ADDRESS()) +
                    (((amount * 10e8) / IERC20(peronioV1Address).totalSupply()) *
                        IFarm(IPeronioV1(peronioV1Address).QIDAO_FARM_ADDRESS()).deposited(IPeronioV1(peronioV1Address).QIDAO_POOL_ID(), peronioV1Address)) /
                    10e8;
                usdcAmount = mulDiv(newLpBalance, usdcReserves, lpTotalSupply);
                maiAmount = mulDiv(newLpBalance, maiReserves, lpTotalSupply);
                lpTotalSupply -= newLpBalance;
            }

            usdcReserves -= usdcAmount;
            maiReserves -= maiAmount;
            kLast = usdcReserves * maiReserves;

            {
                uint256 usdcAmountOut = mulDiv(997 * maiAmount, usdcReserves, 997 * maiAmount + 1000 * maiReserves);
                usdc = usdcAmount + usdcAmountOut;
                usdcReserves -= usdcAmountOut;
            }
        }

        uint256 lpAmountMint;
        {
            uint256 usdcAmount;
            uint256 maiAmount;
            {
                uint256 usdcAmountToSwap = sqrt256(mulDiv(3988009 * usdcReserves + 3988000 * usdc, usdcReserves, 3976036)) - mulDiv(usdcReserves, 1997, 1994);
                uint256 maiAmountOut = mulDiv(997 * usdcAmountToSwap, maiReserves, 997 * usdcAmountToSwap + 1000 * usdcReserves);

                usdcReserves += usdcAmountToSwap;
                maiReserves -= maiAmountOut;

                {
                    uint256 amountMaiOptimal = mulDiv(usdc, maiReserves, usdcReserves);
                    if (amountMaiOptimal <= maiAmountOut) {
                        (usdcAmount, maiAmount) = (usdc, amountMaiOptimal);
                    } else {
                        uint256 amountUsdcOptimal = (maiAmountOut * usdcReserves) / maiReserves;
                        (usdcAmount, maiAmount) = (amountUsdcOptimal, maiAmountOut);
                    }
                }

                {
                    uint256 rootK = sqrt256(usdcReserves * maiReserves);
                    uint256 rootKLast = sqrt256(kLast);
                    if (rootKLast < rootK) {
                        lpTotalSupply += (lpTotalSupply * (rootK - rootKLast)) / (5 * rootK + rootKLast);
                    }
                }
            }

            uint8 decimals = IPeronio(peronioV2Address).decimals();
            uint256 totalMintFee;
            {
                (, , , , uint16 depositFeeBP) = IFarm(IPeronio(peronioV2Address).qiDaoFarmAddress()).poolInfo(IPeronio(peronioV2Address).qiDaoPoolId());
                totalMintFee = RatioWith6Decimals.unwrap(IPeronio(peronioV2Address).swapFee()) + uint256(depositFeeBP) * 10**(decimals - 4);
            }

            lpAmountMint = mulDiv(
                min(mulDiv(usdcAmount, lpTotalSupply, usdcReserves), mulDiv(maiAmount, lpTotalSupply, maiReserves)),
                10**decimals - totalMintFee,
                10**decimals
            );
        }

        uint256 stakedAmount = IFarm(IPeronio(peronioV2Address).qiDaoFarmAddress()).deposited(IPeronio(peronioV2Address).qiDaoPoolId(), peronioV2Address);

        pe = mulDiv(lpAmountMint, IERC20(peronioV2Address).totalSupply(), stakedAmount);
    }
}
