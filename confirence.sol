pragma solidity ^0.4.25;

//import "./ownable.sol";
import "./stdtok.sol";

//
// 'this' contract
//
contract Conference is Ownable {

    //
    // interfaces
    //
    using SafeMath for uint;

    //
    // datatype defs
    //
    struct Participant {
        bool involved; // attr
        uint balance; // balance = trancfered money
        uint tickets; // tickets = tickets * ticketPrice
    }
    enum State { Involving, Locked } // contract states

    //
    // variables
    //
    mapping (address => Participant) participants;
    bool ended = false;
    uint public quote = 0;
    uint public participantsCount = 0;
    uint public ticketPrice = 0;
    State public fsm = State.Locked; // contract finit state machine, initial state Locked
    address seller = address(0);
    SimpleTokenCoin public token = new SimpleTokenCoin();
    
    //
    // constructor for initialize this contract
    //
    constructor (uint _quote, uint _ticketPrice) public payable {
        ticketPrice = _ticketPrice;
        quote = _quote;
        // fsm trasition to Involving state
        fsm = State.Involving;
        // 
        seller = msg.sender;
    }
    
    //
    // modifiers
    //
    modifier condition(bool _condition) {
        require(_condition, "Value is not equalent Participation price!");
        _;
    }

    modifier isInvolving() {
        require(fsm == State.Involving, "No seats left");
        _;
    }

    //
    // features
    //

    // sigle participant
    function participate()
        public
        condition(msg.value == ticketPrice) // exactly equil
        isInvolving()
        payable
    {
        insertPartyProc(1);
        require(State.Involving == fsm, "Rjected, no seats left");
    }

    // take number of tickets
    function takeTickets(uint _tickets)
        public
        condition(msg.value / _tickets == ticketPrice) // exactly equil
        isInvolving()
        payable
    {
        insertPartyProc(_tickets);
        require(State.Involving == fsm, "Rjected, no seats left");
    }

    // get party status
    function getStatus()
        public
        view
        returns (bool)
    {
        return participants[msg.sender].involved;
    }

    // get parties count
    function getCount()
        public
        view
        returns (uint)
    {
        return participantsCount;
    }

    // get tickets
    function getTickets()
        public
        view
        returns (uint)
    {
        return participants[msg.sender].tickets;
    }

    // get balance
    function getBalnce()
        public
        view
        returns (uint)
    {
        return participants[msg.sender].balance;
    }

    // get state
/*    function getState()
        public
        view
        returns memory (string)
    {
        if (State.Involving == fsm) {
            return "[ involving ]";
        } else {
            return "[ locked ]";
        }
    }
*/
    // inserting party procedure
    function insertPartyProc(uint _tickets)
        internal
       // returns(bool success)
    {
        require(_tickets > 0, "More than zero tickets count must be given!");
        participantsCount += _tickets; // or may be decrease...?
        // test on encountering with quote limit
        if (participantsCount > quote) {
        // on failure    
        // if the quote is has been reached then finishing involving new participants
            ended = true;
            // fallback increasing participantsCount
            participantsCount -= _tickets;
            // fsm trasition to Locked state
            fsm = State.Locked;
        } else {
        // on success
            address payer = msg.sender;
            uint amount = ticketPrice * _tickets;
            // init participant
            participants[payer].involved = true;
            participants[payer].balance = amount;
            participants[payer].tickets = _tickets;
            // execute transaction
            withdraw(payer);
        }
    }

    // get contract balance
    function getThisBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
       // return this.balance;
    }

   

    function getThisAddr()
        public
        view
        returns(address)
    {
        return address(this);
    }


    // transctions

    // money back, refound
    function refound()
        public
        payable
    {
        //TODO:more conditions and guards!
        address payee = msg.sender;
        uint amount = participants[payee].balance;
        if (amount > 0) {
            // decrease counter
            uint tickets = participants[payee].balance / ticketPrice;
            participantsCount -= tickets;
            // unitialize party
            participants[payee].involved = false;
            participants[payee].tickets = 0;
            // It is important to set this to zero because the recipient
            // can call this function again as part of the receiving call
            // before `transfer` returns (see the remark above about
            // conditions -> effects -> interaction).
            participants[payee].balance = 0;
            address(this).transfer(amount);
        }
    }

    uint public amt = 0;

    function withdraw(address _payer)
        public
        payable
    {
        /*
        if( allowed[_from][msg.sender] = value &&
        balances[_from] >= value
        && balances[_to] + value >= balances[_to]) {
          allowed[_from][msg.sender] -= value;
          balances[_from] -= value;
          balances[_to] += value;
          Transfer(_from, _to, value);
          _from.transfer(value)
        */

        uint amount = amt = participants[_payer].balance;
        _payer.transfer(amount);
        //seller.transfer(address(this).balance);
    }



    // organize our currency
    function createTokens() payable {
        //multisig.transfer(msg.value);
        address payee = msg.sender;
        uint amount = msg.value;
        participants[payee].balance = participants[payee].balance.add(amount);
        uint rate = 100000000000000000000;
        uint tokens = rate.mul(amount).div(1 ether);
        token.mint(payee, tokens);
    }
    
    // FALLBACK anonymous function
    function () external payable {
        createTokens();
    }
} // end contract
