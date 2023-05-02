// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {Slots} from "../SlotManipulate.sol";
import {ClockV2} from "../Logic/ClockV2.sol";

// ClockUUPSV2 doens't inherit Proxiable
contract ClockUUPSV2 is ClockV2 {

}
