// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

// virtual: means this function can be inherited and customized by the child contract

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }

    function bar() public pure virtual returns (string memory) {
        return "A";
    }

    // more code here
    function baz() public pure returns (string memory) {
        return "A";
    }
}

contract B is A {
    function foo() public pure override returns (string memory) {
        return "B";
    }

    function bar() public pure virtual override returns (string memory) {
        return "B";
    }

    // more code here
}

contract C is B {
    function bar() public pure override returns (string memory) {
        return "C";
    }
}