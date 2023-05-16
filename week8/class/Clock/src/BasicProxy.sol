// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {Proxy} from "./Proxy.sol";

contract BasicProxy is Proxy {
    // First slot is the address of the current implementation
    address public proxyContract;

    constructor(address _proxyContract) {
        proxyContract = _proxyContract;
    }

    fallback() external {
        _delegate(proxyContract);
    }
}
