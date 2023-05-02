// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {ClockUUPS} from "../src/UUPSLogic/ClockUUPS.sol";
import {ClockUUPSV2} from "../src/UUPSLogic/ClockUUPSV2.sol";
import {ClockUUPSV3} from "../src/UUPSLogic/ClockUUPSV3.sol";

contract UUPSTest is Test {
    ClockUUPS public clock;
    ClockUUPSV2 public clockV2;
    ClockUUPSV3 public clockV3;
    ClockUUPS public proxyClock;
    ClockUUPSV2 public proxyClockV2;
    ClockUUPSV3 public proxyClockV3;
    UUPSProxy public uupsProxy;
    uint256 public alarm1Time;

    address admin;
    address user1;

    function setUp() public {
        admin = makeAddr("admin");
        user1 = makeAddr("noob");
        clock = new ClockUUPS();
        clockV2 = new ClockUUPSV2();
        clockV3 = new ClockUUPSV3();

        vm.prank(admin);
        // initialize UUPS proxy
        uupsProxy = new UUPSProxy(
            abi.encodeWithSignature("initialize(uint256)", 123),
            address(clock)
        );
        proxyClock = ClockUUPS(address(uupsProxy));
        proxyClockV2 = ClockUUPSV2(address(uupsProxy));
        proxyClockV3 = ClockUUPSV3(address(uupsProxy));

        vm.stopPrank();
    }

    function testProxyWorks() public {
        // check Clock functionality is successfully proxied
        assertEq(proxyClock.getTimestamp(), block.timestamp);
    }

    function testUpgradeToWorks() public {
        // check upgradeTo works aswell
        vm.prank(admin);
        proxyClock.upgradeTo(address(clockV3));
        vm.stopPrank();

        require(proxyClockV3.alarm2() == 0);
        vm.prank(user1);
        proxyClockV3.setAlarm2(456);
        assertEq(proxyClockV3.alarm2(), 456);
        vm.stopPrank();
    }

    function testCantUpgrade() public {
        // check upgradeTo should fail if implementation doesn't inherit Proxiable
        vm.expectRevert();
        proxyClock.upgradeTo(address(clockV2));
    }

    function testCantUpgradeIfLogicDoesntHaveUpgradeFunction() public {
        // check upgradeTo should fail if implementation doesn't implement upgradeTo
    }
}
