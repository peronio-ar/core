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

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- Standard Numeric Types ---------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

// --- USDC ---------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(IPeronio.UsdcQuantity.unwrap(left) + IPeronio.UsdcQuantity.unwrap(right));
}

function prod(IPeronio.UsdcQuantity val, uint256 x) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(IPeronio.UsdcQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.UsdcQuantity val) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(x * IPeronio.UsdcQuantity.unwrap(val));
}

function subtract(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(IPeronio.UsdcQuantity.unwrap(left) - IPeronio.UsdcQuantity.unwrap(right));
}

function min(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(min(IPeronio.UsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right)));
}

function max(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(max(IPeronio.UsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right)));
}

function eq(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (bool) {
    return IPeronio.UsdcQuantity.unwrap(left) == IPeronio.UsdcQuantity.unwrap(right);
}

function neq(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (bool) {
    return IPeronio.UsdcQuantity.unwrap(left) != IPeronio.UsdcQuantity.unwrap(right);
}

function lt(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (bool) {
    return IPeronio.UsdcQuantity.unwrap(left) < IPeronio.UsdcQuantity.unwrap(right);
}

function gt(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (bool) {
    return IPeronio.UsdcQuantity.unwrap(left) > IPeronio.UsdcQuantity.unwrap(right);
}

function lte(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (bool) {
    return IPeronio.UsdcQuantity.unwrap(left) <= IPeronio.UsdcQuantity.unwrap(right);
}

function gte(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (bool) {
    return IPeronio.UsdcQuantity.unwrap(left) >= IPeronio.UsdcQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.UsdcQuantity right,
    uint256 div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(left, IPeronio.UsdcQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    uint256 right,
    IPeronio.UsdcQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.UsdcQuantity.unwrap(left), right, IPeronio.UsdcQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div));
}

// --- MAI ----------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(IPeronio.MaiQuantity.unwrap(left) + IPeronio.MaiQuantity.unwrap(right));
}

function prod(IPeronio.MaiQuantity val, uint256 x) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(IPeronio.MaiQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.MaiQuantity val) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(x * IPeronio.MaiQuantity.unwrap(val));
}

function subtract(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(IPeronio.MaiQuantity.unwrap(left) - IPeronio.MaiQuantity.unwrap(right));
}

function min(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(min(IPeronio.MaiQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right)));
}

function max(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(max(IPeronio.MaiQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right)));
}

function eq(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (bool) {
    return IPeronio.MaiQuantity.unwrap(left) == IPeronio.MaiQuantity.unwrap(right);
}

function neq(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (bool) {
    return IPeronio.MaiQuantity.unwrap(left) != IPeronio.MaiQuantity.unwrap(right);
}

function lt(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (bool) {
    return IPeronio.MaiQuantity.unwrap(left) < IPeronio.MaiQuantity.unwrap(right);
}

function gt(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (bool) {
    return IPeronio.MaiQuantity.unwrap(left) > IPeronio.MaiQuantity.unwrap(right);
}

function lte(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (bool) {
    return IPeronio.MaiQuantity.unwrap(left) <= IPeronio.MaiQuantity.unwrap(right);
}

function gte(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (bool) {
    return IPeronio.MaiQuantity.unwrap(left) >= IPeronio.MaiQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.MaiQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.MaiQuantity right,
    uint256 div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(left, IPeronio.MaiQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    uint256 right,
    IPeronio.MaiQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.MaiQuantity.unwrap(left), right, IPeronio.MaiQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div));
}

// --- LP USDC/MAI --------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(IPeronio.LpQuantity.unwrap(left) + IPeronio.LpQuantity.unwrap(right));
}

function prod(IPeronio.LpQuantity val, uint256 x) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(IPeronio.LpQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.LpQuantity val) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(x * IPeronio.LpQuantity.unwrap(val));
}

function subtract(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(IPeronio.LpQuantity.unwrap(left) - IPeronio.LpQuantity.unwrap(right));
}

function min(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(min(IPeronio.LpQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right)));
}

function max(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(max(IPeronio.LpQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right)));
}

function eq(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (bool) {
    return IPeronio.LpQuantity.unwrap(left) == IPeronio.LpQuantity.unwrap(right);
}

function neq(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (bool) {
    return IPeronio.LpQuantity.unwrap(left) != IPeronio.LpQuantity.unwrap(right);
}

function lt(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (bool) {
    return IPeronio.LpQuantity.unwrap(left) < IPeronio.LpQuantity.unwrap(right);
}

function gt(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (bool) {
    return IPeronio.LpQuantity.unwrap(left) > IPeronio.LpQuantity.unwrap(right);
}

function lte(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (bool) {
    return IPeronio.LpQuantity.unwrap(left) <= IPeronio.LpQuantity.unwrap(right);
}

function gte(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (bool) {
    return IPeronio.LpQuantity.unwrap(left) >= IPeronio.LpQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.LpQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.LpQuantity right,
    uint256 div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(left, IPeronio.LpQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.LpQuantity left,
    uint256 right,
    IPeronio.LpQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.LpQuantity.unwrap(left), right, IPeronio.LpQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div));
}

// --- PE -----------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(IPeronio.PeQuantity.unwrap(left) + IPeronio.PeQuantity.unwrap(right));
}

function prod(IPeronio.PeQuantity val, uint256 x) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(IPeronio.PeQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.PeQuantity val) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(x * IPeronio.PeQuantity.unwrap(val));
}

function subtract(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(IPeronio.PeQuantity.unwrap(left) - IPeronio.PeQuantity.unwrap(right));
}

function min(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(min(IPeronio.PeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right)));
}

function max(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(max(IPeronio.PeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right)));
}

function eq(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (bool) {
    return IPeronio.PeQuantity.unwrap(left) == IPeronio.PeQuantity.unwrap(right);
}

function neq(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (bool) {
    return IPeronio.PeQuantity.unwrap(left) != IPeronio.PeQuantity.unwrap(right);
}

function lt(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (bool) {
    return IPeronio.PeQuantity.unwrap(left) < IPeronio.PeQuantity.unwrap(right);
}

function gt(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (bool) {
    return IPeronio.PeQuantity.unwrap(left) > IPeronio.PeQuantity.unwrap(right);
}

function lte(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (bool) {
    return IPeronio.PeQuantity.unwrap(left) <= IPeronio.PeQuantity.unwrap(right);
}

function gte(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (bool) {
    return IPeronio.PeQuantity.unwrap(left) >= IPeronio.PeQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.PeQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.PeQuantity right,
    uint256 div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(left, IPeronio.PeQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.PeQuantity left,
    uint256 right,
    IPeronio.PeQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.PeQuantity.unwrap(left), right, IPeronio.PeQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div));
}

// --- QI -----------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(IPeronio.QiQuantity.unwrap(left) + IPeronio.QiQuantity.unwrap(right));
}

function prod(IPeronio.QiQuantity val, uint256 x) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(IPeronio.QiQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.QiQuantity val) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(x * IPeronio.QiQuantity.unwrap(val));
}

function subtract(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(IPeronio.QiQuantity.unwrap(left) - IPeronio.QiQuantity.unwrap(right));
}

function min(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(min(IPeronio.QiQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right)));
}

function max(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(max(IPeronio.QiQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right)));
}

function eq(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (bool) {
    return IPeronio.QiQuantity.unwrap(left) == IPeronio.QiQuantity.unwrap(right);
}

function neq(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (bool) {
    return IPeronio.QiQuantity.unwrap(left) != IPeronio.QiQuantity.unwrap(right);
}

function lt(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (bool) {
    return IPeronio.QiQuantity.unwrap(left) < IPeronio.QiQuantity.unwrap(right);
}

function gt(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (bool) {
    return IPeronio.QiQuantity.unwrap(left) > IPeronio.QiQuantity.unwrap(right);
}

function lte(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (bool) {
    return IPeronio.QiQuantity.unwrap(left) <= IPeronio.QiQuantity.unwrap(right);
}

function gte(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (bool) {
    return IPeronio.QiQuantity.unwrap(left) >= IPeronio.QiQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.QiQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.QiQuantity right,
    uint256 div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(left, IPeronio.QiQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.QiQuantity left,
    uint256 right,
    IPeronio.QiQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.QiQuantity.unwrap(left), right, IPeronio.QiQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div));
}

// --- PE/USDC ------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(IPeronio.PePerUsdcQuantity.unwrap(left) + IPeronio.PePerUsdcQuantity.unwrap(right));
}

function prod(IPeronio.PePerUsdcQuantity val, uint256 x) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(IPeronio.PePerUsdcQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.PePerUsdcQuantity val) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(x * IPeronio.PePerUsdcQuantity.unwrap(val));
}

function subtract(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(IPeronio.PePerUsdcQuantity.unwrap(left) - IPeronio.PePerUsdcQuantity.unwrap(right));
}

function min(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(min(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right)));
}

function max(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(max(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right)));
}

function eq(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (bool) {
    return IPeronio.PePerUsdcQuantity.unwrap(left) == IPeronio.PePerUsdcQuantity.unwrap(right);
}

function neq(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (bool) {
    return IPeronio.PePerUsdcQuantity.unwrap(left) != IPeronio.PePerUsdcQuantity.unwrap(right);
}

function lt(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (bool) {
    return IPeronio.PePerUsdcQuantity.unwrap(left) < IPeronio.PePerUsdcQuantity.unwrap(right);
}

function gt(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (bool) {
    return IPeronio.PePerUsdcQuantity.unwrap(left) > IPeronio.PePerUsdcQuantity.unwrap(right);
}

function lte(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (bool) {
    return IPeronio.PePerUsdcQuantity.unwrap(left) <= IPeronio.PePerUsdcQuantity.unwrap(right);
}

function gte(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (bool) {
    return IPeronio.PePerUsdcQuantity.unwrap(left) >= IPeronio.PePerUsdcQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.PePerUsdcQuantity right,
    uint256 div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(left, IPeronio.PePerUsdcQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    uint256 right,
    IPeronio.PePerUsdcQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), right, IPeronio.PePerUsdcQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div));
}

// --- USDC/PE ------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(IPeronio.UsdcPerPeQuantity.unwrap(left) + IPeronio.UsdcPerPeQuantity.unwrap(right));
}

function prod(IPeronio.UsdcPerPeQuantity val, uint256 x) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(IPeronio.UsdcPerPeQuantity.unwrap(val) * x);
}

function prod(uint256 x, IPeronio.UsdcPerPeQuantity val) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(x * IPeronio.UsdcPerPeQuantity.unwrap(val));
}

function subtract(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(IPeronio.UsdcPerPeQuantity.unwrap(left) - IPeronio.UsdcPerPeQuantity.unwrap(right));
}

function min(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(min(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right)));
}

function max(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(max(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right)));
}

function eq(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (bool) {
    return IPeronio.UsdcPerPeQuantity.unwrap(left) == IPeronio.UsdcPerPeQuantity.unwrap(right);
}

function neq(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (bool) {
    return IPeronio.UsdcPerPeQuantity.unwrap(left) != IPeronio.UsdcPerPeQuantity.unwrap(right);
}

function lt(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (bool) {
    return IPeronio.UsdcPerPeQuantity.unwrap(left) < IPeronio.UsdcPerPeQuantity.unwrap(right);
}

function gt(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (bool) {
    return IPeronio.UsdcPerPeQuantity.unwrap(left) > IPeronio.UsdcPerPeQuantity.unwrap(right);
}

function lte(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (bool) {
    return IPeronio.UsdcPerPeQuantity.unwrap(left) <= IPeronio.UsdcPerPeQuantity.unwrap(right);
}

function gte(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (bool) {
    return IPeronio.UsdcPerPeQuantity.unwrap(left) >= IPeronio.UsdcPerPeQuantity.unwrap(right);
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.UsdcPerPeQuantity right,
    uint256 div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(left, IPeronio.UsdcPerPeQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    uint256 right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (uint256) {
    return mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), right, IPeronio.UsdcPerPeQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div));
}

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
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

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
// --- mulDiv() ad-hoc ----------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function mulDiv(
    IPeronio.PeQuantity left,
    uint256 right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), right, IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    uint256 left,
    IPeronio.PeQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(left, IPeronio.PeQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    uint256 right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), right, IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    uint256 left,
    IPeronio.UsdcQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(left, IPeronio.UsdcQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
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
