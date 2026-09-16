// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract DeployLearningToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function run() external returns (LearningToken token) {
        vm.startBroadcast();
        token = new LearningToken(INITIAL_SUPPLY);
        vm.stopBroadcast();

        console.log("Deployer address:", msg.sender);
        console.log("Contract address:", address(token));
        console.log("Total supply:", token.totalSupply());
    }
}
