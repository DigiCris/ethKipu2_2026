// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {LearningToken} from "../src/LearningToken.sol";

contract LearningTokenTest is Test {
    LearningToken public token;

    address public deployer = address(this);
    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    uint256 public constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {
        token = new LearningToken(INITIAL_SUPPLY);
    }

    function test_Name() public view {
        assertEq(token.name(), "Learning Token");
    }

    function test_Symbol() public view {
        assertEq(token.symbol(), "LRN");
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_DeployerBalance() public view {
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY);
    }

    function test_Transfer() public {
        uint256 amount = 100 ether;

        vm.prank(deployer);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(deployer), INITIAL_SUPPLY - amount);
    }

    function test_Mint() public {
        uint256 amount = 50 ether;

        vm.startPrank(bob);
        token.mint(bob, amount);
        vm.stopPrank();

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }

    function testFuzz_Mint(uint96 amount) public {
        token.mint(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + amount);
    }
}
