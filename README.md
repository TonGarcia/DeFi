# DeFi

This repository contains the core smart contracts for the DeFi Mint Dollar.

# Features

1. Receive & Store ether
1. Mint stable coin giving ether as collateral
1. Burn stable coin receiving ether back
1. Calculate it collateral based on real ether price based on uniswap
1. Calculate the risk to decide the ratio autonomously
1. Available to use uniswap integration on v2 and v3 and available for chainlink oracles integrations

# Development

## Hardhat workflow
1. install hardhat: https://hardhat.org/getting-started/
1. 

## Remix workflow
To test this project you need to install the remixd following the steps:
1. Install remixd: ``` npm i -g @remix-project/remixd ```
1. Run it server: ``` remixd -s . ```
1. Open https://remix.ethereum.org/
1. Edit the solidity source code desired
1. Compile and test it non flat file
1. FOR PRODUCTION
    1. Enable plugin Flatterner
    1. Flat the file changed
    1. Compile the Flat file
    1. 
1. Chainlink integration
    1. Go to chainlink faucet to get chainlink tokens
    1. Add chainlink to metamask on the assets tab on button add token (chainlink address on rinkeby: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709)
    1. Updating the contract balance:
        1. To perform the contract actions we need to have some ether balance to pay the gas fees
        1. To interact with the chainlink the contract need to also have chainlink balance
    1. 
