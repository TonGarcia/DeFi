// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract MintDollar is ERC20 {
    uint8 private _decimal = 2;
    mapping(address => Collateral[]) collateralEthDB;
    
    /** 
      * Collateral Strcut
      * collateredEthInWei = received ether on the transaction
      * remainingEth = not yet payedback, if zero it user was liquidated
      * receivedStablecoin = amount of stablecoin added to the user on the collateralization action
      * ratio = margin. Used to calculate the receivedStable and how much stablecoin to get back the collateral: (ratio+100)/100 * ...
    */
    struct Collateral {
        uint256 collateredEthInWei;
        uint256 remainingEthInWei;
        uint256 receivedStablecoin;
        uint ratio;
    }

    // ETH price oracle
    AggregatorV3Interface internal priceFeed;
    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Dec: 8
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     * Addresses on the networks: https://docs.chain.link/docs/ethereum-addresses/
     */
     address rinkebyETHUSD = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;
     address chainlinkETHUSD = 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e;

    // Constructor on deploy contract: "Mint Dollar - UniswapV2","USDM",100000
    constructor(string memory name, string memory symbol, uint _initialSupply) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender = 100 * 10**uint(decimals())
        // Mint 100.000.000 tokens to msg.sender = 100000000 * 10**uint(decimals())
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        // 100 * 10**uint(decimals()) == 100 units and 100000000000000000000 min units
        // 100000000 * 10**uint(decimals()) == 100.000.000 units and 100000000000000000000 min units
        _mint(msg.sender, _initialSupply * 10**uint(decimals()));

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
        return collateralEthDB[account];
    }

    /**
     * Receives the ether
     * Calculate the ratio
     * Store the ether on the user address
     * Mint stablecoin
     * Send the minted stablecoin to the user address
    */
    function collaterallize() external payable {
        uint256 collateredEthInWei = msg.value;
        uint256 remainingEthInWei = collateredEthInWei;
        
        // calculate the received ETH in dollar amount
        (
            uint80 roundID, 
            uint price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = getETHUSD(collateredEthInWei);
        
        // TODO: calculate the ratio
        uint ratio;

        // TODO calculate the minted stablecoin
        uint256 receivedStablecoin;

        collateralEthDB[msg.sender] += msg.value;
        
        
        // TODO: deposit stablecoin on the user wallet
    }

    /** 
     * 
     * 
    */
    function repay() external payable {

    }

    // #######################
    // # ORACLE INTEGRATION  #
    // #######################

    /**
     * Returns the latest price
     * sample return manipulation: 307184535214 / 10**8 = US$ 3071.84
     */
    function getETHUSD(uint256 amount) public view returns (uint80 roundID, uint256 price, uint startedAt, uint timeStamp, uint80 answeredInRound) {
        // 1 ETH means 10**18 WEI
        uint eth1 = 10 ** 18;

        // helper to convert price
        int partialPrice;
        
        // if the amount is less or equals 1, so it considers 1 ETH, if it is greater than 1 it considers weis
        if(amount <= 1) {
            amount = eth1;
        }

        // retrieve the data from the oracle
        (
            roundID, 
            partialPrice,
            startedAt,
            timeStamp,
            answeredInRound
        ) = priceFeed.latestRoundData();

        // format the output
        return (roundID, 
               ((uint256(partialPrice) * amount) / eth1),
               startedAt,
               timeStamp,
               answeredInRound);
    }

}