pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

import "./IPeronio.sol";

import {Math} from "@openzeppelin/contracts_latest/utils/math/Math.sol";

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
// The mulDiv() interactions will be taken care of later.
//

// --- USDC ---------------------------------------------------------------------------------------------------------------------------------------------------
function add(UsdcQuantity left, UsdcQuantity right) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(UsdcQuantity.unwrap(left) + UsdcQuantity.unwrap(right));
}

function sub(UsdcQuantity left, UsdcQuantity right) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(UsdcQuantity.unwrap(left) - UsdcQuantity.unwrap(right));
}

function mul(UsdcQuantity val, uint256 x) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(UsdcQuantity.unwrap(val) * x);
}

function mul(uint256 x, UsdcQuantity val) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(x * UsdcQuantity.unwrap(val));
}

function min(UsdcQuantity left, UsdcQuantity right) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.min(UsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right)));
}

function max(UsdcQuantity left, UsdcQuantity right) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.max(UsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right)));
}

function eq(UsdcQuantity left, UsdcQuantity right) pure returns (bool) {
    return UsdcQuantity.unwrap(left) == UsdcQuantity.unwrap(right);
}

function neq(UsdcQuantity left, UsdcQuantity right) pure returns (bool) {
    return UsdcQuantity.unwrap(left) != UsdcQuantity.unwrap(right);
}

function lt(UsdcQuantity left, UsdcQuantity right) pure returns (bool) {
    return UsdcQuantity.unwrap(left) < UsdcQuantity.unwrap(right);
}

function gt(UsdcQuantity left, UsdcQuantity right) pure returns (bool) {
    return UsdcQuantity.unwrap(left) > UsdcQuantity.unwrap(right);
}

function lte(UsdcQuantity left, UsdcQuantity right) pure returns (bool) {
    return UsdcQuantity.unwrap(left) <= UsdcQuantity.unwrap(right);
}

function gte(UsdcQuantity left, UsdcQuantity right) pure returns (bool) {
    return UsdcQuantity.unwrap(left) >= UsdcQuantity.unwrap(right);
}

// --- MAI ----------------------------------------------------------------------------------------------------------------------------------------------------
function add(MaiQuantity left, MaiQuantity right) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(MaiQuantity.unwrap(left) + MaiQuantity.unwrap(right));
}

function sub(MaiQuantity left, MaiQuantity right) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(MaiQuantity.unwrap(left) - MaiQuantity.unwrap(right));
}

function mul(MaiQuantity val, uint256 x) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(MaiQuantity.unwrap(val) * x);
}

function mul(uint256 x, MaiQuantity val) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(x * MaiQuantity.unwrap(val));
}

function min(MaiQuantity left, MaiQuantity right) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.min(MaiQuantity.unwrap(left), MaiQuantity.unwrap(right)));
}

function max(MaiQuantity left, MaiQuantity right) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.max(MaiQuantity.unwrap(left), MaiQuantity.unwrap(right)));
}

function eq(MaiQuantity left, MaiQuantity right) pure returns (bool) {
    return MaiQuantity.unwrap(left) == MaiQuantity.unwrap(right);
}

function neq(MaiQuantity left, MaiQuantity right) pure returns (bool) {
    return MaiQuantity.unwrap(left) != MaiQuantity.unwrap(right);
}

function lt(MaiQuantity left, MaiQuantity right) pure returns (bool) {
    return MaiQuantity.unwrap(left) < MaiQuantity.unwrap(right);
}

function gt(MaiQuantity left, MaiQuantity right) pure returns (bool) {
    return MaiQuantity.unwrap(left) > MaiQuantity.unwrap(right);
}

function lte(MaiQuantity left, MaiQuantity right) pure returns (bool) {
    return MaiQuantity.unwrap(left) <= MaiQuantity.unwrap(right);
}

function gte(MaiQuantity left, MaiQuantity right) pure returns (bool) {
    return MaiQuantity.unwrap(left) >= MaiQuantity.unwrap(right);
}

