// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// 什麼是 Delegatecall？
// 將其他合約的邏輯拿來自己的合約使用
// 執行邏輯時，是使用合約 A 的 storage 
// 你可以簡單想像成，你把 Logic contract 的合約裡那段 method 剪下貼在你的合約裡

// Delegatcall 的 msg.sender 和 tx.origin 會是誰？
// msg.sender 為合約 B，tx.origin 為用戶 A

// Delegatecall 時，改變的 state 是存在執行 delegatecall 的 storage 還是 call 的對象的 storage？
// 執行 delegatecall 的 storage

contract Call {
    function callSender(address addr) public returns (address) {
        (, bytes memory data) = addr.call(abi.encodeWithSignature("getSender()"));
        address sender = abi.decode(data, (address));

        return sender;
    }

    function callOrigin(address addr) public returns (address) {
        (, bytes memory data) = addr.delegatecall(abi.encodeWithSignature("getOrigin()"));
        address origin = abi.decode(data, (address));

        return origin;
    }
}

contract A {
   function getSender() public view returns (address) {
      return msg.sender;
   }

   function getOrigin() public view returns (address) {
      return tx.origin;
   }
}