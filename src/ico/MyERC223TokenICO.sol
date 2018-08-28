pragma solidity ^0.4.24;

import "../common/Ownable.sol";
import "../token/ERC223TokenReceiver.sol";

/**
 * @title Token interface
 */
contract Token {
    function decimals() public returns (uint8 _decimals);
    function balanceOf(address _tokenOwner) public returns (uint256 _value);
    function transfer(address _to, uint256 _value) public returns (bool _success);
}

/**
 * @title My ERC223 Token ICO Contract
 */
contract MyERC223TokenICO is Ownable, ERC223TokenReceiver {
    
    uint256 public softCap; // specify by wei
    uint256 public hardCap; // specify by wei
    uint256 public tokenPrice; // token per ether
    uint256 public icoStartTime; // UNIX epoch
    uint256 public deadlineOfSoftCap; // UNIX epoch
    uint256 public icoEndTime; // UNIX epoch
    
    uint256 public fundingAmount; // specify by wei
    uint256 public withdrawnAmount; // specify by wei
    
    mapping (address => uint256) public balanceOf; // specify by wei
    Token public token;
    
    event TokenPurchase(address indexed _purchaser, uint256 _paidValue, uint256 _fundingAmount);
    event WithdrawalEther(address indexed _owner, uint256 _value);
    event WithdrawalToken(address indexed _owner, uint256 _value);
    event Payback(address indexed _purchaser, uint256 _value);
    event Receive(address indexed _from, uint256 _value, bytes _data);
    
    constructor (
        uint256 _softCap, // specify by ether
        uint256 _hardCap, // specify by ether
        uint256 _tokenPrice, // token per ether
        uint256 _icoStartTime, // UNIX epoch
        uint256 _deadlineOfSoftCap, // UNIX epoch
        uint256 _icoEndTime, // UNIX epoch
        address _tokenAddress) Ownable() public {
        token = Token(_tokenAddress);
        
        softCap = _softCap * 1 ether;
        hardCap = _hardCap * 1 ether;
        tokenPrice = _tokenPrice * (10 ** uint256(token.decimals()));
        icoStartTime = _icoStartTime;
        deadlineOfSoftCap = _deadlineOfSoftCap;
        icoEndTime = _icoEndTime;
    }
    
    function () payable public {
        require(icoStartTime <= now && now <= icoEndTime);
        require(now <= deadlineOfSoftCap || softCap <= fundingAmount);
        
        uint256 paidWeis = msg.value;
        
        require(fundingAmount + paidWeis <= hardCap);
        require(((tokenPrice * paidWeis) % 1 ether) == 0);
        
        uint256 tokenWillPay = (tokenPrice * paidWeis) / 1 ether;
        
        balanceOf[msg.sender] += paidWeis;
        fundingAmount += paidWeis;
        token.transfer(msg.sender, tokenWillPay);
        
        emit TokenPurchase(msg.sender, paidWeis, fundingAmount);
    }
    
    function withdrawalEther() public onlyOwner {
        require(softCap <= fundingAmount);
        
        withdrawnAmount = fundingAmount;
        uint256 value = address(this).balance;
        owner.transfer(value);
        
        emit WithdrawalEther(owner, value);
    }
    
    function withdrawalToken() public onlyOwner {
        require(icoEndTime < now);
        
        uint256 value = token.balanceOf(address(this));
        token.transfer(owner, value);
        
        emit WithdrawalToken(owner, value);
    }
    
    function payback() public {
        require(deadlineOfSoftCap < now && fundingAmount < softCap);
        
        uint256 paidWeis = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(paidWeis);
        
        emit Payback(msg.sender, paidWeis);
    }
    
    function tokenFallback(address _from, uint256 _value, bytes _data) public {
        emit Receive(_from, _value, _data);
    }
}