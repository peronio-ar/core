pragma solidity ^0.8.16;

// SPDX-License-Identifier: MIT

import {IPeronio} from "./IPeronio.sol";
import {max, min, mulDiv, sqrt256} from "./Utils.sol";

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- Implementation-side user defined value types -----------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

type UniSwapKQuantity is uint256;
type UniSwapRootKQuantity is uint256;
type UsdcSqQuantity is uint256;
type RatioWith4Decimals is uint256;

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- Standard Numeric Types ---------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

// --- UniSwap K ----------------------------------------------------------------------------------------------------------------------------------------------
function add(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UniSwapKQuantity.unwrap(left) + UniSwapKQuantity.unwrap(right));
}

function prod(UniSwapKQuantity val, uint256 x) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UniSwapKQuantity.unwrap(val) * x);
}

function prod(uint256 x, UniSwapKQuantity val) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(x * UniSwapKQuantity.unwrap(val));
}

function subtract(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UniSwapKQuantity.unwrap(left) - UniSwapKQuantity.unwrap(right));
}

function min(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(min(UniSwapKQuantity.unwrap(left), UniSwapKQuantity.unwrap(right)));
}

function max(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(max(UniSwapKQuantity.unwrap(left), UniSwapKQuantity.unwrap(right)));
}

function eq(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (bool) {
    return UniSwapKQuantity.unwrap(left) == UniSwapKQuantity.unwrap(right);
}

function neq(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (bool) {
    return UniSwapKQuantity.unwrap(left) != UniSwapKQuantity.unwrap(right);
}

function lt(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (bool) {
    return UniSwapKQuantity.unwrap(left) < UniSwapKQuantity.unwrap(right);
}

function gt(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (bool) {
    return UniSwapKQuantity.unwrap(left) > UniSwapKQuantity.unwrap(right);
}

function lte(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (bool) {
    return UniSwapKQuantity.unwrap(left) <= UniSwapKQuantity.unwrap(right);
}

function gte(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (bool) {
    return UniSwapKQuantity.unwrap(left) >= UniSwapKQuantity.unwrap(right);
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(left, UniSwapKQuantity.unwrap(right), div));
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(UniSwapKQuantity.unwrap(left), right, UniSwapKQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(left, UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div));
}

// --- UniSwap rootK ------------------------------------------------------------------------------------------------------------------------------------------
function add(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(UniSwapRootKQuantity.unwrap(left) + UniSwapRootKQuantity.unwrap(right));
}

function prod(UniSwapRootKQuantity val, uint256 x) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(UniSwapRootKQuantity.unwrap(val) * x);
}

function prod(uint256 x, UniSwapRootKQuantity val) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(x * UniSwapRootKQuantity.unwrap(val));
}

function subtract(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(UniSwapRootKQuantity.unwrap(left) - UniSwapRootKQuantity.unwrap(right));
}

function min(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(min(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right)));
}

function max(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(max(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right)));
}

function eq(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (bool) {
    return UniSwapRootKQuantity.unwrap(left) == UniSwapRootKQuantity.unwrap(right);
}

function neq(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (bool) {
    return UniSwapRootKQuantity.unwrap(left) != UniSwapRootKQuantity.unwrap(right);
}

function lt(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (bool) {
    return UniSwapRootKQuantity.unwrap(left) < UniSwapRootKQuantity.unwrap(right);
}

function gt(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (bool) {
    return UniSwapRootKQuantity.unwrap(left) > UniSwapRootKQuantity.unwrap(right);
}

function lte(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (bool) {
    return UniSwapRootKQuantity.unwrap(left) <= UniSwapRootKQuantity.unwrap(right);
}

function gte(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (bool) {
    return UniSwapRootKQuantity.unwrap(left) >= UniSwapRootKQuantity.unwrap(right);
}

function mulDiv(
    UniSwapRootKQuantity left,
    uint256 right,
    uint256 div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    UniSwapRootKQuantity right,
    uint256 div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(left, UniSwapRootKQuantity.unwrap(right), div));
}

function mulDiv(
    UniSwapRootKQuantity left,
    uint256 right,
    UniSwapRootKQuantity div
) pure returns (uint256) {
    return mulDiv(UniSwapRootKQuantity.unwrap(left), right, UniSwapRootKQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (uint256) {
    return mulDiv(left, UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div));
}

// --- USDC-squared -------------------------------------------------------------------------------------------------------------------------------------------
function add(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(UsdcSqQuantity.unwrap(left) + UsdcSqQuantity.unwrap(right));
}

function prod(UsdcSqQuantity val, uint256 x) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(UsdcSqQuantity.unwrap(val) * x);
}

function prod(uint256 x, UsdcSqQuantity val) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(x * UsdcSqQuantity.unwrap(val));
}

function subtract(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(UsdcSqQuantity.unwrap(left) - UsdcSqQuantity.unwrap(right));
}

function min(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(min(UsdcSqQuantity.unwrap(left), UsdcSqQuantity.unwrap(right)));
}

function max(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(max(UsdcSqQuantity.unwrap(left), UsdcSqQuantity.unwrap(right)));
}

function eq(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (bool) {
    return UsdcSqQuantity.unwrap(left) == UsdcSqQuantity.unwrap(right);
}

function neq(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (bool) {
    return UsdcSqQuantity.unwrap(left) != UsdcSqQuantity.unwrap(right);
}

function lt(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (bool) {
    return UsdcSqQuantity.unwrap(left) < UsdcSqQuantity.unwrap(right);
}

function gt(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (bool) {
    return UsdcSqQuantity.unwrap(left) > UsdcSqQuantity.unwrap(right);
}

function lte(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (bool) {
    return UsdcSqQuantity.unwrap(left) <= UsdcSqQuantity.unwrap(right);
}

function gte(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (bool) {
    return UsdcSqQuantity.unwrap(left) >= UsdcSqQuantity.unwrap(right);
}

function mulDiv(
    UsdcSqQuantity left,
    uint256 right,
    uint256 div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    UsdcSqQuantity right,
    uint256 div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(left, UsdcSqQuantity.unwrap(right), div));
}

function mulDiv(
    UsdcSqQuantity left,
    uint256 right,
    UsdcSqQuantity div
) pure returns (uint256) {
    return mulDiv(UsdcSqQuantity.unwrap(left), right, UsdcSqQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (uint256) {
    return mulDiv(left, UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- mulDiv() flexibility -----------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function mulDiv(
    IPeronio.LpQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    IPeronio.LpQuantity right,
    UniSwapRootKQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    UniSwapRootKQuantity right,
    IPeronio.LpQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- USDC-squared quantities --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.UsdcQuantity right,
    uint256 div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), div));
}

function sqrt256(UsdcSqQuantity x) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(sqrt256(UsdcSqQuantity.unwrap(x)));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- UniSwap K-values ---------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function prod(IPeronio.UsdcQuantity left, IPeronio.MaiQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(IPeronio.UsdcQuantity.unwrap(left) * IPeronio.MaiQuantity.unwrap(right));
}

function sqrt256(UniSwapKQuantity x) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(sqrt256(UniSwapKQuantity.unwrap(x)));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- Ratio conversion ---------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function ratio4to6(RatioWith4Decimals x) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(RatioWith4Decimals.unwrap(x) * 10**2);
}
