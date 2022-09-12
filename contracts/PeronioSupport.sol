pragma solidity ^0.8.17;

// SPDX-License-Identifier: MIT

import "./IPeronioSupport.sol";
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

// --- UniSwap K ----------------------------------------------------------------------------------------------------------------------------------------------
function add(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UniSwapKQuantity.unwrap(left) + UniSwapKQuantity.unwrap(right));
}

function sub(UniSwapKQuantity left, UniSwapKQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UniSwapKQuantity.unwrap(left) - UniSwapKQuantity.unwrap(right));
}

function mul(UniSwapKQuantity val, uint256 x) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UniSwapKQuantity.unwrap(val) * x);
}

function mul(uint256 x, UniSwapKQuantity val) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(x * UniSwapKQuantity.unwrap(val));
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

// --- UniSwap rootK ------------------------------------------------------------------------------------------------------------------------------------------
function add(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(UniSwapRootKQuantity.unwrap(left) + UniSwapRootKQuantity.unwrap(right));
}

function sub(UniSwapRootKQuantity left, UniSwapRootKQuantity right) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(UniSwapRootKQuantity.unwrap(left) - UniSwapRootKQuantity.unwrap(right));
}

function mul(UniSwapRootKQuantity val, uint256 x) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(UniSwapRootKQuantity.unwrap(val) * x);
}

function mul(uint256 x, UniSwapRootKQuantity val) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(x * UniSwapRootKQuantity.unwrap(val));
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

// --- USDC-squared -------------------------------------------------------------------------------------------------------------------------------------------
function add(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(UsdcSqQuantity.unwrap(left) + UsdcSqQuantity.unwrap(right));
}

function sub(UsdcSqQuantity left, UsdcSqQuantity right) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(UsdcSqQuantity.unwrap(left) - UsdcSqQuantity.unwrap(right));
}

function mul(UsdcSqQuantity val, uint256 x) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(UsdcSqQuantity.unwrap(val) * x);
}

function mul(uint256 x, UsdcSqQuantity val) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(x * UsdcSqQuantity.unwrap(val));
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

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- USDC-squared quantities --------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function sqrt256(UsdcSqQuantity x) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(sqrt256(UsdcSqQuantity.unwrap(x)));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- UniSwap K-values ---------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function mul(UsdcQuantity left, MaiQuantity right) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(UsdcQuantity.unwrap(left) * MaiQuantity.unwrap(right));
}

function sqrt256(UniSwapKQuantity x) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(sqrt256(UniSwapKQuantity.unwrap(x)));
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- Ratio conversion ---------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function ratio4to6(RatioWith4Decimals x) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(RatioWith4Decimals.unwrap(x) * 10**2);
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------
// --- MulDiv Interactions ------------------------------------------------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------------------------------------------------------------------------

