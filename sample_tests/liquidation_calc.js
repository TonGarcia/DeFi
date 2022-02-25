collateral = 45000000000000000;
currentPrice = 261398847162;
vaultDebt = 1000;
liquidationRatio = 170;
calcLiquidationRatio = (vaultDebt*liquidationRatio*(10**14))/currentPrice;
(currentPrice*calcLiquidationRatio)/(10**16) // -> 1700
