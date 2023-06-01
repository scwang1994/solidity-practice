// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "./SimpleSwap.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("key");
        vm.startBroadcast(deployerPrivateKey); // key

        SimpleSwap simple = new SimpleSwap(
            0xAdC0fec4459b55Af7B615e1aA28F5BE9C50D6b06,
            0xAdC0fec4459b55Af7B615e1aA28F5BE9C50D6b06
        );

        vm.stopBroadcast();
    }
}
