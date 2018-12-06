pragma solidity ^0.4.24;

import "./stdtok.sol";

contract CrowdSale {
    
    SimpleTokenCoin public token = new SimpleTokenCoin();
    uint public start = 0;
    address public owner = 0;
    uint public period = 0;
    uint public hardcap = 0;
    address public multisig = 0;
    uint public rate = 0;
    
    mapping(address => uint) balances;
    
    // возврат средств реципиенту
    function refaund() isActiveBalance payable {
        address who = msg.sender;
        uint amount = balances[who];
        require(balances[msg.sender] >= amount);
        //msg.sender.transfer(amount);
        who.transfer(amount);
        balances[who] -= amount;
    }
    
    // получить баланс за пользователя
    function balanceOf(address _who) public view returns (uint) {
        return balances[_who];
    }
    
    // завершить выпуск токена
    function finishCrowdSale() {
        token.finishMinting();
    }
    
    // внесение средств на промежуточный баланс
    function createTokens() saleIsOn lessThenHardcap payable {
        address who = msg.sender;
        uint amount = msg.value;
        //multisig.transfer(msg.value);
        token.mint(who, (msg.value * rate) / 1 ether);
        balances[who] += msg.value;
    } 

    // команда получения времени в секундах 
    // seconds since 1970-01-01 00:00:00 UTC
    // date +%s
    function crowdSale(uint _period, uint _start, address _multisig) {
        owner = msg.sender;
        start = _start;
        period  = _period;
        rate = 10000000000000000000;
        multisig = _multisig;
        hardcap = rate * 100;
    } 
    
    // payable fallback anon function
    function () external payable {
        createTokens();
    }
    
    modifier isActiveBalance {
        require(balances[msg.sender] > 0);
        _;
    }
    
    modifier saleIsOn() {
       // require(now < start + period + 1 * days);
        _;
    }
    
    modifier lessThenHardcap() {
        require(multisig.balance <= hardcap);
        _;
    }
}
