// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// cost 21442 gas
contract Constants {
    address public constant MY_ADDRESS = 0xAdC0fec4459b55Af7B615e1aA28F5BE9C50D6b06;
    uint public constant MY_UINT = 123;
}

// cost 23553 gas
contract Var {
    address public MY_ADDRESS = 0xAdC0fec4459b55Af7B615e1aA28F5BE9C50D6b06;
}