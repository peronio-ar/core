pragma solidity ^0.8.16;

// SPDX-License-Identifier: MIT

import {IPeronio} from "./IPeronio.sol";
import {max, min, mulDiv} from "./Utils.sol";

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- Standard Numeric Types ---------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// Standard Numeric Types (SNTs) can be operated with in the same manner as "normal" numeric types can.
// This means that SNTs can:
//   - be added together,
//   - be subtracted from each other,
//   - be multiplied by a scalar value (only uint256 in this implementation) - both on the left and on the right,
//   - the minimum be calculated among them,
//   - the maximum be calculated among them,
//   - the "==", "!=", "<=", "<", ">", and ">=" relations established between them, and
//   - the "mulDiv" operation applied to them so that:
//     - all arguments are SNT instances,
//     - an SNT instance is multiplied and divided by scalar quantities, yielding an SNT instance, and
//     - a scalar quantity is multiplied by and divided by SNT instances, yielding a scalar quantity.
//

// --- USDC ---------------------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(IPeronio.UsdcQuantity.unwrap(left) + IPeronio.UsdcQuantity.unwrap(right));
}

function sub(IPeronio.UsdcQuantity left, IPeronio.UsdcQuantity right) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(IPeronio.UsdcQuantity.unwrap(left) - IPeronio.UsdcQuantity.unwrap(right));
}

function mul(IPeronio.UsdcQuantity val, uint256 x) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(IPeronio.UsdcQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.UsdcQuantity val) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(x * IPeronio.UsdcQuantity.unwrap(val));
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
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
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

function sub(IPeronio.MaiQuantity left, IPeronio.MaiQuantity right) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(IPeronio.MaiQuantity.unwrap(left) - IPeronio.MaiQuantity.unwrap(right));
}

function mul(IPeronio.MaiQuantity val, uint256 x) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(IPeronio.MaiQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.MaiQuantity val) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(x * IPeronio.MaiQuantity.unwrap(val));
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
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
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

function sub(IPeronio.LpQuantity left, IPeronio.LpQuantity right) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(IPeronio.LpQuantity.unwrap(left) - IPeronio.LpQuantity.unwrap(right));
}

function mul(IPeronio.LpQuantity val, uint256 x) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(IPeronio.LpQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.LpQuantity val) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(x * IPeronio.LpQuantity.unwrap(val));
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
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
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

function sub(IPeronio.PeQuantity left, IPeronio.PeQuantity right) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(IPeronio.PeQuantity.unwrap(left) - IPeronio.PeQuantity.unwrap(right));
}

function mul(IPeronio.PeQuantity val, uint256 x) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(IPeronio.PeQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.PeQuantity val) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(x * IPeronio.PeQuantity.unwrap(val));
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
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
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

function sub(IPeronio.QiQuantity left, IPeronio.QiQuantity right) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(IPeronio.QiQuantity.unwrap(left) - IPeronio.QiQuantity.unwrap(right));
}

function mul(IPeronio.QiQuantity val, uint256 x) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(IPeronio.QiQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.QiQuantity val) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(x * IPeronio.QiQuantity.unwrap(val));
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
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
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

function sub(IPeronio.PePerUsdcQuantity left, IPeronio.PePerUsdcQuantity right) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(IPeronio.PePerUsdcQuantity.unwrap(left) - IPeronio.PePerUsdcQuantity.unwrap(right));
}

function mul(IPeronio.PePerUsdcQuantity val, uint256 x) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(IPeronio.PePerUsdcQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.PePerUsdcQuantity val) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(x * IPeronio.PePerUsdcQuantity.unwrap(val));
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
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
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

function sub(IPeronio.UsdcPerPeQuantity left, IPeronio.UsdcPerPeQuantity right) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(IPeronio.UsdcPerPeQuantity.unwrap(left) - IPeronio.UsdcPerPeQuantity.unwrap(right));
}

function mul(IPeronio.UsdcPerPeQuantity val, uint256 x) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(IPeronio.UsdcPerPeQuantity.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.UsdcPerPeQuantity val) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(x * IPeronio.UsdcPerPeQuantity.unwrap(val));
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
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
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

// --- 6-decimals ratio ---------------------------------------------------------------------------------------------------------------------------------------
function add(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(IPeronio.RatioWith6Decimals.unwrap(left) + IPeronio.RatioWith6Decimals.unwrap(right));
}

function sub(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(IPeronio.RatioWith6Decimals.unwrap(left) - IPeronio.RatioWith6Decimals.unwrap(right));
}

function mul(IPeronio.RatioWith6Decimals val, uint256 x) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(IPeronio.RatioWith6Decimals.unwrap(val) * x);
}

function mul(uint256 x, IPeronio.RatioWith6Decimals val) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(x * IPeronio.RatioWith6Decimals.unwrap(val));
}

function min(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(min(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right)));
}

function max(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(max(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right)));
}

