// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "interfaces/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// ERC4626
contract TokenVault is Ownable {
    // deposit/withdraw
    mapping (address => uint256) public balance;
    address public token;

    event Deposited(address indexed who, uint256 amount);
    event Withdrawn(address indexed who, uint256 amount);

    constructor(address _token) Ownable(msg.sender) {
        token = _token;
    }

    function deposit(uint256 amount) external {
        // CEI
        if (IERC20(token).balanceOf(msg.sender) < amount) revert();
        balance[msg.sender] += amount;
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit Deposited(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        if (IERC20(token).balanceOf(address(this)) < amount) revert(); // que tenga liquidez
        if(balance[msg.sender] < amount) revert(); // c
        balance[msg.sender] -= amount; //e
        IERC20(token).transfer(msg.sender, amount); //I
        emit Withdrawn(msg.sender, amount);
    }

    function withdrawAll() external onlyOwner {
        //msg.sender
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, amount);
    }

}