// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/* 
 * ETH/USD price will be received from Chainlink Oracles prices feed aggregator.
 * more: https://docs.chain.link/docs/using-chainlink-reference-contracts
 */

contract Oracle {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Rinkeby
     * Aggregator: ETH/USD
     * Dec: 8
     * Address: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
     * Addresses on the networks: https://docs.chain.link/docs/ethereum-addresses/
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    }

    /**
     * Returns the latest price
     * sample manipulation: 307184535214 / 10**8 = US$ 3071.84
     */
    function getETHUSD(int amount) public view returns (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) {
        if(amount == 0) {
            amount = 1;
        }

        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return (roundID, price, startedAt, timeStamp, answeredInRound);
    }

}