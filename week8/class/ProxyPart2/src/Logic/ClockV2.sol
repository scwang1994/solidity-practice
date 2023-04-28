// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Clock } from "./Clock.sol";

contract ClockV2 is Clock {

  // TODO: setAlarm2
  function setAlarm2 (uint256 _timestamp) public {
    alarm2 = _timestamp;
  }
}