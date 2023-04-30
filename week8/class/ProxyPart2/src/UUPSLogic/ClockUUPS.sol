// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {Slots} from "../SlotManipulate.sol";
import {Clock} from "../Logic/Clock.sol";
import {Proxiable} from "../Proxy/Proxiable.sol";

contract ClockUUPS is Clock, Proxiable, Slots {
    bytes32 public constant slot =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    function upgradeTo(address _newImpl) public {
        // TODO: upgrade to new implementation
        _setSlotToAddress(slot, _newImpl);
    }

    function upgradeToAndCall(address _newImpl, bytes memory data) public {
        // TODO: upgrade to new implementation and call initialize
        _setSlotToAddress(slot, _newImpl);
        (bool success, ) = _getSlotToAddress(slot).delegatecall(data);
        require(success);
    }
}
