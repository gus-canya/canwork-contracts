pragma solidity ^0.4.24;

import './Job.sol';
import './Escrow.sol';
import './Dispute.sol';

/**
* Questions
* what happens if the client raises a Dispute with another wallet. The Dispute gets resolved and the client gets part of the money back?
* how can we make sure that the client is no in the Dispute with another wallet?
* what % to give to a resolved Dispute?
* should the Dispute have a deadline? If the deadline is met, transfer the funds to the provider?
*/

contract CanWork {

    string public version = '0.1';

    event CreatedJob(address indexed client, address indexed Job);
    event CreatedEscrow(address indexed client, address indexed Escrow);
    event CreatedDispute(address indexed creator, address indexed Dispute);

    event GotFee();
    event GotAmount();

    struct Contracts {
        address Escrow;
        address Dispute;
    }

    Job[] public jobs;
    mapping (address => Job[]) public jobsByOwner;
    mapping (address => Contracts) public jobContracts;
  
    constructor() {}

    function () payable {}

    function createJob() public {
        client = msg.sender;
        Job job = new Job(client);
        jobsByOwner[client].push(job);
        emit CreatedJob(client, job);
    }

    function createEscrow(Job job) public payable {
        Escrow escrow = new Escrow(job);
        jobContracts[job].Escrow = escrow;
        emit CreatedEscrow(job.client(), escrow);
        uint256 fee = collectFee();
        uint256 amount = getJobAmount(fee);
        escrow.deposit(job.provider(), amount);
    }

    /**
    * @dev creates a Dispute contract and links it to a Job
    * should the Escrow funds be managed by the Dispute contract?
    */
    function createDispute(Job job) public {
        require(jobContracts[job].Dispute == address(0));
        require(msg.sender == job.client() || msg.sender == job.provider());
        job.dispute(msg.sender);
        Dispute dispute = new Dispute(job);
        jobContracts[job].Dispute = dispute;
        emit CreatedDispute(msg.sender, dispute);
        // escrow.transferPrimary(dispute);
    }

    function authorizeWithdrawal(Job job) public {
        require(job.isFulfilled());
        Escrow escrow = jobContracts[job].Escrow;
        escrow.transferPrimary(job.provider());
    }

    function collectFee() public returns (uint256 fee) {}
    function getJobAmount(uint256 fee) public returns (uint256 amount) {}
}