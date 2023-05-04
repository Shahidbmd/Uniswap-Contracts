// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";


contract TestUniswap {
  address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address private constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  

  //Events
  event LiquidityAdded(string);
  event LiquidityRemoved(string);
  function addLiquidity( address tokenA,
   address tokenB,
   uint amountADesired,
   uint amountBDesired,
   uint amountAMin,
   uint amountBMin,
   address to) external {
   
   // transfer from msg.sender to TestUniswap address (approve before transfer)
   IERC20(tokenA).transferFrom(msg.sender, address(this),amountADesired);
   IERC20(tokenB).transferFrom(msg.sender, address(this),amountBDesired);
   // approve the amounts of tokens that user want to add in Liquidity to Router Address
   IERC20(tokenA).approve(UNISWAP_V2_ROUTER, amountADesired);
   IERC20(tokenB).approve(UNISWAP_V2_ROUTER, amountBDesired);
   IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidity(tokenA,tokenB,amountADesired,amountBDesired,amountAMin,amountBMin,to, block.timestamp);
   emit LiquidityAdded("Liquidity Added");
  }

  function getReserves(address tokenA, address tokenB) external view returns(uint reserve0, uint reserve1) {
    address pairAddress = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(tokenA, tokenB);
    require(pairAddress != address(0), "Pair not found");
    IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
    (uint reserveA, uint reserveB, ) = pair.getReserves();
    address token0 = pair.token0();
    (reserve0,reserve1) = tokenA == token0 ? (reserveA, reserveB) : (reserveB, reserveA);
    return (reserve0, reserve1);
  }
 
  function removeLiquidity(address _tokenA, address _tokenB, uint liquidity) external returns(uint amountA, uint amountB) {
    address pair = IUniswapV2Factory(UNISWAP_V2_FACTORY).getPair(_tokenA, _tokenB);
    IERC20(pair).transferFrom(msg.sender, address(this),liquidity);
    IERC20(pair).approve(UNISWAP_V2_ROUTER, liquidity);
    (amountA,amountB) = IUniswapV2Router02(UNISWAP_V2_ROUTER).removeLiquidity(_tokenA,_tokenB,liquidity,1,1,msg.sender,block.timestamp);
    emit LiquidityRemoved("Liquidity Removed");
  }

  function addLiquidityETH(address token,
   uint amountTokenDesired,
   uint amountTokenMin,
   uint amountETHMin,
   address to) external payable {
   IERC20(token).transferFrom(msg.sender, address(this),amountTokenDesired); 
   IERC20(token).approve(UNISWAP_V2_ROUTER, amountTokenDesired);
   IUniswapV2Router02(UNISWAP_V2_ROUTER).addLiquidityETH{value: msg.value}(token,amountTokenDesired,amountTokenMin,amountETHMin,to,block.timestamp);
   emit LiquidityAdded("Liquidity Added");
   }
}

