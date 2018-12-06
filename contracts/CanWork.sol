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
        createJobGroup();
    }

    function createJobGroup() public {
        jobCount++;
        client = msg.sender;
        jobsByOwner[client].push(jobCount);
        
        Job job = new Job(client);
        Escrow escrow = new Escrow(job);
        jobs[jobCount].Job = job;
        jobs[jobCount].Escrow = escrow;
        emit CreatedJob(client, jobCount, job);
        emit CreatedEscrow(client, jobCount, escrow);
    }
    
    function createJobGroup() public payable {
        jobCount++;
        client = msg.sender;
        jobsByOwner[client].push(jobCount);
        
        Job job = new Job(client);
        Escrow escrow = new Escrow(job);
        jobs[jobCount].Job = job;
        jobs[jobCount].Escrow = escrow;
        emit CreatedJob(client, jobCount, job);
        emit CreatedEscrow(client, jobCount, escrow);

        fee = getFee();
        amount = getJobAmount();
        escrow.deposit(client, amount);
    }

    function createJobDispute(uint256 _jobCount, Job job) public {
        require(msg.sender == job.client() || msg.sender == job.provider());
        Dispute dispute = new Dispute(job);
        jobs[_jobCount].Dispute = dispute;
        emit CreatedDispute(job.client(), _jobCount, dispute);
    }

    function withdraw(uint256 _jobCount) public {
        require();
    }

    function getFee() public returns (uint256 fee) {}
    function getJobAmount() public returns (uint256 amount) {}
}