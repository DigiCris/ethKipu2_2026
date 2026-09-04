// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.7.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EthKipuToken is ERC20 {
    constructor() ERC20("EthKipuToken", "EKT") {
        _mint(msg.sender, 100 * 10 ** decimals());
    }
}