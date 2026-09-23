// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    event Incremented(address indexed caller, uint256 newCount);

    function setUp() public {
        counter = new Counter();
    }

    function test_InitialCountIsZero() public view {
        assertEq(counter.count(), 0);
    }

    function test_IncrementFromZeroToOne() public {
        counter.increment();
        assertEq(counter.count(), 1);
    }

    function test_IncrementEmitsEvent() public {
        vm.expectEmit(true, false, false, true);
        emit Incremented(address(this), 1);
        counter.increment();
    }

    function test_DecrementWhenCountIsPositive() public {
        counter.increment();
        counter.decrement();
        assertEq(counter.count(), 0);
    }

    function test_RevertWhen_DecrementAtZero() public {
        vm.expectRevert(Counter.CounterIsZero.selector);
        counter.decrement();
    }
}
