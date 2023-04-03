// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
//  Function modifier - reuse code before and / or after function
//  Basic, inputs, sandwich

contract FunctionModifier {
    bool public paused;
    uint public count;

    function setPause(bool _paused) external {
        paused = _paused;
    }

    modifier whenNotPaused() {
        require(!paused, "paused");
        _; // allow to call the rest actual function 
    }

    function inc() external whenNotPaused {
        // require(!paused, "paused"); // replaced
        count += 1;
    }

    function dec() external whenNotPaused {
        // require(!paused, "paused"); // replaced
        count -= 1;
    }

    modifier cap(uint _x) {
        require(_x < 100, "x >= 100");
        _;
    }

    function incBy(uint _x) external whenNotPaused cap(_x) {
        // require(_x < 100, "x >= 100"); //replaced
        count += _x;
    }

    modifier sandwich() {
        // code here
        count += 10; // step1. count += 10;
        _; // step2. call main function, which is count +=1
        // more code here
        count *= 2; // step3. count *= 2;
    }

    function foo() external sandwich {
        count += 1;
    }
}