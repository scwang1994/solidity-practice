// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// 3 ways to send ETH
// transfer - 2300 gas, reverts
// send - 2300 gas, return bool
// call - all gas, returns bool and data

/*
總結來說，
call 沒有 gas 限制，是最彈性的作法，故現在最被提倡使用。
transfer 和 send 都有 2300 的 gas limit，而 transfer 發送失敗會自動 revert 交易，所以比 send 推薦。
send 失敗時不會自動 revert 同時還有 2300 gas limit，幾乎沒有人會使用。

reference
1. https://medium.com/coinmonks/solidity-transfer-vs-send-vs-call-function-64c92cfc878a
2. https://news.cnyes.com/news/id/4938407
*/
contract SendEther {
    constructor() payable {}

    receive() external payable {}

    // 有 2300 的 gas limit
    // if failed, revert
    function sendViaTransfer(address payable _to) external payable {
        _to.transfer(123);
    }

    // 有 2300 的 gas limit
    // won't revert, just return bool
    // need more code (require)
    // smart contract on mainnet will never use this function (use transfer or call)
    function sendViaSend(address payable _to) external payable {
        bool sent = _to.send(123);
        require(sent, "send failed");
    }

    // the recommended way
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