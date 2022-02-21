// Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
nWeiETH = 1 * 10**18;
ethPrice = 264477535214;
ethFloatPrice = ethPrice / 10**8;
requestStableCoin = 1322.35; // expectedStable
providedCollateral = 200;
liquidationRation = (requestStableCoin * providedCollateral) / ethFloatPrice;
console.log('liquidationRation: ' + liquidationRation);
liquidationPrice = LiquidationPrice * ethFloatPrice;
console.log('liquidationPrice: ' + liquidationPrice);

//Oasis React: vaultDebt.times(liquidationRatio).div(lockedCollateral)

/*
Current price (and provided amount (1ETH)): 2625.73 USD
Generated: 881 USD (Vault Dai Debt)
Provided Ratio: 300.20%
Liquidation Price: 1497.70
Vault Dai Debt 881.00 DAI
Collateral Locked: 1.0000 ETH
----------------------------------------------------------------------------------------------------------
vaultDebt.times(liquidationRatio).div(lockedCollateral) -> (generatedStable*liquidationRatio) / collateral
(881*1.7)/2625.73 = 0.057
(2625.73*0.057)/10000 = 1.496,66
----------------------------------------------------------------------------------------------------------
(881*170)/2625.73 = 0.5703937572
(2625.73*0.5703937572)/(10**12) = 1497,70
----------------------------------------------------------------------------------------------------------
(88100*170*(10**14))/262573 = 5703937571646742
(262573*5703937571646742)/(10**16) = 149770 USD (1497.70)
*/

/*
Current price (and provided amount (1ETH)): 2625.73 USD
Generated: 1555 USD (Vault Dai Debt)
Provided Ratio: 170.08%
Liquidation Price: 2643.50
Vault Dai Debt 1,555.00 DAI
Collateral Locked: 1.0000 ETH
----------------------------------------------------------------------------------------------------------
vaultDebt.times(liquidationRatio).div(lockedCollateral) -> (generatedStable*liquidationRatio) / collateral
(1555*1.7)/2625.73 = 0.1006767642
(2625.73*0.1006767642)/100000000000 = 2643.50
----------------------------------------------------------------------------------------------------------
(1555*170)/2625.73 = 1.0067676418
(2625.73*1.0067676418)/(10**12) = 2643.50 USD
----------------------------------------------------------------------------------------------------------
(155500*170*(10**13))/262573 = 1006767641760577
(262573*1006767641760577)/(10**15) = 264350 USD (2643.50)
----------------------------------------------------------------------------------------------------------
(155500*170*(10**14))/262573 = 10067676417605772
(262573*10067676417605772)/(10**16) = 264350 USD (2643.50)
*/
