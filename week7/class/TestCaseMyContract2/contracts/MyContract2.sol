// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

contract MyContract {
    address public user1;
    address public user2;

    event Receive(address from, uint256 amount);
    event SendETH(address to, uint256 amount);

    constructor(address _user1, address _user2) {
        user1 = _user1;
        user2 = _user2;
    }

    function sendETH(address to, uint256 amount) external payable {
        require(
            msg.sender == user1 || msg.sender == user2,
            "only user1 or user2 can send"
        );
        require(address(this).balance >= amount, "insufficient balance");

        (bool success, ) = to.call{value: amount}("");
        require(success, "transfer failed");
        emit SendETH(to, amount);
    }

    receive() external payable {
        emit Receive(msg.sender, msg.value);
    }
}
