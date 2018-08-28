pragma solidity ^0.4.24;

import "./ERC20.sol";

/**
 * @title ERC223 interface, fully inherits ERC20
 * @dev see https://github.com/ethereum/EIPs/issues/223
 * @dev see https://github.com/Dexaran/ERC223-token-standard
 */
contract ERC223 is ERC20 {
    function transfer(address _to, uint256 _value, bytes _data) public returns (bool _success);
    function transfer(address _to, uint256 _value, bytes _data, string _custom_fallback) public returns (bool _success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}