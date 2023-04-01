// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Counter {
    uint public number;

    function increment() external {
        number += 1;
    }

    function inspectSender() public view returns(address) {
        return msg.sender;
    }
    
    function inspectOrigin() public view returns(address) {
        return tx.origin;
    }
}

contract CounterCaller {
    Counter public myCounter;

    constructor(address counterAddress) {
        myCounter = Counter(counterAddress);
    }

    function inspectInspectOrigin() public view returns(address) {
        return myCounter.inspectOrigin();
    }

    function inspectInspectSender() public view returns(address) {
        return myCounter.inspectSender();
    }

    function inspectSender() public view returns(address) {
        return msg.sender;
    }

    function inspectOrigin() public view returns(address) {
        return tx.origin;
    }
}