// --- LP USDC/MAI --------------------------------------------------------------------------------------------------------------------------------------------
function add(LpQuantity left, LpQuantity right) pure returns (LpQuantity) {
    return LpQuantity.wrap(LpQuantity.unwrap(left) + LpQuantity.unwrap(right));
}

function sub(LpQuantity left, LpQuantity right) pure returns (LpQuantity) {
    return LpQuantity.wrap(LpQuantity.unwrap(left) - LpQuantity.unwrap(right));
}

function mul(LpQuantity val, uint256 x) pure returns (LpQuantity) {
    return LpQuantity.wrap(LpQuantity.unwrap(val) * x);
}

function mul(uint256 x, LpQuantity val) pure returns (LpQuantity) {
    return LpQuantity.wrap(x * LpQuantity.unwrap(val));
}

function min(LpQuantity left, LpQuantity right) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.min(LpQuantity.unwrap(left), LpQuantity.unwrap(right)));
}

function max(LpQuantity left, LpQuantity right) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.max(LpQuantity.unwrap(left), LpQuantity.unwrap(right)));
}

function eq(LpQuantity left, LpQuantity right) pure returns (bool) {
    return LpQuantity.unwrap(left) == LpQuantity.unwrap(right);
}

function neq(LpQuantity left, LpQuantity right) pure returns (bool) {
    return LpQuantity.unwrap(left) != LpQuantity.unwrap(right);
}

function lt(LpQuantity left, LpQuantity right) pure returns (bool) {
    return LpQuantity.unwrap(left) < LpQuantity.unwrap(right);
}

function gt(LpQuantity left, LpQuantity right) pure returns (bool) {
    return LpQuantity.unwrap(left) > LpQuantity.unwrap(right);
}

function lte(LpQuantity left, LpQuantity right) pure returns (bool) {
    return LpQuantity.unwrap(left) <= LpQuantity.unwrap(right);
}

function gte(LpQuantity left, LpQuantity right) pure returns (bool) {
    return LpQuantity.unwrap(left) >= LpQuantity.unwrap(right);
}

// --- PE -----------------------------------------------------------------------------------------------------------------------------------------------------
function add(PeQuantity left, PeQuantity right) pure returns (PeQuantity) {
    return PeQuantity.wrap(PeQuantity.unwrap(left) + PeQuantity.unwrap(right));
}

function sub(PeQuantity left, PeQuantity right) pure returns (PeQuantity) {
    return PeQuantity.wrap(PeQuantity.unwrap(left) - PeQuantity.unwrap(right));
}

function mul(PeQuantity val, uint256 x) pure returns (PeQuantity) {
    return PeQuantity.wrap(PeQuantity.unwrap(val) * x);
}

function mul(uint256 x, PeQuantity val) pure returns (PeQuantity) {
    return PeQuantity.wrap(x * PeQuantity.unwrap(val));
}

function min(PeQuantity left, PeQuantity right) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.min(PeQuantity.unwrap(left), PeQuantity.unwrap(right)));
}

function max(PeQuantity left, PeQuantity right) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.max(PeQuantity.unwrap(left), PeQuantity.unwrap(right)));
}

function eq(PeQuantity left, PeQuantity right) pure returns (bool) {
    return PeQuantity.unwrap(left) == PeQuantity.unwrap(right);
}

function neq(PeQuantity left, PeQuantity right) pure returns (bool) {
    return PeQuantity.unwrap(left) != PeQuantity.unwrap(right);
}

function lt(PeQuantity left, PeQuantity right) pure returns (bool) {
    return PeQuantity.unwrap(left) < PeQuantity.unwrap(right);
}

function gt(PeQuantity left, PeQuantity right) pure returns (bool) {
    return PeQuantity.unwrap(left) > PeQuantity.unwrap(right);
}

function lte(PeQuantity left, PeQuantity right) pure returns (bool) {
    return PeQuantity.unwrap(left) <= PeQuantity.unwrap(right);
}

function gte(PeQuantity left, PeQuantity right) pure returns (bool) {
    return PeQuantity.unwrap(left) >= PeQuantity.unwrap(right);
}

