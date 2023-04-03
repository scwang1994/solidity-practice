// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
contract Immutable {
    // gas: 45718
    // address public owner = msg.sender; 

    //  initialize only once when the contract is deployed.
    // gas: 43585; save some gas
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    uint public x;
    function foo() external {
        require(msg.sender == owner);
        x += 1;
    }
}