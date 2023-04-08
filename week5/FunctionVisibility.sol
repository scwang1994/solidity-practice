// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract FunctionVisibility {

    uint num = 123;

    // // X 
    // function viewVer(uint _num) public view {
    //     num = _num;
    // }

    // O
    // view 不會改變全域變數的值，只讀取
    function viewVer(uint _num) public view returns (uint) {
        return num + _num;
    }

    // 可以被合約、繼承合約、外部合約調用
    function publicVer() public {
        internalVer();
        // externalVer();
        privateVer();
    }

    // 可以被合約、繼承合約調用
    function internalVer() internal {
        publicVer();
        // externalVer();
        privateVer();
    }

    // 可以被外部合約調用
    function externalVer() external {
        publicVer();
        internalVer();
        privateVer();
    }

    // 可以被合約調用
    function privateVer() private {
        publicVer();
        internalVer();
        // externalVer();
    }
}

contract Inherit is FunctionVisibility {
    function publicVerInherit() public {
        publicVer();
    }

    function internalVerInherit() internal {
        internalVer();
    }

    function externalVerInherit() external {
        // externalVer();
    }

    function privateVerInherit() private {
        // privateVer();
    }
}