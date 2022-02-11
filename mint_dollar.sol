// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract MintDollar is ERC20 {

    mapping(address => uint) collateralEth;

    // Constructor on deploy contract: "Mint Dollar","USDM",1000
    constructor(string memory name, string memory symbol, uint _initialSupply) ERC20(name, symbol) {
        // Mint 100 tokens to msg.sender = 100 * 10**uint(decimals())
        // Mint 100.000.000 tokens to msg.sender = 100000000 * 10**uint(decimals())
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        // 100 * 10**uint(decimals()) == 100 units and 100000000000000000000 min units
        // 100000000 * 10**uint(decimals()) == 100.000.000 units and 100000000000000000000 min units
        _mint(msg.sender, _initialSupply * 10**uint(decimals()));
    }

    // Override the decimals to 2 decimals to look like stable coin
    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function mint() external payable {
        collateralEth[msg.sender] += msg.value;
    }

}