function mulDiv(
    LpQuantity left,
    RatioWith4Decimals right,
    LpQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(LpQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(LpQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UniSwapKQuantity right,
    LpQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(LpQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(LpQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UniSwapRootKQuantity right,
    LpQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(LpQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(LpQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UsdcSqQuantity right,
    LpQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(LpQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    LpQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(LpQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    RatioWith4Decimals right,
    MaiQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(MaiQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UniSwapKQuantity right,
    MaiQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UniSwapRootKQuantity right,
    MaiQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcQuantity right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(MaiQuantity.unwrap(left), UsdcQuantity.unwrap(right), UniSwapKQuantity.unwrap(div));
}

function mulDiv(
    MaiQuantity left,
    UsdcQuantity right,
    UniSwapRootKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UsdcQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcQuantity right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UsdcQuantity.unwrap(right), div));
}

function mulDiv(
    MaiQuantity left,
    UsdcSqQuantity right,
    MaiQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcSqQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcSqQuantity right,
    UsdcQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    MaiQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(MaiQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    RatioWith4Decimals right,
    PePerUsdcQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UniSwapKQuantity right,
    PePerUsdcQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UniSwapRootKQuantity right,
    PePerUsdcQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcSqQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    PePerUsdcQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(PePerUsdcQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    RatioWith4Decimals right,
    PeQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(PeQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(PeQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UniSwapKQuantity right,
    PeQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(PeQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(PeQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UniSwapRootKQuantity right,
    PeQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(PeQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(PeQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcSqQuantity right,
    PeQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(PeQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    PeQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(PeQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    RatioWith4Decimals right,
    QiQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(QiQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(QiQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UniSwapKQuantity right,
    QiQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(QiQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(QiQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UniSwapRootKQuantity right,
    QiQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(QiQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(QiQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UsdcSqQuantity right,
    QiQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(QiQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    QiQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(QiQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    LpQuantity right,
    LpQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    LpQuantity right,
    RatioWith4Decimals div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), LpQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    MaiQuantity right,
    RatioWith4Decimals div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), MaiQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    PePerUsdcQuantity right,
    RatioWith4Decimals div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), PePerUsdcQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    PeQuantity right,
    PeQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    PeQuantity right,
    RatioWith4Decimals div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), PeQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    QiQuantity right,
    QiQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    QiQuantity right,
    RatioWith4Decimals div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), QiQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    RatioWith6Decimals right,
    RatioWith4Decimals div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UniSwapKQuantity right,
    RatioWith4Decimals div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UniSwapKQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UniSwapRootKQuantity right,
    RatioWith4Decimals div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UniSwapRootKQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UsdcPerPeQuantity right,
    RatioWith4Decimals div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UsdcPerPeQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UsdcQuantity right,
    RatioWith4Decimals div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UsdcQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UsdcSqQuantity right,
    RatioWith4Decimals div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UsdcSqQuantity.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith4Decimals left,
    uint256 right,
    RatioWith4Decimals div
) pure returns (uint256) {
    return mulDiv(RatioWith4Decimals.unwrap(left), right, RatioWith4Decimals.unwrap(div));
}

function mulDiv(
    RatioWith4Decimals left,
    uint256 right,
    uint256 div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith4Decimals.unwrap(left), right, div));
}

function mulDiv(
    RatioWith6Decimals left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(RatioWith6Decimals.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    RatioWith4Decimals right,
    RatioWith6Decimals div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(RatioWith6Decimals.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UniSwapKQuantity right,
    RatioWith6Decimals div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(RatioWith6Decimals.unwrap(left), UniSwapKQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(RatioWith6Decimals.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UniSwapRootKQuantity right,
    RatioWith6Decimals div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(RatioWith6Decimals.unwrap(left), UniSwapRootKQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(RatioWith6Decimals.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcSqQuantity right,
    RatioWith6Decimals div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(RatioWith6Decimals.unwrap(left), UsdcSqQuantity.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    RatioWith6Decimals left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(RatioWith6Decimals.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    LpQuantity right,
    UniSwapKQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), LpQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    MaiQuantity right,
    UniSwapKQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), MaiQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    PePerUsdcQuantity right,
    UniSwapKQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    PeQuantity right,
    UniSwapKQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), PeQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    QiQuantity right,
    UniSwapKQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), QiQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    RatioWith4Decimals right,
    UniSwapKQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(UniSwapKQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    RatioWith6Decimals right,
    UniSwapKQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(UniSwapKQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UniSwapRootKQuantity right,
    UniSwapKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcPerPeQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcQuantity right,
    MaiQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcQuantity right,
    UsdcSqQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcSqQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    MaiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), right, MaiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(UniSwapKQuantity.unwrap(left), right, UniSwapKQuantity.unwrap(div));
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    UniSwapRootKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), right, UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    UsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), right, UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapKQuantity left,
    uint256 right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapKQuantity.unwrap(left), right, div));
}

function mulDiv(
    UniSwapRootKQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    LpQuantity right,
    UniSwapRootKQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), LpQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    MaiQuantity right,
    UniSwapRootKQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), MaiQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    PePerUsdcQuantity right,
    UniSwapRootKQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    PeQuantity right,
    UniSwapRootKQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), PeQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    QiQuantity right,
    UniSwapRootKQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), QiQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    RatioWith4Decimals right,
    UniSwapRootKQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    RatioWith6Decimals right,
    UniSwapRootKQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapRootKQuantity right,
    MaiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapRootKQuantity right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapRootKQuantity right,
    UsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UniSwapRootKQuantity right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), div));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UsdcPerPeQuantity right,
    UniSwapRootKQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UsdcQuantity right,
    UniSwapRootKQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UsdcQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UsdcSqQuantity right,
    UniSwapRootKQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UniSwapRootKQuantity left,
    uint256 right,
    UniSwapRootKQuantity div
) pure returns (uint256) {
    return mulDiv(UniSwapRootKQuantity.unwrap(left), right, UniSwapRootKQuantity.unwrap(div));
}

function mulDiv(
    UniSwapRootKQuantity left,
    uint256 right,
    uint256 div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UniSwapRootKQuantity.unwrap(left), right, div));
}

function mulDiv(
    UsdcPerPeQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    RatioWith4Decimals right,
    UsdcPerPeQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UniSwapKQuantity right,
    UsdcPerPeQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UniSwapRootKQuantity right,
    UsdcPerPeQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UsdcSqQuantity right,
    UsdcPerPeQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcPerPeQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UsdcPerPeQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    MaiQuantity right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(UsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), UniSwapKQuantity.unwrap(div));
}

function mulDiv(
    UsdcQuantity left,
    MaiQuantity right,
    UniSwapRootKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    MaiQuantity right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), MaiQuantity.unwrap(right), div));
}

function mulDiv(
    UsdcQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    RatioWith4Decimals right,
    UsdcQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(UsdcQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UniSwapKQuantity right,
    MaiQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UniSwapKQuantity right,
    UsdcQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UniSwapKQuantity right,
    UsdcSqQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UniSwapRootKQuantity right,
    UsdcQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UsdcQuantity right,
    UsdcSqQuantity div
) pure returns (uint256) {
    return mulDiv(UsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcSqQuantity.unwrap(div));
}

function mulDiv(
    UsdcQuantity left,
    UsdcQuantity right,
    uint256 div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UsdcQuantity.unwrap(right), div));
}

function mulDiv(
    UsdcQuantity left,
    UsdcSqQuantity right,
    UsdcQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    LpQuantity right,
    LpQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), LpQuantity.unwrap(right), LpQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    LpQuantity right,
    UsdcSqQuantity div
) pure returns (LpQuantity) {
    return LpQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), LpQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    MaiQuantity right,
    MaiQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), MaiQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    MaiQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), MaiQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    MaiQuantity right,
    UsdcQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), MaiQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    MaiQuantity right,
    UsdcSqQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), MaiQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    PePerUsdcQuantity right,
    PePerUsdcQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), PePerUsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    PePerUsdcQuantity right,
    UsdcSqQuantity div
) pure returns (PePerUsdcQuantity) {
    return PePerUsdcQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), PePerUsdcQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    PeQuantity right,
    PeQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), PeQuantity.unwrap(right), PeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    PeQuantity right,
    UsdcSqQuantity div
) pure returns (PeQuantity) {
    return PeQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), PeQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    QiQuantity right,
    QiQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), QiQuantity.unwrap(right), QiQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    QiQuantity right,
    UsdcSqQuantity div
) pure returns (QiQuantity) {
    return QiQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), QiQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    RatioWith4Decimals right,
    UsdcSqQuantity div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(UsdcSqQuantity.unwrap(left), RatioWith4Decimals.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    RatioWith6Decimals right,
    RatioWith6Decimals div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), RatioWith6Decimals.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    RatioWith6Decimals right,
    UsdcSqQuantity div
) pure returns (RatioWith6Decimals) {
    return RatioWith6Decimals.wrap(mulDiv(UsdcSqQuantity.unwrap(left), RatioWith6Decimals.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UniSwapKQuantity right,
    UsdcSqQuantity div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UniSwapKQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UniSwapRootKQuantity right,
    UsdcSqQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UniSwapRootKQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UsdcPerPeQuantity right,
    UsdcPerPeQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcPerPeQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UsdcPerPeQuantity right,
    UsdcSqQuantity div
) pure returns (UsdcPerPeQuantity) {
    return UsdcPerPeQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UsdcPerPeQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UsdcQuantity right,
    UsdcQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UsdcQuantity right,
    UsdcSqQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UsdcQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    uint256 right,
    UsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(UsdcSqQuantity.unwrap(left), right, UsdcQuantity.unwrap(div)));
}

function mulDiv(
    UsdcSqQuantity left,
    uint256 right,
    UsdcSqQuantity div
) pure returns (uint256) {
    return mulDiv(UsdcSqQuantity.unwrap(left), right, UsdcSqQuantity.unwrap(div));
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
    RatioWith4Decimals right,
    RatioWith4Decimals div
) pure returns (uint256) {
    return mulDiv(left, RatioWith4Decimals.unwrap(right), RatioWith4Decimals.unwrap(div));
}

function mulDiv(
    uint256 left,
    RatioWith4Decimals right,
    uint256 div
) pure returns (RatioWith4Decimals) {
    return RatioWith4Decimals.wrap(mulDiv(left, RatioWith4Decimals.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    MaiQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(left, UniSwapKQuantity.unwrap(right), MaiQuantity.unwrap(div)));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    UniSwapKQuantity div
) pure returns (uint256) {
    return mulDiv(left, UniSwapKQuantity.unwrap(right), UniSwapKQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    UniSwapRootKQuantity div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(left, UniSwapKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div)));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    UsdcQuantity div
) pure returns (MaiQuantity) {
    return MaiQuantity.wrap(mulDiv(left, UniSwapKQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    uint256 left,
    UniSwapKQuantity right,
    uint256 div
) pure returns (UniSwapKQuantity) {
    return UniSwapKQuantity.wrap(mulDiv(left, UniSwapKQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    UniSwapRootKQuantity right,
    UniSwapRootKQuantity div
) pure returns (uint256) {
    return mulDiv(left, UniSwapRootKQuantity.unwrap(right), UniSwapRootKQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UniSwapRootKQuantity right,
    uint256 div
) pure returns (UniSwapRootKQuantity) {
    return UniSwapRootKQuantity.wrap(mulDiv(left, UniSwapRootKQuantity.unwrap(right), div));
}

function mulDiv(
    uint256 left,
    UsdcSqQuantity right,
    UsdcQuantity div
) pure returns (UsdcQuantity) {
    return UsdcQuantity.wrap(mulDiv(left, UsdcSqQuantity.unwrap(right), UsdcQuantity.unwrap(div)));
}

function mulDiv(
    uint256 left,
    UsdcSqQuantity right,
    UsdcSqQuantity div
) pure returns (uint256) {
    return mulDiv(left, UsdcSqQuantity.unwrap(right), UsdcSqQuantity.unwrap(div));
}

function mulDiv(
    uint256 left,
    UsdcSqQuantity right,
    uint256 div
) pure returns (UsdcSqQuantity) {
    return UsdcSqQuantity.wrap(mulDiv(left, UsdcSqQuantity.unwrap(right), div));
}
