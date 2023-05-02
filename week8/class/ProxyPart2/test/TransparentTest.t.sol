// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Transparent} from "../src/Transparent.sol";
import {Clock} from "../src/Logic/Clock.sol";
import {ClockV2} from "../src/Logic/ClockV2.sol";

contract TransparentTest is Test {
    Clock public clock;
    ClockV2 public clockV2;
    Transparent public transparentProxy;
    Clock public proxyClock;
    ClockV2 public proxyClockV2;

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
        proxyClock = Clock(address(transparentProxy));
        proxyClockV2 = ClockV2(address(transparentProxy));
        vm.stopPrank();
    }

    function testProxyWorks(uint256 _alarm1) public {
        // check Clock functionality is successfully proxied
        proxyClock.setAlarm1(_alarm1);
        assertEq(proxyClock.alarm1(), _alarm1);
    }

    function testUpgradeToOnlyAdmin(uint256 _alarm1, uint256 _alarm2) public {
        // check upgradeTo could be called only by admin
        vm.prank(user1);
        vm.expectRevert("Not Admin");
        transparentProxy.upgradeTo(address(clockV2));
        vm.stopPrank();
    }

    function testUpgradeToAndCallOnlyAdmin(
        uint256 _alarm1,
        uint256 _alarm2
    ) public {
        // check upgradeToAndCall could be called only by admin
        vm.prank(user1);
        vm.expectRevert("Not Admin");
        transparentProxy.upgradeToAndCall(address(clockV2), bytes(""));
        vm.stopPrank();
    }

    function testFallbackShouldRevertIfSenderIsAdmin(uint256 _alarm1) public {
        // check admin shouldn't trigger fallback
        vm.startPrank(admin);
        vm.expectRevert();
        proxyClock.setAlarm1(_alarm1);
        vm.stopPrank();
    }

    function testFallbackShouldSuccessIfSenderIsntAdmin(
        uint256 _alarm1
    ) public {
        // check admin shouldn't trigger fallback
        vm.startPrank(user1);
        require(proxyClock.alarm1() == 0);
        proxyClock.setAlarm1(123);
        assertEq(proxyClock.alarm1(), 123);
        vm.stopPrank();
    }
}