// --- QI -----------------------------------------------------------------------------------------------------------------------------------------------------
function add(QiQuantity left, QiQuantity right) pure returns (QiQuantity) {
    return QiQuantity.wrap(QiQuantity.unwrap(left) + QiQuantity.unwrap(right));
}

function sub(QiQuantity left, QiQuantity right) pure returns (QiQuantity) {
    return QiQuantity.wrap(QiQuantity.unwrap(left) - QiQuantity.unwrap(right));
}

function mul(QiQuantity val, uint256 x) pure returns (QiQuantity) {
    return QiQuantity.wrap(QiQuantity.unwrap(val) * x);
}

function mul(uint256 x, QiQuantity val) pure returns (QiQuantity) {
    return QiQuantity.wrap(x * QiQuantity.unwrap(val));
}

function min(QiQuantity left, QiQuantity right) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.min(QiQuantity.unwrap(left), QiQuantity.unwrap(right)));
}

function max(QiQuantity left, QiQuantity right) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.max(QiQuantity.unwrap(left), QiQuantity.unwrap(right)));
}

function eq(QiQuantity left, QiQuantity right) pure returns (bool) {
    return QiQuantity.unwrap(left) == QiQuantity.unwrap(right);
}

function neq(QiQuantity left, QiQuantity right) pure returns (bool) {
    return QiQuantity.unwrap(left) != QiQuantity.unwrap(right);
}

function lt(QiQuantity left, QiQuantity right) pure returns (bool) {
    return QiQuantity.unwrap(left) < QiQuantity.unwrap(right);
}

function gt(QiQuantity left, QiQuantity right) pure returns (bool) {
    return QiQuantity.unwrap(left) > QiQuantity.unwrap(right);
}

function lte(QiQuantity left, QiQuantity right) pure returns (bool) {
    return QiQuantity.unwrap(left) <= QiQuantity.unwrap(right);
}

function gte(QiQuantity left, QiQuantity right) pure returns (bool) {
    return QiQuantity.unwrap(left) >= QiQuantity.unwrap(right);
}

// --- PE/USDC ------------------------------------------------------------------------------------------------------------------------------------------------
function add(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(PePerUsdcQuantity.unwrap(left) + PePerUsdcQuantity.unwrap(right));
}

function sub(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(PePerUsdcQuantity.unwrap(left) - PePerUsdcQuantity.unwrap(right));
}

function mul(PePerUsdcQuantity val, uint256 x) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(PePerUsdcQuantity.unwrap(val) * x);
}

function mul(uint256 x, PePerUsdcQuantity val) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(x * PePerUsdcQuantity.unwrap(val));
}

function min(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.min(PePerUsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right)));
}

function max(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.max(PePerUsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right)));
}

function eq(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (bool) {
    return PePerUsdcQuantity.unwrap(left) == PePerUsdcQuantity.unwrap(right);
}

function neq(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (bool) {
    return PePerUsdcQuantity.unwrap(left) != PePerUsdcQuantity.unwrap(right);
}

function lt(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (bool) {
    return PePerUsdcQuantity.unwrap(left) < PePerUsdcQuantity.unwrap(right);
}

function gt(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (bool) {
    return PePerUsdcQuantity.unwrap(left) > PePerUsdcQuantity.unwrap(right);
}

function lte(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (bool) {
    return PePerUsdcQuantity.unwrap(left) <= PePerUsdcQuantity.unwrap(right);
}

function gte(PePerUsdcQuantity left, PePerUsdcQuantity right) pure returns (bool) {
    return PePerUsdcQuantity.unwrap(left) >= PePerUsdcQuantity.unwrap(right);
}

// --- USDC/PE ------------------------------------------------------------------------------------------------------------------------------------------------
function add(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(UsdcPerPeQuantity.unwrap(left) + UsdcPerPeQuantity.unwrap(right));
}

function sub(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(UsdcPerPeQuantity.unwrap(left) - UsdcPerPeQuantity.unwrap(right));
}

function mul(UsdcPerPeQuantity val, uint256 x) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(UsdcPerPeQuantity.unwrap(val) * x);
}

function mul(uint256 x, UsdcPerPeQuantity val) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(x * UsdcPerPeQuantity.unwrap(val));
}

function min(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.min(UsdcPerPeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right)));
}

function max(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.max(UsdcPerPeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right)));
}

