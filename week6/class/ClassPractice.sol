// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// 請 deploy 一個 contract A 和 contract B，並從 B call callSetA，觀察 B 中發生了什麼事 
// 會改變同個 slot 的值

contract A {
   uint256 public a = 0;
   function setA(uint256 newA) external {
       a = newA;
   }
}

contract B {
    uint256 public amount;
    uint256 public amount2;

    function callSetA(address a) external {
        bytes memory hash = abi.encodeWithSignature("setA(uint256)", 10);
        (bool success, bytes memory data) = a.delegatecall(hash);
    }
}