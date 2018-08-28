pragma solidity ^0.4.24;

/**
 * @title Contract interface, to work with ERC223 token
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223TokenReceiver {
    function tokenFallback(address _from, uint256 _value, bytes _data) public;
}