function eq(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (bool) {
    return UsdcPerPeQuantity.unwrap(left) == UsdcPerPeQuantity.unwrap(right);
}

function neq(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (bool) {
    return UsdcPerPeQuantity.unwrap(left) != UsdcPerPeQuantity.unwrap(right);
}

function lt(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (bool) {
    return UsdcPerPeQuantity.unwrap(left) < UsdcPerPeQuantity.unwrap(right);
}

function gt(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (bool) {
    return UsdcPerPeQuantity.unwrap(left) > UsdcPerPeQuantity.unwrap(right);
}

function lte(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (bool) {
    return UsdcPerPeQuantity.unwrap(left) <= UsdcPerPeQuantity.unwrap(right);
}

function gte(UsdcPerPeQuantity left, UsdcPerPeQuantity right) pure returns (bool) {
    return UsdcPerPeQuantity.unwrap(left) >= UsdcPerPeQuantity.unwrap(right);
}

// --- 6-decimals ratio ---------------------------------------------------------------------------------------------------------------------------------------
function add(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(RatioWith6Decimals.unwrap(left) + RatioWith6Decimals.unwrap(right));
}

function sub(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(RatioWith6Decimals.unwrap(left) - RatioWith6Decimals.unwrap(right));
}

function mul(RatioWith6Decimals val, uint256 x) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(RatioWith6Decimals.unwrap(val) * x);
}

function mul(uint256 x, RatioWith6Decimals val) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(x * RatioWith6Decimals.unwrap(val));
}

function min(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.min(RatioWith6Decimals.unwrap(left), RatioWith6Decimals.unwrap(right)));
}

function max(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.max(RatioWith6Decimals.unwrap(left), RatioWith6Decimals.unwrap(right)));
}

function eq(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (bool) {
    return RatioWith6Decimals.unwrap(left) == RatioWith6Decimals.unwrap(right);
}

function neq(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (bool) {
    return RatioWith6Decimals.unwrap(left) != RatioWith6Decimals.unwrap(right);
}

function lt(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (bool) {
    return RatioWith6Decimals.unwrap(left) < RatioWith6Decimals.unwrap(right);
}

function gt(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (bool) {
    return RatioWith6Decimals.unwrap(left) > RatioWith6Decimals.unwrap(right);
}

function lte(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (bool) {
    return RatioWith6Decimals.unwrap(left) <= RatioWith6Decimals.unwrap(right);
}

function gte(RatioWith6Decimals left, RatioWith6Decimals right) pure returns (bool) {
    return RatioWith6Decimals.unwrap(left) >= RatioWith6Decimals.unwrap(right);
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- MulDiv Interactions ------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function mulDiv(
    LpQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    MaiQuantity right,
    LpQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), MaiQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    PePerUsdcQuantity right,
    LpQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    PeQuantity right,
    LpQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), PeQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    QiQuantity right,
    LpQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), QiQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    RatioWith6Decimals right,
    LpQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(LpQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UsdcPerPeQuantity right,
    LpQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UsdcQuantity right,
    LpQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), UsdcQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    uint256 right,
    LpQuantity div
) pure returns (uint256) {
    return Math.mulDiv(LpQuantity.unwrap(left), right, LpQuantity.unwrap(div));
}

function mulDiv(
    LpQuantity left,
    uint256 right,
    uint256 div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(LpQuantity.unwrap(left), right, div));
}

function mulDiv(
    MaiQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    LpQuantity right,
    MaiQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), LpQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    PePerUsdcQuantity right,
    MaiQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    PeQuantity right,
    MaiQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), PeQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    QiQuantity right,
    MaiQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), QiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    RatioWith6Decimals right,
    MaiQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(MaiQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcPerPeQuantity right,
    MaiQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcQuantity right,
    MaiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), UsdcQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    uint256 right,
    MaiQuantity div
) pure returns (uint256) {
    return Math.mulDiv(MaiQuantity.unwrap(left), right, MaiQuantity.unwrap(div));
}

