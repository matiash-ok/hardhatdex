// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol';
import '@uniswap/v2-core/contracts/UniswapV2Pair.sol';
import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import 'hardhat/console.sol';

interface IUniswapV2Callee {
  function uniswapV2Call(
    address sender,
    uint amount0,
    uint amount1,
    bytes calldata data
  ) external;
}

// interface IUniswapV2Factory {
//     event PairCreated(address indexed token0, address indexed token1, address pair, uint);

//     function feeTo() external view returns (address);
//     function feeToSetter() external view returns (address);

//     function getPair(address tokenA, address tokenB) external view returns (address pair);
//     function allPairs(uint) external view returns (address pair);
//     function allPairsLength() external view returns (uint);

//     function createPair(address tokenA, address tokenB) external returns (address pair);

//     function setFeeTo(address) external;
//     function setFeeToSetter(address) external;
// }


// contract UniswapV2Factory is IUniswapV2Factory {
//     address public feeTo;
//     address public feeToSetter;

//     mapping(address => mapping(address => address)) public getPair;
//     address[] public allPairs;

//     event PairCreated(address indexed token0, address indexed token1, address pair, uint);

//     constructor(address _feeToSetter) public {
//         feeToSetter = _feeToSetter;
//     }

//     function allPairsLength() external view returns (uint) {
//         return allPairs.length;
//     }

//     function createPair(address tokenA, address tokenB) external returns (address pair) {
//         require(tokenA != tokenB, 'UniswapV2: IDENTICAL_ADDRESSES');
//         (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
//         require(token0 != address(0), 'UniswapV2: ZERO_ADDRESS');
//         require(getPair[token0][token1] == address(0), 'UniswapV2: PAIR_EXISTS'); // single check is sufficient
//         bytes memory bytecode = type(UniswapV2Pair).creationCode;
//         bytes32 salt = keccak256(abi.encodePacked(token0, token1));
//         assembly {
//             pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
//         }
//         IUniswapV2Pair(pair).initialize(token0, token1);
//         getPair[token0][token1] = pair;
//         getPair[token1][token0] = pair; // populate mapping in the reverse direction
//         allPairs.push(pair);
//         emit PairCreated(token0, token1, pair, allPairs.length);
//     }

//     function setFeeTo(address _feeTo) external {
//         require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
//         feeTo = _feeTo;
//     }

//     function setFeeToSetter(address _feeToSetter) external {
//         require(msg.sender == feeToSetter, 'UniswapV2: FORBIDDEN');
//         feeToSetter = _feeToSetter;
//     }
// }



contract Dex is IUniswapV2Callee {
  // Uniswap V2 router
  // 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
  // Uniswap V2 factory
  address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

  constructor() public {
    // uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
  }

  function testSwap() external{
    uint _amount = 10;
    address pair = IUniswapV2Factory(FACTORY).getPair(USDC, WETH);
    console.log("holaaaaaa");
    require(pair != address(0), "!pair");

    address token0 = IUniswapV2Pair(pair).token0();
    address token1 = IUniswapV2Pair(pair).token1();
    uint amount0Out = WETH == token0 ? _amount : 0;
    uint amount1Out = WETH == token1 ? _amount : 0;

    // need to pass some data to trigger uniswapV2Call
    bytes memory data = abi.encode(USDC, _amount);

    console.log(pair);
    console.log(token0);
    console.log(WETH);
    console.log(token1);
    console.log(USDC);

    IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
  }

  function swapEthForUSDC(uint _amount) external {
    address pair = IUniswapV2Factory(FACTORY).getPair(USDC, WETH);
    require(pair != address(0), "!pair");

    address token0 = IUniswapV2Pair(pair).token0();
    address token1 = IUniswapV2Pair(pair).token1();
    uint amount0Out = WETH == token0 ? _amount : 0;
    uint amount1Out = WETH == token1 ? _amount : 0;

    // need to pass some data to trigger uniswapV2Call
    bytes memory data = abi.encode(USDC, _amount);

    console.log(pair);
    console.log(token0);
    console.log(WETH);
    console.log(token1);
    console.log(USDC);

    IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
  }

  // called by pair contract
  function uniswapV2Call(
    address _sender,
    uint _amount0,
    uint _amount1,
    bytes calldata _data
  ) external override {
    address token0 = IUniswapV2Pair(msg.sender).token0();
    address token1 = IUniswapV2Pair(msg.sender).token1();
    address pair = IUniswapV2Factory(FACTORY).getPair(token0, token1);
    require(msg.sender == pair, "!pair");
    require(_sender == address(this), "!sender");

    (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));

    // about 0.3%
    uint fee = ((amount * 3) / 997) + 1;
    uint amountToRepay = amount + fee;

    // do stuff here
    console.log(amount);
    console.log(_amount0);
    console.log(_amount1);
    console.log(fee);
    console.log(amountToRepay);

    IERC20(tokenBorrow).transfer(pair, amountToRepay);
  }
}