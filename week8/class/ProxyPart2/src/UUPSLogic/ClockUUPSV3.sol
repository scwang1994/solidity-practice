// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import { Slots } from "../SlotManipulate.sol";
import { ClockV2 } from "../Logic/ClockV2.sol";
import { Proxiable } from "../Proxy/Proxiable.sol";

// ClockUUPSV3 inherit Proxiable
contract ClockUUPSV3 is ClockV2, Proxiable {}