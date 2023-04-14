// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
 
// example1
// memory is cheaper than storage
// calldata < memory < storage

contract SaveGas {
    uint public n = 5;

    // accessing n with n times
    // execution cost: 7109 gas
    function noCache() external view returns (uint) {
        uint s = 0;
        for (uint i = 0; i < n; i++) {
            s += 1;
        }

        return s;
    }

    // accessing n with 1 time (set uint _n = n;)
    // execution cost: 3100 gas
    function cache() external view returns (uint) {
        uint s = 0;
        uint _n = n;
        for (uint i = 0; i < _n; i++) {
            s += 1;
        }

        return s;
    }
}