function eq(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (bool) {
    return IPeronio.RatioWith6Decimals.unwrap(left) == IPeronio.RatioWith6Decimals.unwrap(right);
}

function neq(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (bool) {
    return IPeronio.RatioWith6Decimals.unwrap(left) != IPeronio.RatioWith6Decimals.unwrap(right);
}

function lt(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (bool) {
    return IPeronio.RatioWith6Decimals.unwrap(left) < IPeronio.RatioWith6Decimals.unwrap(right);
}

function gt(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (bool) {
    return IPeronio.RatioWith6Decimals.unwrap(left) > IPeronio.RatioWith6Decimals.unwrap(right);
}

function lte(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (bool) {
    return IPeronio.RatioWith6Decimals.unwrap(left) <= IPeronio.RatioWith6Decimals.unwrap(right);
}

function gte(IPeronio.RatioWith6Decimals left, IPeronio.RatioWith6Decimals right) pure returns (bool) {
    return IPeronio.RatioWith6Decimals.unwrap(left) >= IPeronio.RatioWith6Decimals.unwrap(right);
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    uint256 right,
    uint256 div
) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    IPeronio.RatioWith6Decimals right,
    uint256 div
) pure returns (IPeronio.RatioWith6Decimals) {
    return IPeronio.RatioWith6Decimals.wrap(mulDiv(left, IPeronio.RatioWith6Decimals.unwrap(right), div));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    uint256 right,
    IPeronio.RatioWith6Decimals div
) pure returns (uint256) {
    return mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), right, IPeronio.RatioWith6Decimals.unwrap(div));
}

function mulDiv(
    uint256 left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (uint256) {
    return mulDiv(left, IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- mulDiv() Identities ------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------
//
// The following are simple overloads that take care of generalizations upon the "mulDiv" cases referenced above.
// In particular: when multiplying and dividing by one type, the other is returned.
//

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
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(
            mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(
            mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(
            mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.UsdcQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.UsdcQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.UsdcQuantity.unwrap(div))
        );
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
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return
        IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return
        IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return
        IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.MaiQuantity) {
    return
        IPeronio.MaiQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.MaiQuantity) {
    return
        IPeronio.MaiQuantity.wrap(
            mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.MaiQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.MaiQuantity) {
    return
        IPeronio.MaiQuantity.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.MaiQuantity right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.MaiQuantity.unwrap(right), IPeronio.MaiQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.MaiQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.MaiQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.MaiQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.MaiQuantity.unwrap(div))
        );
}

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
    IPeronio.LpQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.LpQuantity) {
    return IPeronio.LpQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.LpQuantity) {
    return
        IPeronio.LpQuantity.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.LpQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.LpQuantity) {
    return
        IPeronio.LpQuantity.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.LpQuantity right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.LpQuantity.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.LpQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.LpQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.LpQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.LpQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.PeQuantity) {
    return
        IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.PeQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.PeQuantity) {
    return
        IPeronio.PeQuantity.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.PeQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.QiQuantity) {
    return IPeronio.QiQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.QiQuantity) {
    return
        IPeronio.QiQuantity.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.QiQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.QiQuantity) {
    return
        IPeronio.QiQuantity.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.QiQuantity right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.QiQuantity.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.QiQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.QiQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(mulDiv(IPeronio.QiQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.QiQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.PePerUsdcQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.PePerUsdcQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div))
        );
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.UsdcPerPeQuantity div
) pure returns (IPeronio.RatioWith6Decimals) {
    return
        IPeronio.RatioWith6Decimals.wrap(
            mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.UsdcPerPeQuantity.unwrap(div))
        );
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
    IPeronio.PeQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.PeQuantity right,
    IPeronio.UsdcQuantity div
) pure returns (IPeronio.PePerUsdcQuantity) {
    return
        IPeronio.PePerUsdcQuantity.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.UsdcQuantity.unwrap(div)));
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

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.RatioWith6Decimals right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.RatioWith6Decimals.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.RatioWith6Decimals left,
    IPeronio.UsdcQuantity right,
    IPeronio.PeQuantity div
) pure returns (IPeronio.UsdcPerPeQuantity) {
    return
        IPeronio.UsdcPerPeQuantity.wrap(mulDiv(IPeronio.RatioWith6Decimals.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.PeQuantity.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.PePerUsdcQuantity right,
    uint256 div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.UsdcQuantity right,
    uint256 div
) pure returns (IPeronio.PeQuantity) {
    return IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.UsdcQuantity left,
    IPeronio.PePerUsdcQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.PeQuantity) {
    return
        IPeronio.PeQuantity.wrap(mulDiv(IPeronio.UsdcQuantity.unwrap(left), IPeronio.PePerUsdcQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.PePerUsdcQuantity left,
    IPeronio.UsdcQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.PeQuantity) {
    return
        IPeronio.PeQuantity.wrap(mulDiv(IPeronio.PePerUsdcQuantity.unwrap(left), IPeronio.UsdcQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    uint256 div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.PeQuantity right,
    uint256 div
) pure returns (IPeronio.UsdcQuantity) {
    return IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), div));
}

function mulDiv(
    IPeronio.PeQuantity left,
    IPeronio.UsdcPerPeQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.PeQuantity.unwrap(left), IPeronio.UsdcPerPeQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    IPeronio.UsdcPerPeQuantity left,
    IPeronio.PeQuantity right,
    IPeronio.RatioWith6Decimals div
) pure returns (IPeronio.UsdcQuantity) {
    return
        IPeronio.UsdcQuantity.wrap(mulDiv(IPeronio.UsdcPerPeQuantity.unwrap(left), IPeronio.PeQuantity.unwrap(right), IPeronio.RatioWith6Decimals.unwrap(div)));
}
