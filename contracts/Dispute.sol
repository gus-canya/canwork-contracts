pragma solidity ^0.4.24;

import './Job.sol';
import "./SafeMath.sol";
import "./Secondary.sol";

/**
* @dev Dispute contract
* Dispute needs at least 3 participants
* Client must not be a participant
* Provider must not be a participant
*/
contract Dispute {
    using SafeMath for uint256;

    Job public job;

    bool public resolved = false;

    mapping(address => uint256) private _deposits;
    mapping(address => address) private _votes;

    // unix dates
    uint256 public joinBefore;
    uint256 public voteBefore;
    uint256 public withdrawBefore;
    
    event Withdrawn(address indexed payee, uint256 weiAmount);

    /**
    * @dev set a job
    * set a deadline too?
    */
    constructor(Job _job) public {
        job = _job;
        joinBefore = now + 3 days;
        voteBefore = joinBefore + 3 days;
        withdrawBefore = voteBefore + 3 days;
    }

    /**
    * @dev a wallet joins a Dispute
    * wallet should not be a provider or a client
    * participant can join only with a stake of the same amount of the Escrow amount
    * participant is added to _votes mapping with an empty address
    * participant can join before the joining deadline
    */
    function join() public payable {
        require(msg.sender != job.client() || msg.sender != job.provider());
        require(now <= joinBefore);
        uint256 amount = msg.value;
        _deposits[msg.sender] = _deposits[msg.sender].add(amount);
        _votes[msg.sender] = address(0);
    }

    function vote(address party) public {
        require(now <= voteBefore);
        require(_votes[msg.sender] == address(0));
        require(msg.sender != job.client() || msg.sender != job.provider());
        require(party == job.client() || party == job.provider());
        _votes[msg.sender] = party;
    }

    function depositsOf(address payee) public view returns (uint256) {
        return _deposits[payee];
    }

    /**
    * @dev Withdraw accumulated balance for a payee.
    * if date to withdraw is over, transfer the balance to CanWork contract
    */
    function withdraw() public {
        if (now > withdrawBefore) {
            primary.transfer(balance);
        }

        require(now > voteBefore && now <= withdrawBefore);
        address payee = msg.sender;
        uint256 payment = _deposits[payee];
        _deposits[payee] = 0;
        payee.transfer(payment);
        emit Withdrawn(payee, payment);
    }

    /**
    * @dev resolve needs 51% or more of the participants to agree
    * date must be after the voting period
    * Loop through _votes
    * count provider and client votes 
    * determine winner
    * deliver funds back to winning party. Loser party loses funds.
    * if a voter from the winning party didn't vote, distribute her funds between active winning party
    * mark the job as fulfilled
    * Should this function deliver the funds or should the participant withdraw before a date?
    */
    function resolve() public {
        require(now > voteBefore);
        resolved = true;
    }
}