function mulDiv(
    MaiQuantity left,
    uint256 right,
    uint256 div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(MaiQuantity.unwrap(left), right, div));
}

function mulDiv(
    PePerUsdcQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    LpQuantity right,
    PePerUsdcQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), LpQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    MaiQuantity right,
    PePerUsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    PeQuantity right,
    PePerUsdcQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), PeQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    QiQuantity right,
    PePerUsdcQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), QiQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    RatioWith6Decimals right,
    PePerUsdcQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcPerPeQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcPerPeQuantity right,
    RatioWith6Decimals div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcQuantity right,
    PeQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcQuantity right,
    RatioWith6Decimals div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    uint256 right,
    PePerUsdcQuantity div
) pure returns (uint256) {
    return Math.mulDiv(PePerUsdcQuantity.unwrap(left), right, PePerUsdcQuantity.unwrap(div));
}

function mulDiv(
    PePerUsdcQuantity left,
    uint256 right,
    uint256 div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PePerUsdcQuantity.unwrap(left), right, div));
}

function mulDiv(
    PeQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    LpQuantity right,
    PeQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), LpQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    MaiQuantity right,
    PeQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), MaiQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    PePerUsdcQuantity right,
    PeQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    QiQuantity right,
    PeQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), QiQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    RatioWith6Decimals right,
    PePerUsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    RatioWith6Decimals right,
    PeQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(PeQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    RatioWith6Decimals right,
    UsdcQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcPerPeQuantity right,
    PeQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcPerPeQuantity right,
    RatioWith6Decimals div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcPerPeQuantity right,
    UsdcQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(PeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcQuantity right,
    PeQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), UsdcQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    uint256 right,
    PeQuantity div
) pure returns (uint256) {
    return Math.mulDiv(PeQuantity.unwrap(left), right, PeQuantity.unwrap(div));
}

function mulDiv(
    PeQuantity left,
    uint256 right,
    uint256 div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(PeQuantity.unwrap(left), right, div));
}

function mulDiv(
    QiQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    LpQuantity right,
    QiQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), LpQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    MaiQuantity right,
    QiQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), MaiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    PePerUsdcQuantity right,
    QiQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    PeQuantity right,
    QiQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), PeQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    RatioWith6Decimals right,
    QiQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(QiQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UsdcPerPeQuantity right,
    QiQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UsdcQuantity right,
    QiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), UsdcQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    uint256 right,
    QiQuantity div
) pure returns (uint256) {
    return Math.mulDiv(QiQuantity.unwrap(left), right, QiQuantity.unwrap(div));
}

function mulDiv(
    QiQuantity left,
    uint256 right,
    uint256 div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(QiQuantity.unwrap(left), right, div));
}

function mulDiv(
    RatioWith6Decimals left,
    LpQuantity right,
    LpQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    LpQuantity right,
    RatioWith6Decimals div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), LpQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    MaiQuantity right,
    RatioWith6Decimals div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), MaiQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    PePerUsdcQuantity right,
    RatioWith6Decimals div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), PePerUsdcQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    PeQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), PeQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    PeQuantity right,
    PeQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    PeQuantity right,
    RatioWith6Decimals div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), PeQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    PeQuantity right,
    UsdcQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), PeQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    QiQuantity right,
    QiQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    QiQuantity right,
    RatioWith6Decimals div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), QiQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    RatioWith6Decimals right,
    PePerUsdcQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), RatioWith6Decimals.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    RatioWith6Decimals right,
    UsdcPerPeQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), RatioWith6Decimals.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcPerPeQuantity right,
    RatioWith6Decimals div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), UsdcPerPeQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcQuantity right,
    PeQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), UsdcQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcQuantity right,
    RatioWith6Decimals div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), UsdcQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcQuantity right,
    UsdcPerPeQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), UsdcQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    uint256 right,
    RatioWith6Decimals div
) pure returns (uint256) {
    return Math.mulDiv(RatioWith6Decimals.unwrap(left), right, RatioWith6Decimals.unwrap(div));
}

