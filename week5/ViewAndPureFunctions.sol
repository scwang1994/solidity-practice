// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
contract ViewAndPureFunctions {
    uint public num;

    // view function can read data from blockchain.
    function viewFunc() external view returns (uint) { 
        return num;
    }

    // pure function does not read anything from blockchain.
    // pure function does not modify anything from blockchain.
    function pureFunc() external pure returns (uint) {
        return 1;
    }

    // function addToNum(uint x) external ? returns (uint) {
    //     return num + x;
    // }
    // => read num, ? = view

    // function add(uint x, uint y) external ? returns (uint) {
    //     return x + y;
    // }
    // => doesn't read anything from blockchain, ? = pure
}