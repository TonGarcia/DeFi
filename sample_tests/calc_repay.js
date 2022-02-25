eth1 = 1 * 10**18;
amount = 1000; //repay amount (1000 = US$ 10.00)
eth1Price = 259960505241; // dollar only -> parseInt(eth1Price / 10**6) => int: 259960 = US$ 2599.60
eth1PriceFloat = eth1Price/(10**6);
remainingCollateralPrice = 0; // calc with chainlink
remainingCollateralWei = 20000000000000000;

formula = (remainingCollateralWei*eth1PriceFloat)/eth1;
console.log(formula); // = 5199 -> US$ 51.99
parseInt(formula);
