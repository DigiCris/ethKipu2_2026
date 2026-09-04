// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "interfaces/IERC20.sol";

contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    constructor(string memory _name, string memory _symbol) {
        mint(msg.sender, 100);
        name = _name;
        symbol = _symbol;
    }

    function decimals() public virtual pure returns(uint8) {
        return 18;
    }

    // mint(address,uint256)
    function mint(address to, uint256 amount) internal virtual {
        balanceOf[to] += amount;
        totalSupply += amount;
    }


    function transfer(address _to, uint256 _value) public virtual returns (bool success){
        return _transfer(msg.sender,_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual returns (bool success){
        address owner = _from;
        address spender = msg.sender;
        if (allowance[owner][spender] < _value) revert();
        allowance[owner][spender] -= _value;
        return _transfer(_from, _to, _value);
    }

    function _transfer(address _from, address _to, uint256 _value) internal virtual returns (bool success){
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from,_to,_value);
        return true;
    }

    function approve(address _spender, uint256 _value) public virtual returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }


}
