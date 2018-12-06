pragma solidity ^0.4.24;

import './Job.sol';
import './Escrow.sol';
import './Dispute.sol';

contract CanWork {

    string public version = '0.1';

    uint256 public jobCount = 0;

    event CreatedJob(address indexed client, uint256 indexed jobCount, address indexed Job);
    event CreatedDispute(address indexed client, uint256 indexed jobCount, address indexed Dispute);
    event CreatedEscrow(address indexed client, uint256 indexed jobCount, address indexed Escrow);

    event GotFee();
    event GotAmount();

    struct JobGroup {
        address Job;
        address Dispute;
        address Escrow;
    }

    mapping (address => uint256[]) public jobsByOwner;
    mapping (uint256 => JobGroup) public jobs;
  
    constructor() {}

    function () payable {
        createJob();
    }

    function createJob() public {
        jobCount++;
        client = msg.sender;
        jobsByOwner[client].push(jobCount);
        
        Job job = new Job(client);
        Dispute dispute = new Dispute(job);
        Escrow escrow = new Escrow(job);

        jobs[jobCount].Job = job;
        jobs[jobCount].Dispute = dispute;
        jobs[jobCount].Escrow = escrow;

        emit CreatedJob(client, jobCount, job);
        emit CreatedDispute(client, jobCount, dispute);
        emit CreatedEscrow(client, jobCount, escrow);
    }
    
    function createJob() public payable {
        jobCount++;
        client = msg.sender;
        jobsByOwner[client].push(jobCount);
        
        Job job = new Job(client);
        Dispute dispute = new Dispute(job);
        Escrow escrow = new Escrow(job);

        jobs[jobCount].Job = job;
        jobs[jobCount].Dispute = dispute;
        jobs[jobCount].Escrow = escrow;

        emit CreatedJob(client, jobCount, job);
        emit CreatedDispute(client, jobCount, dispute);
        emit CreatedEscrow(client, jobCount, escrow);

        fee = getFee();
        amount = getJobAmount();
        escrow.deposit(amount);
    }

    function getFee() public returns (uint256 fee) {}
    function getJobAmount() public returns (uint256 amount) {}
}