// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
 
// visibility
// private - only insde contract
// internal - only inside contract and child contract
// public - inside and outside contract
// external - only from outside contract

/*

contract A         |
private pri()      |
internal inter()   |  <------ C
public pub()       |          can call pub() and ext()
external ext()     |

contract B is A    |
inter()            |  <------ C
pub()              |          can call pub() and ext()

*/

contract VisibilityBase {
    uint private x = 0;
    uint internal y = 1;
    uint public z = 2;

    function privateFunc() private pure returns (uint) {
        return 0;
    }

    function internalFunc() internal pure returns (uint) {
        return 100;
    }

    function publicFunc() public pure returns (uint) {
        return 200;
    }

    function externalFunc() external pure returns (uint) {
        return 300;
    }

    function examples() external view {
        x + y + z;

        privateFunc(); // O
        internalFunc(); // O
        publicFunc(); // O

        // externalFunc() // X, can only from outside contract
        this.externalFunc(); // O, 'this' making a external call into this contract, BUT. hacky trick and gas inefficient. dont do it.
    }
}

contract VisibilityChild is VisibilityBase {
    function examples2() external view {
        y + z; // x (private);
        
        internalFunc();
        publicFunc();
    }
}