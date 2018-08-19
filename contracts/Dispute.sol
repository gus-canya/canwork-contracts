pragma solidity ^0.4.24;

import './Job.sol';

/*
* @dev Dispute contract
*/
contract JobDispute {

    Job public job;

    bool public resolved = false;

    constructor(Job _job) public {
        require(_job.client() == msg.sender || _job.provider() == msg.sender);
        job = _job;
    }

    function resolve() public {
        require(job.disputeBy() == msg.sender);
        resolved = true;
    }
}