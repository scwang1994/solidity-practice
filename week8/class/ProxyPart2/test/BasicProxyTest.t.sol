// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {Clock} from "../src/Logic/Clock.sol";
import {ClockV2} from "../src/Logic/ClockV2.sol";
import {BasicProxy} from "../src/BasicProxy.sol";

contract BasicProxyTest is Test {
    Clock public clock;
    ClockV2 public clockV2;
    BasicProxy public basicProxy;
    Clock public proxyClock;
    ClockV2 public proxyClockV2;

    uint256 public alarm1Time;
    uint256 public alarm2Time;
    address owner = makeAddr('owner');

    function setUp() public {
        clock = new Clock();
        clockV2 = new ClockV2();
        basicProxy = new BasicProxy(address(clock));
        proxyClock = Clock(address(basicProxy));
    }

    function testProxyWorks() public {
        // TODO: check Clock functionality is successfully proxied
        require(alarm1Time == 0, "Invalid Alerm1Time");
        alarm1Time = proxyClock.getTimestamp();
        assertEq(alarm1Time, block.timestamp);
    }

    function testInitialize() public {
        // TODO: check initialize works
        require(proxyClock.initialized() == false, "Already initialized");
        proxyClock.initialize(123);
        assertEq(proxyClock.initialized(), true);
    }

    function testUpgrade() public {
        // TODO: check Clock functionality is successfully proxied
        // upgrade Logic contract to ClockV2
        basicProxy = new BasicProxy(address(clockV2));
        proxyClockV2 = ClockV2(address(basicProxy));
        // check state hadn't been changed
        assertEq(proxyClockV2.initialized(), false);
        // check new functionality is available
        require(proxyClockV2.alarm2() == 0, "Invalid Alerm2Time");
        proxyClockV2.setAlarm2(123);
        assertEq(proxyClockV2.alarm2(), 123);
    }

    function testUpgradeAndCall() public {
        // TODO: calling initialize right after upgrade
        // upgrade Logic contract to ClockV2
        basicProxy = new BasicProxy(address(clockV2));
        proxyClockV2 = ClockV2(address(basicProxy));
        // check state hadn't been changed
        require(proxyClockV2.initialized() == false, "Invalid");
        proxyClockV2.initialize(456);
        // check state had been changed according to initialize
        assertEq(proxyClockV2.initialized(), true);
    }

    function testChangeOwnerWontCollision() public {
        // TODO: call changeOwner to update owner
        // upgrade Logic contract to ClockV2
        basicProxy = new BasicProxy(address(clockV2));
        proxyClockV2 = ClockV2(address(basicProxy));
        // check state hadn't been changed
        require(proxyClockV2.owner() == 0x0000000000000000000000000000000000000000, "Invalid");
        proxyClockV2.changeOwner(owner);
        // check Clock functionality is successfully proxied
        assertEq(proxyClockV2.owner(), owner);
    }
}
