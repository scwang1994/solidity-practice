// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

/*
Fallback executed when
- function doesn't exist
-directly send ETH
*/

contract Fallback {
    event Log(string func, address sender, uint value, bytes data);

    // if someone call a func doesn't exist, fallback will be executed.
    // mostly to enable smart contract to receive ether
    fallback() external payable {
        emit Log("fallback", msg.sender, msg.value, msg.data);
    }
    
    // similar
    // called when the data was sent with empty
    // if data empty and receive is declared, receive(), otherwise fallback()
    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    } 
}