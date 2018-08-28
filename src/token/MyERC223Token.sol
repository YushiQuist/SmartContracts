pragma solidity ^0.4.24;

import "./ERC223.sol";
import "./ERC223TokenReceiver.sol";

/**
 * @title My ERC223 Token. Inherits ERC223
 */
contract MyERC223Token is ERC223 {
    
    constructor(uint256 _totalSupply) public {
        name = "MyERC223Token";
        symbol = "MyT";
        decimals = 18;
        totalSupply = _totalSupply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool _success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        if (isContract(_to)) {
            bytes memory empty_data;
            ERC223TokenReceiver receiver = ERC223TokenReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, empty_data);
        }
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
        require(allowance[_from][msg.sender] >= _value);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        
        if (isContract(_to)) {
            bytes memory empty_data;
            ERC223TokenReceiver receiver = ERC223TokenReceiver(_to);
            receiver.tokenFallback(_from, _value, empty_data);
        }
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool _success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        if (isContract(_to)) {
            ERC223TokenReceiver receiver = ERC223TokenReceiver(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        
        emit Transfer(msg.sender, _to, _value, _data);
        
        return true;
    }

    function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public returns (bool _success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        if (isContract(_to)) {
            assert(_to.call.value(0)(abi.encodeWithSignature(_custom_fallback, msg.sender, _value, _data)));
        }
        
        emit Transfer(msg.sender, _to, _value, _data);
        
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool _success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function isContract(address _addr) private view returns (bool _isContract) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
}