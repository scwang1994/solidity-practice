// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 3 ways to send ETH
// transfer - 2300 gas, reverts
// send - 2300 gas, return bool
// call - all gas, returns bool and data

contract SendEther {
    constructor() payable {}

    receive() external payable {}

    function sendViaTransfer(address payable _to) external payable {
        _to.transfer(123);
    }

    // smart contract on mainnet will never use this function (use transfer or call)
    function sendViaSend(address payable _to) external payable {
        bool sent = _to.send(123);
        require(sent, "send failed");
    }

    function sendViaCall(address payable _to) external payable {
        (bool success, bytes memory data) = _to.call{value: 123}("");
        require(success, "call failed");
    }
}

contract EthReceiver {
    event Log(uint amount, uint gas);

    receive() external payable {
        emit Log(msg.value, gasleft());
    }
}