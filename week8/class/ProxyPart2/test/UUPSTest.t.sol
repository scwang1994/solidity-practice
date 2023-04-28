// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { UUPSProxy } from "../src/UUPSProxy.sol";
import { ClockUUPS } from "../src/UUPSLogic/ClockUUPS.sol";
import { ClockUUPSV2 } from "../src/UUPSLogic/ClockUUPSV2.sol";

contract UUPSTest is Test {
  
  ClockUUPS public clock;
  ClockUUPSV2 public clockV2;
  UUPSProxy public uupsProxy;
  uint256 public alarm1Time;

  address admin;
  address user1;

  function setUp() public {
    admin = makeAddr("admin");
    user1 = makeAddr("noob");
    clock = new ClockUUPS();
    clockV2 = new ClockUUPSV2();
    vm.prank(admin);
    // initialize UUPS proxy
  }

  function testProxyWorks() public {
    // check Clock functionality is successfully proxied
  }

  function testUpgradeToWorks() public {
    // check upgradeTo works aswell
  }

  function testCantUpgrade() public {
    // check upgradeTo should fail if implementation doesn't inherit Proxiable
  }
  
  function testCantUpgradeIfLogicDoesntHaveUpgradeFunction() public {
    // check upgradeTo should fail if implementation doesn't implement upgradeTo
  }

}