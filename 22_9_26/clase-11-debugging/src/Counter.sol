// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;

    error CounterIsZero();

    event Incremented(address indexed caller, uint256 newCount);
    event Decremented(address indexed caller, uint256 newCount);

    function increment() external {
        count += 1;
        emit Incremented(msg.sender, count);
    }

    function decrement() external {
        if (count == 0) {
            revert CounterIsZero();
        }
        count -= 1;
        emit Decremented(msg.sender, count);
    }
}