function mulDiv(
    RatioWith6Decimals left,
    uint256 right,
    uint256 div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(RatioWith6Decimals.unwrap(left), right, div));
}

function mulDiv(
    UsdcPerPeQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    LpQuantity right,
    UsdcPerPeQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), LpQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    MaiQuantity right,
    UsdcPerPeQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), MaiQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PePerUsdcQuantity right,
    RatioWith6Decimals div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PePerUsdcQuantity right,
    UsdcPerPeQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PeQuantity right,
    RatioWith6Decimals div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PeQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PeQuantity right,
    UsdcPerPeQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    PeQuantity right,
    UsdcQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), PeQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    QiQuantity right,
    UsdcPerPeQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), QiQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    RatioWith6Decimals right,
    UsdcPerPeQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UsdcQuantity right,
    UsdcPerPeQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    uint256 right,
    UsdcPerPeQuantity div
) pure returns (uint256) {
    return Math.mulDiv(UsdcPerPeQuantity.unwrap(left), right, UsdcPerPeQuantity.unwrap(div));
}

function mulDiv(
    UsdcPerPeQuantity left,
    uint256 right,
    uint256 div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcPerPeQuantity.unwrap(left), right, div));
}

function mulDiv(
    UsdcQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    LpQuantity right,
    UsdcQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), LpQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    MaiQuantity right,
    UsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    PePerUsdcQuantity right,
    PeQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    PePerUsdcQuantity right,
    RatioWith6Decimals div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    PePerUsdcQuantity right,
    UsdcQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    PeQuantity right,
    UsdcQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), PeQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    QiQuantity right,
    UsdcQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), QiQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    RatioWith6Decimals right,
    PeQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    RatioWith6Decimals right,
    UsdcPerPeQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    RatioWith6Decimals right,
    UsdcQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UsdcPerPeQuantity right,
    UsdcQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    uint256 right,
    UsdcQuantity div
) pure returns (uint256) {
    return Math.mulDiv(UsdcQuantity.unwrap(left), right, UsdcQuantity.unwrap(div));
}

function mulDiv(
    UsdcQuantity left,
    uint256 right,
    uint256 div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(UsdcQuantity.unwrap(left), right, div));
}

function mulDiv(
    uint256 left,
    LpQuantity right,
    LpQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, LpQuantity.unwrap(right), LpQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    LpQuantity right,
    uint256 div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(Math.mulDiv(left, LpQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, MaiQuantity.unwrap(right), MaiQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    MaiQuantity right,
    uint256 div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(Math.mulDiv(left, MaiQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    PePerUsdcQuantity right,
    uint256 div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(Math.mulDiv(left, PePerUsdcQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    PeQuantity right,
    PeQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, PeQuantity.unwrap(right), PeQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    PeQuantity right,
    uint256 div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(Math.mulDiv(left, PeQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    QiQuantity right,
    QiQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, QiQuantity.unwrap(right), QiQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    QiQuantity right,
    uint256 div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(Math.mulDiv(left, QiQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (uint256) {
    return Math.mulDiv(left, RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div));
}

function mulDiv(
    uint256 left,
    RatioWith6Decimals right,
    uint256 div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(Math.mulDiv(left, RatioWith6Decimals.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UsdcPerPeQuantity right,
    uint256 div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(Math.mulDiv(left, UsdcPerPeQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (uint256) {
    return Math.mulDiv(left, UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UsdcQuantity right,
    uint256 div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(Math.mulDiv(left, UsdcQuantity.unwrap(right), div));
}
