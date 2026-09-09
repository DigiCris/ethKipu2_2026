// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

// Otro ejemplo de librería con una propia pueden verlo acá: https://github.com/DigiCris/EducationIT/tree/main/clase3/libs
contract Sqrt {
    uint256 public result;

    using Math for uint256;

    function sqrtFoo(uint256 value) public returns(uint256 rta) {
        result = value.sqrt(); // sstore
        return value.sqrt(); // mload
    }
}
