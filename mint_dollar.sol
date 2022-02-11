// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/UniswapV2Pair.sol";

contract MintDollar is ERC20 {
    uint8 private _decimal = 2;
    mapping(address => uint256) collateralEth;

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
    }

    // Override the decimals to 2 decimals to look like stable coin
    function decimals() public view virtual override returns (uint8) {
        return _decimal;
    }

    function mint() external payable {
        collateralEth[msg.sender] += msg.value;
        // TODO: integrate with uniswap to get real-time ether price
        // TODO: calculate the ratio
        // TODO: deposit stablecoin on the user wallet
    }

    function getCollateralEthOf(address account) public view virtual returns(uint256) {
        return collateralEth[account];
    }

    // calculate price based on pair reserves
   function getEthUSDPrice(uint amount) public view returns(uint) {
       // mainnet
        const factory = "0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95";

        // testnets
        const ropsten = "0x9c83dCE8CA20E9aAF9D3efc003b2ea62aBC08351";
        const rinkeby = "0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36";
        const kovan = "0xD3E51Ef092B2845f10401a0159B2B96e8B6c3D30";
        const gorli = "0x6Ce570d02D73d4c384b46135E87f8C592A8c86dA";

        address _factory = rinkeby;
        address ethToken = 0xCAFE000000000000000000000000000000000000; // ether
        address usdToken = 0x6b175474e89094c44da98b954eedeac495271d0f; // USDC, DAI or USDT??

        address pair = address(uint(keccak256(abi.encodePacked(
            hex"ff",
            factory,
            keccak256(
                        abi.encodePacked(token0, token1)),
                        hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f"
                    )
                )
            )
        );


        //address pairAddress = 

        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        IERC20 token1 = IERC20(pair.token1);
        (uint Res0, uint Res1,) = pair.getReserves();

        // decimals
        uint res0 = Res0*(10**token1.decimals());
        return((amount*res0)/Res1); // return amount of token0 needed to buy token1
   }

}