// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// Low level calls: staticcall, call
// 如果用 staticcall call 來 call 一個可以改變 EVM state machine 的 function，會發生什麼事？
// staticcall 不能用在改變函數的狀態

contract Call {
   
   function calls(address addr, uint256 s) public {
    
      /* 
      To Do: Call setA()
      (bool success, bytes memory data) = ...
      */
      (bool success, bytes memory data) = addr.call(abi.encodeWithSignature("setA(uint256)", s));
      require(success);
      /* 
      To Do: Call getA()
      (bool success, bytes memory data ) = ...
      */

      (bool success2, bytes memory data2) = addr.staticcall(abi.encodeWithSignature("getA()"));
      uint256 a = abi.decode(data2, (uint256));
      require(a == s);
   }
}

contract A {
   uint public a;
   function setA(uint256 _a) public {
      a = _a;
   }

   function getA() public view returns (uint256) {
      return a;
   }
}