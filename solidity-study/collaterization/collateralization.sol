// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract StableCollateral is ERC20 {

    /**
      *  Smart contract values example
      *  passing to deploy: "Mint Dollar","USDM"
      *  name = "Mint Dollar"
      *  symbol = "USDM"
     **/
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        // Mint 100.000.000 tokens to msg.sender = _mint(msg.sender, 100000000 * 10**uint(decimals()));
        // Mint 10 tokens to msg.sender = _mint(msg.sender, 10 * 10**uint(decimals()));
        // Similar to how
        // 1 dollar = 100 cents
        // 1 token = 1 * (10 ** decimals)
        // 100 * 10**uint(decimals()) == 100 units and 100000000000000000000 min units
        // 100000000 * 10**uint(decimals()) == 100.000.000 units and 100000000000000000000 min units
        _mint(msg.sender, 10 * 10**uint(decimals()));
    }

    function storeETH() payable public {    
        // nothing to do here
    }

    function deposit() payable public {
        // nothing to do, it just store ether for this user in inhiretance
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getEthBalance() public view returns (uint256) {
        return address(this).balance;
    }

}