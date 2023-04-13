// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
 
contract Payable {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    // call this func with value, will send the value to this contract
    // able to send eth with payable
    function deposit() external payable {
    }

    // return the balance of this contract address
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}