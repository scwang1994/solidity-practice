// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Counter {
    uint public count = 0;
    uint public balances = 0;
    function counter() public payable {
        require(msg.value == 1000000 gwei,"Amount should be equal to 1000000 Gwei");
        balances += 1000000 gwei;
        count = count+1;
    }
}