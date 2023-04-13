// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

// Delegate call (A, B or Bob)
// Bob call A 合約，A call B合約，B 中的 msg.sender 是誰？ 
// contractA

// Bob call A 合約，A delegatecall B 合約，在 B 中的 msg.sender 是誰？ 
// Bob

// Bob call A 合約，A delegatecall B合約，B 合約又 call C 合約，這時在 C 合約中的 msg.sender 是誰呢？
// contractA

// Bob call A 合約，A call B合約，B 合約又 delegatecall C 合約，這時在 C 合約中的 msg.sender 是誰呢？
// contractA

contract A {
    function callB(address addr) public view returns (address) {
        (, bytes memory data) = addr.staticcall(abi.encodeWithSignature("getSender()"));
        address sender = abi.decode(data, (address));

        return sender;
    }

    function delegatecallB(address addr) public returns (address) {
        (, bytes memory data) = addr.delegatecall(abi.encodeWithSignature("getSender()"));
        address sender = abi.decode(data, (address));

        return sender;
    }

    function delegatecallBcallC(address addrB, address addrC) public returns (address) {
        (, bytes memory data) = addrB.delegatecall(abi.encodeWithSignature("callC(address)", addrC));
        address sender = abi.decode(data, (address));

        return sender;
    }

    function callBdelegatecallC(address addrB, address addrC) public returns (address) {
        (, bytes memory data) = addrB.call(abi.encodeWithSignature("delegatecallC(address)", addrC));
        address sender = abi.decode(data, (address));

        return sender;
    }
}

contract B {
   function getSender() public view returns (address) {
      return msg.sender;
   }

   function callC(address addr) public returns (address) {
        (, bytes memory data) = addr.call(abi.encodeWithSignature("getSender()"));
        address sender = abi.decode(data, (address));

        return sender;
    }

    function delegatecallC(address addr) public returns (address) {
        (, bytes memory data) = addr.delegatecall(abi.encodeWithSignature("getSender()"));
        address sender = abi.decode(data, (address));

        return sender;
    }
}

contract C {
   function getSender() public view returns (address) {
      return msg.sender;
   }
}