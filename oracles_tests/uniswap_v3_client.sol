// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
pragma abicoder v2;

import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/ISwapRouter.sol";
import "https://github.com/Uniswap/uniswap-v3-periphery/blob/main/contracts/interfaces/IQuoter.sol";
import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";

interface IUniswapRouter is ISwapRouter {
    function refundETH() external payable;
}

contract UniswapV3 {
    IUniswapRouter public constant uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IQuoter public constant quoter = IQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6);
    
    //address private constant multiDaiKovan = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    address private constant multiDaiRinkeby = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;
    address private constant ETH = 0x0000000000000000000000000000000000000000;
    //address private constant WETH9 = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;

    IUniswapV3Factory public constant uniFactory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

    // 1 ETH = 1000000000000000000 WEI
    function getPriceETHforDAI(uint weiAmount) external view returns (uint160 price) {
        address tokenIn = ETH;
        address tokenOut = multiDaiRinkeby;
        uint24 fee = 3000;
        IUniswapV3Pool pool = IUniswapV3Pool(uniFactory.getPool(tokenIn, tokenOut, fee));
        (uint160 sqrtPriceX96,,,,,,) =  pool.slot0();
        //return uint(sqrtPriceX96).mul(uint(sqrtPriceX96)).mul(1e18) >> (96 * 2);
        //return sqrtPriceX96;
        return uint160(1);
    }

    // do not used on-chain, gas inefficient!
    function getEstimatedETHforDAI(uint daiAmount) public returns (uint256) {
        address tokenIn = ETH; // WETH9
        address tokenOut = multiDaiRinkeby; // multiDaiKovan
        uint24 fee = 3000;
        uint160 sqrtPriceLimitX96 = 0;

        return quoter.quoteExactOutputSingle(
            tokenIn,
            tokenOut,
            fee,
            daiAmount,
            sqrtPriceLimitX96
        );
    }

    // do not used on-chain, gas inefficient!
    // 1 ETH = 1000000000000000000 WEI
    function getEstimatedDAIforETH(uint weiAmount) external payable returns (uint256) {
        address tokenIn = multiDaiRinkeby; // multiDaiKovan
        address tokenOut = ETH; // WETH9
        uint24 fee = 3000;
        uint160 sqrtPriceLimitX96 = 0;
 
        return quoter.quoteExactOutputSingle(
            tokenIn,
            tokenOut,
            fee,
            weiAmount,
            sqrtPriceLimitX96
        );
    }

    function convertExactEthToDai() external payable {
        require(msg.value > 0, "Must pass non 0 ETH amount");

        uint256 deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        address tokenIn = ETH; // WETH9
        address tokenOut = multiDaiRinkeby; // multiDaiKovan
        uint24 fee = 3000;
        address recipient = msg.sender;
        uint256 amountIn = msg.value;
        uint256 amountOutMinimum = 1;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,
            deadline,
            amountIn,
            amountOutMinimum,
            sqrtPriceLimitX96
        );

        uniswapRouter.exactInputSingle{ value: msg.value }(params);
        uniswapRouter.refundETH();

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }
  
    function convertEthToExactDai(uint256 daiAmount) external payable {
        require(daiAmount > 0, "Must pass non 0 DAI amount");
        require(msg.value > 0, "Must pass non 0 ETH amount");
            
        uint256 deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
        address tokenIn = ETH; // WETH9;
        address tokenOut = multiDaiRinkeby; // multiDaiKovan;
        uint24 fee = 3000;
        address recipient = msg.sender;
        uint256 amountOut = daiAmount;
        uint256 amountInMaximum = msg.value;
        uint160 sqrtPriceLimitX96 = 0;

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams(
            tokenIn,
            tokenOut,
            fee,
            recipient,
            deadline,
            amountOut,
            amountInMaximum,
            sqrtPriceLimitX96
        );

        uniswapRouter.exactOutputSingle{ value: msg.value }(params);
        uniswapRouter.refundETH();

        // refund leftover ETH to user
        (bool success,) = msg.sender.call{ value: address(this).balance }("");
        require(success, "refund failed");
    }
  
    // important to receive ETH
    receive() payable external {}
}