// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

import {Test} from "forge-std/Test.sol";
import {Clock} from "../src/Clock.sol";
import {ClockV2} from "../src/ClockV2.sol";
import {BasicProxy} from "../src/BasicProxy.sol";
import {BasicProxyV2} from "../src/BasicProxyV2.sol";

contract ProxyTest is Test {
    Clock public clock;
    ClockV2 public clock2;
    BasicProxy public proxy;
    BasicProxyV2 public proxy2;
    uint256 public alarm1Time;

    function setUp() public {
        // 1. set up clock with custom time
        alarm1Time = 1682265600;
        clock = new Clock();
        clock2 = new ClockV2();
        proxy = new BasicProxy(address(clock));
        proxy2 = new BasicProxyV2(address(clock));
    }

    function testAlerm1AndSet() public {
        uint256 timestampNow = block.timestamp;
        // call alerm1
        uint256 t1 = Clock(address(proxy)).alarm1();
        assertFalse(t1 == timestampNow);

        Clock(address(proxy)).setAlarm1(timestampNow);
        uint256 t2 = Clock(address(proxy)).alarm1();
        assertEq(t2, timestampNow);
    }

    // function testUpgrade() public {
    //     BasicProxyV2(address(proxy2).upgradeTo(address(clock2)));
    // }

    // function testAlerm1InProxy() public {
    //     uint256 t = Clock(address(proxy)).alarm1();
    //     // alerm1 !== alarm1Time
    //     assertEq(t, alarm1Time);
    // }

    // function testProxy() public {
    //     uint256 timestampNow = block.timestamp;

    //     // check getTimestamp works
    //     uint256 timestampGet = Clock(address(proxy)).getTimestamp();
    //     assertEq(timestampGet, timestampNow);

    //     // check setAlarm1 works
    //     Clock(address(proxy)).setAlarm1(timestampNow + 1);
    //     assertEq(Clock(address(proxy)).alarm1(), timestampNow + 1);
    // }
}
