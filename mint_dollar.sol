// SPDX-License-Identifier: none
// "Mint Dollar","USDM",100000
pragma solidity ^0.8.12;

//import "hardhat/console.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MintDollar is ERC20 {
    uint8 private _decimal = 2;
    uint private _liquidationRatio = 170;
    uint private _maxMintableRatio = 5882; // 58.82%
    uint private _minMintableStablecoin = 1000; // US$ 10.00
    mapping(address => Collateral[]) lockedCollateralsDB;

    modifier auth {
        require(lockedCollateralsDB[msg.sender].length > 0, "Wallet without any collaterals");
        _;
    }

    /**
      * Collateral Strcut
      * @param lockedCollateral = received ether on the transaction (ETH in WEI units)
      * @param remainingCollateral = not yet repaid, if zero it user was liquidated or got it back
      * @param vaultDebt = amount of StableCoin added to the user on the collateralization action
      * @param liquidationPrice = price which the balance gonna be liquidated
      * ratio = margin, stored to get back in time, because it liquidation ration can change along the time
    */
    struct Collateral {
        uint256 lockedCollateral;
        uint256 remainingCollateral;
        uint256 vaultDebt;
        uint liquidationPrice;
    }

    // ETH price oracle
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Mainnet
     * Aggregator: ETH/USD
     * Dec: 8
     * Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
     * Addresses on the networks: https://docs.chain.link/docs/ethereum-addresses/
    */
    address _mainChainlinkETHUSD = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Dec: 8
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     * Addresses on the networks: https://docs.chain.link/docs/ethereum-addresses/
    */
    address _rinkebyChainlinkETHUSD = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;

    // Constructor on deploy contract: "Mint Dollar","USDM",100000
    constructor(string memory name, string memory symbol, uint _initialSupply) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender = 100 * 10**uint(decimals())
        // Mint 100.000.000 tokens to msg.sender = 100000000 * 10**uint(decimals())
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        // 100 * 10**uint(decimals()) == 100 units and 100000000000000000000 min units
        // 100000000 * 10**uint(decimals()) == 100.000.000 units and 100000000000000000000 min units
        _mint(msg.sender, _initialSupply * 10**uint(decimals()));

        //address chainlinkETHUSD = _mainChainlinkETHUSD;
        address chainlinkETHUSD = _rinkebyChainlinkETHUSD;

        // Instantiate chainlink oracle client
        priceFeed = AggregatorV3Interface(chainlinkETHUSD);
    }

    // Override the decimals to 2 decimals to look like stable coin
    function decimals() public view virtual override returns (uint8) {
        return _decimal;
    }

    /**
     * Receive the account
     * Returns all user's collaterals
    */
    function getCollateralsEthOf(address account) public view virtual returns(Collateral[] memory) {
        require(account == address(account),"Invalid address account");
        return lockedCollateralsDB[account];
    }

    /**
     * Receives the ether
     * Calculate the ratio
     * Store the ether on the user address
     * Mint stablecoin
     * Send the minted stablecoin to the user address
     * @param vaultDebt = how much StableCoin to be minted
    */
    function collaterallize(uint256 vaultDebt) external payable {
        // start the collateralization
        //uint256 eth1 = 10 ** 18;
        uint256 lockedCollateral = msg.value;
        uint256 remainingCollateral = lockedCollateral;

        // calculate the received ETH in dollar amount
        (
            , //uint80 roundID
            int globalPrice,
            , //uint unitsPrice
            , //uint startedAt
            , //uint timeStamp
            // uint80 answeredInRound
        ) = getETHUSD(lockedCollateral);
        uint256 _globalPrice = uint256(globalPrice);

        // calculate the received ETH in dollar amount
        (
            , //uint80 roundID
            int _collateralUSD,
            , //uint unitsPrice
            , //uint startedAt
            , //uint timeStamp
            // uint80 answeredInRound
        ) = getETHUSD(lockedCollateral);
        uint256 collateralUSD = uint256(_collateralUSD);

        // Check if the asked/bid value is greater than the minimal mintable stablecoin
        require(_minMintableStablecoin <= vaultDebt, "The received ETH doesn't mint the minimal amount of US$ 10.00");

        // Calculate to check if the received ether fit the vaultDebt required
        uint calcVaultDebt = estimateMaxMintableStable(lockedCollateral, _globalPrice); // amount to be minted
        require(_minMintableStablecoin <= calcVaultDebt, "The received ETH doesn't mint the minimal amount of US$ 10.00");
        require(calcVaultDebt >= vaultDebt, "The received ETH doesn't fit to collaterize the asked amount vaultDebt");

        // Provided Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
        uint providedRatio = calcProvidedRatio(lockedCollateral, globalPrice, vaultDebt);
        require(providedRatio >= _liquidationRatio, "The amount asked vs. paid ETH diverges for the liquidation ratio: 170%");

        // Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
        uint liquidationPrice = estimateLiquidationPrice(calcVaultDebt, _globalPrice, collateralUSD);

        // Mint the stablecoin
        _mint(msg.sender, vaultDebt);

        // Store the calculated data
        lockedCollateralsDB[msg.sender].push(
            Collateral(
                lockedCollateral,
                remainingCollateral,
                calcVaultDebt, // mintedStableCoin
                liquidationPrice
            )
        );
    }

    /**
     * Repay the user collateral burning it stable and sending back the user ether
     * @param idxCollateral is the index of the collateral on the DB for the msg.sender address 
     * @param amount is the amount in stablecoin to be refunded to unlock collateral
    */
    function repay(uint idxCollateral, uint256 amount) external auth {
        // aux vars
        // uint256 eth1 = 1 * 10**18;
        Collateral memory collateral = lockedCollateralsDB[msg.sender][idxCollateral];

        // the minimal repay it the minimal mintable
        require(_minMintableStablecoin < amount, "The received ETH doesn't mint the minimal amount of US$ 10.00");

        // calculate the remain collateral repay in dollar amount
        (
            , //uint80 roundID
            , //int ethPrice
            uint256 remainingCollateralPrice,
            , //uint startedAt
            , //uint timeStamp
            // uint80 answeredInRound
        ) = getETHUSD(collateral.remainingCollateral);

        // only fullfill repay strategy (mintedStableCoin = vaultDebt)
        string memory errorMsg = string(
                                abi.encodeWithSignature("The received amount: US$ (uint256) is less than the vaultDebt: US$ (uint256)", 
                                amount, collateral.vaultDebt)
                            );

        require(remainingCollateralPrice != amount, errorMsg);

        // burn the stablecoins
        uint256 currentBalance = balanceOf(msg.sender);
        _burn(msg.sender, amount);
        require(balanceOf(msg.sender) == (currentBalance - amount), "Unable to burn/repay");

        // refund the user ethers
        bool sent = payable(msg.sender).send(collateral.remainingCollateral);
        require(sent, "Failed to refund the account. The system was unable to send ether.");
    }

    // ##########################
    // #  CONVERTION FUNCTIONS  #
    // ##########################

    /** 
     * Estimate the max mintable based on the provided ETH
     * @param lockedCollateral is the amount weis locked
     * @param globalPrice is the price on oracle format (10 ** 8)
    **/
    function estimateMaxMintableStable(uint256 lockedCollateral, uint256 globalPrice) 
                                        public view returns (uint maxMintableStable) {
        uint256 eth1 = 10 ** 18;

        if(lockedCollateral == 0 || globalPrice == 0) {
             // calculate the received ETH in dollar amount
            (
                , //uint80 roundID
                int _globalPrice,
                , //uint unitsPrice
                , //uint startedAt
                , //uint timeStamp
                // uint80 answeredInRound
            ) = getETHUSD(lockedCollateral);

            globalPrice = uint256(_globalPrice);
        }

        return (((globalPrice*lockedCollateral)/eth1)*(_maxMintableRatio/100)) / 10**8;
    }

    /*
     * Liquidation Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
    */
    function calcProvidedRatio(uint256 lockedCollateral, int currentPrice, uint256 expectedStable) 
                                      public view returns (uint providedRatio) {

        if(currentPrice == 0) {
            // calculate the received ETH in dollar amount
            (
                , //uint80 roundID
                int _globalPrice,
                , //uint unitsPrice
                , //uint startedAt
                , //uint timeStamp
                // uint80 answeredInRound
            ) = getETHUSD(lockedCollateral);

            currentPrice = int(_globalPrice);
        }

        uint ethFloatPrice = uint(currentPrice/ 10**8);
        return (lockedCollateral * ethFloatPrice) / (expectedStable * 10**12);
    }

    /*
     * vaultDebt = amount to be minted
     * currentPrice = price (1000 = US$ 10.00)
     * Liquidation Price = ((Generated Stable * Liquidation Ratio) / (Amount of Collateral in dollar)) * Current Price
    */
    function estimateLiquidationPrice(uint256 vaultDebt, uint256 currentPrice, uint256 collateralUSD) 
                                      public view returns (uint liquidationPrice) {

        uint256 eth1 = 10 ** 18;

        if(currentPrice == 0) {
            // calculate the received ETH in dollar amount
            (
                , //uint80 roundID
                int _globalPrice,
                , //uint unitsPrice
                , //uint startedAt
                , //uint timeStamp
                // uint80 answeredInRound
            ) = getETHUSD(eth1);

            currentPrice = uint256(_globalPrice);
        }

        return (((vaultDebt*_liquidationRatio)/collateralUSD) * currentPrice) / 10 ** 8;
    }

    // #######################
    // # ORACLE INTEGRATION  #
    // #######################

    /**
     * Returns the latest price
     * sample return manipulation: 307184535214 / 10**8 = US$ 3071.84
     * globalPrice = the price with the max decimals precision
     * unitsPrice = the price in stablecoin precision (2 float decimals)
     */
    function getETHUSD(uint256 amount) 
                       public view returns (
                           uint80 roundID, 
                           int256 globalPrice, 
                           uint256 unitsPrice, 
                           uint startedAt, 
                           uint timeStamp, 
                           uint80 answeredInRound) {

        // 1 ETH means 10**18 WEI
        uint eth1 = 10 ** 18;

        // if the amount is less or equals 1, so it considers 1 ETH, if it is greater than 1 it considers weis
        if(amount <= 1) {
            amount = eth1;
        }

        // retrieve the data from the oracle
        (
            roundID,
            globalPrice,
            startedAt,
            timeStamp,
            answeredInRound
        ) = priceFeed.latestRoundData();

        uint256 floatPrice = uint256(globalPrice / 10**8);

        // format the output
        return (roundID,
                globalPrice,
               ((floatPrice * amount * 100) / eth1),
               startedAt,
               timeStamp,
               answeredInRound);
    }

}
