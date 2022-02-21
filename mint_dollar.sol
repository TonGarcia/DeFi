// SPDX-License-Identifier: none
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MintDollar is ERC20 {
    uint8 private _decimal = 2;
    uint private _liquidationRatio = 170;
    uint private _minMintableStablecoin = 1000; // US$ 10.00
    mapping(address => Collateral[]) lockedCollateralsDB;

    modifier auth {
        require(lockedCollateralsDB[msg.sender].length > 0, "Wallet wihout caollaterals");
        _;
    }

    /**
      * Collateral Strcut
      * lockedCollateral = received ether on the transaction (ETH in WEI units)
      * remainingCollateral = not yet repaid, if zero it user was liquidated or got it back
      * mintedStableCoin = amount of StableCoin added to the user on the collateralization action
      * ratio = margin, stored to get back in time, because it liquidation ration can change along the time
    */
    struct Collateral {
        uint256 lockedCollateral;
        uint256 remainingCollateral;
        uint256 mintedStableCoin;
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
     * params
     * vaultDebt = how much StableCoin to be minted
    */
    function collaterallize(uint256 vaultDebt) external payable {
        // start the collateralization
        uint256 eth1 = 10 ** 18;
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

        // Check if the asked/bid value is the minimal mintable stablecoin
        require(_minMintableStablecoin <= vaultDebt, "The min ask for vault debt is US$ 10.00");

        // Calculate to check if the received value on the transaction match with the asked/bid
        uint calcVaultDebt = (lockedCollateral * _globalPrice) / eth1; // amount to be minted
        require(_minMintableStablecoin <= calcVaultDebt, "The received ETH doesn't mint the minimal amount of US$ 10.00");

        // Provided Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
        uint providedRatio = calcProvidedRatio(lockedCollateral, globalPrice, vaultDebt);
        bool ratioOk = (providedRatio >= _liquidationRatio); // _liquidationRatio = _minCollateralRatio
        require(ratioOk, "The amount asked vs. paid ETH diverges for the liquidation ratio: 170%");

        // Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
        uint liquidationPrice = estimateLiquidationPrice(vaultDebt, uint16(_globalPrice));

        // Mint the stablecoin
        _mint(msg.sender, vaultDebt);

        // Store the calculated data
        lockedCollateralsDB[msg.sender].push(
            Collateral(
                lockedCollateral,
                remainingCollateral,
                vaultDebt, // mintedStableCoin
                liquidationPrice
            )
        );
    }

    /**
     *
     *
    */
    function repay() external payable {

    }

    // ##########################
    // #  CONVERTION FUNCTIONS  #
    // ##########################

    /*
     * Liquidation Ratio = (Collateral Amount x Collateral Price) ÷ Generated Stable × 100
    */
    function calcProvidedRatio(uint256 collateredEthInWei, int globalPrice, uint256 expectedStable) 
                                      public pure returns (uint providedRatio) {
        uint ethFloatPrice = uint(globalPrice/ 10**8);
        return (collateredEthInWei * ethFloatPrice) / (expectedStable * 10**12 * 100);
    }

    /*
     * vaultDebt = amount to be minted
     * currentPrice = price (1000 = US$ 10.00)
     * Liquidation Price = (Generated Stable * Liquidation Ratio) / (Amount of Collateral)
    */
    function estimateLiquidationPrice(uint256 vaultDebt, uint16 currentPrice) 
                                      public view returns (uint liquidationPrice) {
        uint256 calcLiquidationRatio = (vaultDebt*_liquidationRatio*(10**14))/currentPrice;
        return (currentPrice*calcLiquidationRatio)/(10**16); // liquidationPrice
    }

    // #######################
    // # ORACLE INTEGRATION  #
    // #######################

    /**
     * Returns the latest price
     * sample return manipulation: 307184535214 / 10**8 = US$ 3071.84
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
               ((floatPrice * amount) / eth1),
               startedAt,
               timeStamp,
               answeredInRound);
    }

}
