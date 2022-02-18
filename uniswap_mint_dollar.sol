// SPDX-License-Identifier: none
pragma solidity ^0.8.11;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";

contract MintDollar is ERC20 {
    uint8 private _decimal = 2;
    mapping(address => uint256) collateralEth;

    // testnets uniswap smart contract
    address uniswapMainnet = 0x9c83dCE8CA20E9aAF9D3efc003b2ea62aBC08351;
    address uniswapRopsten = 0x9c83dCE8CA20E9aAF9D3efc003b2ea62aBC08351;
    address uniswapRinkeby = 0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36;
    address uniswapKovan = 0xD3E51Ef092B2845f10401a0159B2B96e8B6c3D30;
    address uniswapGorli = 0x6Ce570d02D73d4c384b46135E87f8C592A8c86dA;
    address uniswapAddress = uniswapRinkeby;
    
    // sample uniswap router approach
    address internal constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IUniswapV2Router02 public uniswapRouter;

    // uniswap rinkeby tokens list: https://github.com/Uniswap/default-token-list/blob/main/src/tokens/rinkeby.json 
    // DAI rinkeby: 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735
    // WETH rinkeby: 0xc778417E063141139Fce010982780140Aa0cD5Ab // ETH rinkeby and mainnet: 0x0000000000000000000000000000000000000000
    address private daiAddress = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;
    // Wrapped ETH, or WETH, refers to an ERC-20 compatible version of ether.
    // In order for ETH to be exchanged with other Ethereum-based tokens, it needs to be wrapped into WETH. Wrapping ETH does not affect its value, 1 ETH = 1 WETH.
    address private wethAddress = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

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

        // Instantiate the uniswap router
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
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

    // #######################
    // # UNISWAP INTEGRATION #
    // #######################

    /*
    function getPriceBy(address[] addressPair) public view returns (uint[] memory) {
        uint dollarUnitAmount = 100;
        return uniswapRouter.getAmountsIn(dollarUnitAmount, addressPair);
    }
    */

    function getETHDollarPrice() public view returns (uint[] memory) {
        uint dollarUnitAmount = 100;
        return uniswapRouter.getAmountsIn(dollarUnitAmount, getPathDAItoETH());
    }

    function getDollarETHPrice() public view returns (uint[] memory) {
        uint dollarUnitAmount = 100;
        return uniswapRouter.getAmountsIn(dollarUnitAmount, getPathForETHtoDAI());
    }

    function getEstimatedETHforDAI(uint daiAmount) public view returns (uint[] memory) {
        return uniswapRouter.getAmountsIn(daiAmount, getPathForETHtoDAI());
    }

    function getPathForETHtoDAI() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = wethAddress; //uniswapRouter.WETH();
        path[1] = daiAddress;
        
        return path;
    }

    function getPathDAItoETH() public view returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = daiAddress;
        path[1] = wethAddress; //uniswapRouter.WETH();
        
        return path;
    }

    function getWETHUniswapAddress() public view returns (address) {
        return uniswapRouter.WETH();
    }

    function getDAIUniswapAddress() public view returns (address) {
        return uniswapRouter.WETH();
    }

    // important to receive ETH
    receive() payable external {}

}