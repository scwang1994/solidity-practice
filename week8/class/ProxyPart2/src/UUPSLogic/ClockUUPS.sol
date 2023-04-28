// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Slots } from "../SlotManipulate.sol";
import { Clock } from "../Logic/Clock.sol";
import { Proxiable } from "../Proxy/Proxiable.sol";

contract ClockUUPS is Clock, Proxiable {

  function upgradeTo(address _newImpl) public {
    // TODO: upgrade to new implementation
  }

  function upgradeToAndCall(address _newImpl, bytes memory data) public {
    // TODO: upgrade to new implementation and call initialize
  }
}