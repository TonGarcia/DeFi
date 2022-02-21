eth1 = 1 * 10**18; 
nWei = 2000000000000000000; // 1 ETH = 1000000000000000000 WEI
globalPrice = 262573; // 2625.73
// floatPrice =  globalPrice/100;

// ((nWei * floatPrice) / eth1);
calcPrice = ((nWei * globalPrice) / eth1);
//parseInt(calcPrice)/100;
parseInt(calcPrice);

lockedCollateral = 1000000000000000;
calcVaultDebt = parseInt((lockedCollateral * globalPrice) / eth1);
_minMintableStablecoin = 1000;

console.log(calcVaultDebt);
_minMintableStablecoin <= calcVaultDebt;