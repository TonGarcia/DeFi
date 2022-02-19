// LIQUIDATION PRICE CALC
//Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
//ratio = 50;
ratio = 200; // giving 1 ETH to get 50% of it current price
nWeiETH = 1 * 10**18;
expectedStable = 153550;
ethPrice = 307184535214;
ethFloatPrice = ethPrice / 10**8;
((expectedStable * 10**12) * ratio) / nWeiETH;
