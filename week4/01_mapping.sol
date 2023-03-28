// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// Mapping
// How to declare a mapping (simple and nested)
// set, get, delete
 
contract Mapping {
    mapping(address => uint) public balances; // the balances of an address
    mapping(address => mapping(address => bool)) public isFriend; // if address A a friend of address B?

    function examples() external {
        balances[msg.sender] = 123;
        uint bal = balances[msg.sender];
        uint bal2 = balances[address(1)]; // 0

        balances[msg.sender] += 456; // 123 + 456 = 579
        delete balances[msg.sender]; // 0

        isFriend[msg.sender][address(this)] = true;
    }
}