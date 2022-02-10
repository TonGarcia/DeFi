// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract StableCollateral is ERC20 {

    /**
        Sample Token Data
        name = "Mint Dollar"
        symbol = "USDM"
        add to deploy input: "Mint Dollar","USDM"
    **/
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100.000.000 tokens to msg.sender
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        // 100 * 10**uint(decimals()) == 100 units and 100000000000000000000 min units
        // 100000000 * 10**uint(decimals()) == 100.000.000 units and 100000000000000000000 min units
        _mint(msg.sender, 100000000 * 10**uint(decimals()));
    }

    

}