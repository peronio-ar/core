# SPDX-License-Identifier: MIT

existingUnits: set[str] = {
    'uint256',
}

interfaceUnits: set[str] = existingUnits | {
    'UsdcQuantity',
    'MaiQuantity',
    'LpQuantity',
    'PeQuantity',
    'QiQuantity',
    'PePerUsdcQuantity',
    'UsdcPerPeQuantity',
    'RatioWith6Decimals',
}

implementationUnits: set[str] = interfaceUnits | {
    'UniSwapKQuantity',
    'UniSwapRootKQuantity',
    'UsdcSqQuantity',
    'RatioWith4Decimals',
}

dimensions: set[str] = { 'INT', 'USDC', 'MAI', 'LP', 'PE', 'QI' }

unitToDimensions: dict[str, dict[str, float]] = {
    'uint256':              { 'INT':  0, 'USDC':  0  , 'MAI': 0  , 'LP': 0, 'PE':  0, 'QI': 0 },  # 10**0
    #
    'UsdcQuantity':         { 'INT':  6, 'USDC':  1  , 'MAI': 0  , 'LP': 0, 'PE':  0, 'QI': 0 },  # USDC (6 decimals)
    'MaiQuantity':          { 'INT': 18, 'USDC':  0  , 'MAI': 1  , 'LP': 0, 'PE':  0, 'QI': 0 },  # MAI (18 decimals)
    'LpQuantity':           { 'INT': 18, 'USDC':  0  , 'MAI': 0  , 'LP': 1, 'PE':  0, 'QI': 0 },  # LP (18 decimals)
    'PeQuantity':           { 'INT':  6, 'USDC':  0  , 'MAI': 0  , 'LP': 0, 'PE':  1, 'QI': 0 },  # PE (6 decimals)
    'QiQuantity':           { 'INT': 18, 'USDC':  0  , 'MAI': 0  , 'LP': 0, 'PE':  0, 'QI': 1 },  # QI (18 decimals)
    'PePerUsdcQuantity':    { 'INT':  6, 'USDC': -1  , 'MAI': 0  , 'LP': 0, 'PE':  1, 'QI': 0 },  # PE / USDC
    'UsdcPerPeQuantity':    { 'INT':  6, 'USDC':  1  , 'MAI': 0  , 'LP': 0, 'PE': -1, 'QI': 0 },  # USDC / PE
    'RatioWith6Decimals':   { 'INT':  6, 'USDC':  0  , 'MAI': 0  , 'LP': 0, 'PE':  0, 'QI': 0 },  # 10**6
    #
    'UniSwapKQuantity':     { 'INT': 24, 'USDC':  1  , 'MAI': 1  , 'LP': 0, 'PE':  0, 'QI': 0 },  # USDC * MAI
    'UniSwapRootKQuantity': { 'INT': 12, 'USDC':  0.5, 'MAI': 0.5, 'LP': 0, 'PE':  0, 'QI': 0 },  # sqrt(USDC * MAI)
    'UsdcSqQuantity':       { 'INT': 12, 'USDC':  2  , 'MAI': 0  , 'LP': 0, 'PE':  0, 'QI': 0 },  # USDC**2
    'RatioWith4Decimals':   { 'INT':  4, 'USDC':  0  , 'MAI': 0  , 'LP': 0, 'PE':  0, 'QI': 0 },  # 10**4
}

def freezeDimensions(dimensions: dict[str, float]) -> tuple[tuple[str, float], ...]:
    return tuple(sorted(dimensions.items()))

frozenDimensionsToUnits: dict[tuple[tuple[str, float], ...], str] = { freezeDimensions(dimensions): unit for unit, dimensions in unitToDimensions.items() }

def mulDivUnit(leftDimensions: dict[str, float], rightDimensions: dict[str, float], divDimensions: dict[str, float]) -> str | None:
    return frozenDimensionsToUnits.get(freezeDimensions({ d: leftDimensions[d] + rightDimensions[d] - divDimensions[d] for d in dimensions }), None)


interfaceOverloads: set[tuple[str, str, str, str]] = set()
implementationOverloads: set[tuple[str, str, str, str]] = set()

for (leftUnit, leftDimensions) in unitToDimensions.items():
    for (rightUnit, rightDimensions) in unitToDimensions.items():
        if leftUnit <= rightUnit:
            for (divUnit, divDimensions) in unitToDimensions.items():
                if (resultUnit := mulDivUnit(leftDimensions, rightDimensions, divDimensions)) is not None:
                    if all(unit in existingUnits for unit in [leftUnit, rightUnit, divUnit, resultUnit]):
                        pass
                    elif all(unit in interfaceUnits for unit in [leftUnit, rightUnit, divUnit, resultUnit]):
                        interfaceOverloads |= {(leftUnit, rightUnit, divUnit, resultUnit)}
                    elif all(unit in implementationUnits for unit in [leftUnit, rightUnit, divUnit, resultUnit]):
                        implementationOverloads |= {(leftUnit, rightUnit, divUnit, resultUnit)}


def wrap(unit: str, value: str) -> str:
    return f'{unit}.wrap({value})' if unit not in existingUnits else f'{value}'

def unwrap(unit: str, value: str) -> str:
    return f'{unit}.unwrap({value})' if unit not in existingUnits else f'{value}'

def mulDiv(leftUnit: str, rightUnit: str, divUnit: str, resultUnit: str) -> str:
    return f"""function mulDiv({leftUnit} left, {rightUnit} right, {divUnit} div) pure returns ({resultUnit}) {{ return {wrap(resultUnit, f"mulDiv({unwrap(leftUnit, 'left')}, {unwrap(rightUnit, 'right')}, {unwrap(divUnit, 'div')})")}; }}"""

def declAll(overloads: set[tuple[str, str, str, str]]) -> str:
    decls: set[str] = set()
    for (leftUnit, rightUnit, divUnit, resultUnit) in overloads:
        decls |= { mulDiv(leftUnit, rightUnit, divUnit, resultUnit) }
        if leftUnit != rightUnit:
            decls |= { mulDiv(rightUnit, leftUnit, divUnit, resultUnit) }
    return '\n'.join(sorted(decls))


print(declAll(interfaceOverloads))
print('-----------')
print(declAll(implementationOverloads))
