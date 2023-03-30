// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract Counter {
    uint public count;

    function inc() external {
        count += 1;
    }
    
    function dev() external {
        count -= 1;
    }
}