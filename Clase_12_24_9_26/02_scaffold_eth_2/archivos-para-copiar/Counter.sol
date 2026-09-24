// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
    uint256 public number;

    event CounterChanged(address indexed user, uint256 newNumber);

    function increment() external {
        number += 1;
        emit CounterChanged(msg.sender, number);
    }

    function decrement() external {
        require(number > 0, "Counter already at zero");
        number -= 1;
        emit CounterChanged(msg.sender, number);
    }
}
