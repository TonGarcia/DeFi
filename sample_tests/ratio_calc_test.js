// LIQUIDATION RATIO CALC
//Liquidation Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
//expectedStable = 307100; // 100%
expectedStable = 153550; // 50% receiving back, so it collateral ratio is 200%
nWeiETH = 1 * 10**18;
ethPrice = 307184535214;
ethFloatPrice = ethPrice / 10**8;
//((nWeiETH * (ethPrice * 10**7)) / expectedStable) * 100;
parseInt((nWeiETH * ethFloatPrice) / (expectedStable * 10**12 * 100));
