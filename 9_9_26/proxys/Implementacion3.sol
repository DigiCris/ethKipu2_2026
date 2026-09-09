// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

// recuerden que lo que realmente importa son los slots cuando se usa delegateCall y no los nombres que le pongamos a las variables
contract Implementacion3 {
    address public owner; // slot1
    address public callee; // slot1
    address otra;

    function changeOwner(address _owner) external {
        owner = _owner;
    }
}