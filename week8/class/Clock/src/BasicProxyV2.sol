// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {BasicProxy} from "./BasicProxy.sol";

contract BasicProxyV2 is BasicProxy {
    // First slot is the address of the current implementation
    constructor(address addr) BasicProxy(addr) {}

    function upgradeTo(address newImplementation) external {
        proxyContract = newImplementation;
    }

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external {
        proxyContract = newImplementation;
        (bool success, ) = proxyContract.delegatecall(data);
        require(success);
    }
}
