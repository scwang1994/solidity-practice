// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import { Transparent } from "../src/Transparent.sol";
import { Clock } from "../src/Logic/Clock.sol";
import { ClockV2 } from "../src/Logic/ClockV2.sol";

contract TransparentTest is Test {
  
  Clock public clock;
  ClockV2 public clockV2;
  Transparent public transparentProxy;
  uint256 public alarm1Time;

  address admin;
  address user1;

  function setUp() public {
    admin = makeAddr("admin");
    user1 = makeAddr("noobUser");
    clock = new Clock();
    clockV2 = new ClockV2();
    vm.prank(admin);
    transparentProxy = new Transparent(address(clock));
  }

  function testProxyWorks(uint256 _alarm1) public {
    // check Clock functionality is successfully proxied
  }

  function testUpgradeToOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public {
    // check upgradeTo could be called only by admin
  }

  function testUpgradeToAndCallOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public {
    // check upgradeToAndCall could be called only by admin
  }

  function testFallbackShouldRevertIfSenderIsAdmin(uint256 _alarm1) public {
    // check admin shouldn't trigger fallback
  }

  function testFallbackShouldSuccessIfSenderIsntAdmin(uint256 _alarm1) public {
    // check admin shouldn't trigger fallback
  }
}