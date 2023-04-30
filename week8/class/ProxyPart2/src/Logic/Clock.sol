// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract Clock {
    address public owner;
    bool public initialized;
    uint256 public alarm1;
    uint256 public alarm2;

    function initialize(uint256 _alarm1) external {
        require(!initialized, "Already initialized");
        alarm1 = _alarm1;
        initialized = true;
    }

    function setAlarm1(uint256 _timestamp) public {
        alarm1 = _timestamp;
    }

    function getTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function changeOwner(address _newOwner) public {
        owner = _newOwner;
    }
}
