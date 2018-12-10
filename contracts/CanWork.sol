pragma solidity ^0.4.24;

import './Service.sol';
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

    event CreatedService(address indexed client, address indexed Service);
    event CreatedEscrow(address indexed client, address indexed Escrow);
    event CreatedDispute(address indexed creator, address indexed Dispute);

    event GotFee();
    event GotAmount();

    struct Contracts {
        address Escrow;
        address Dispute;
    }

    Service[] public services;
    mapping (address => Service[]) public servicesByOwner;
    mapping (address => Contracts) public serviceContracts;
  
    constructor() {}

    function () payable {}

    function createService() public {
        client = msg.sender;
        Service service = new Service(client);
        servicesByOwner[client].push(service);
        emit CreatedService(client, service);
    }

    function createEscrow(Service service) public payable {
        Escrow escrow = new Escrow(service);
        serviceContracts[service].Escrow = escrow;
        emit CreatedEscrow(service.client(), escrow);
        uint256 fee = collectFee();
        uint256 amount = getServiceAmount(fee);
        escrow.deposit(service.provider(), amount);
    }

    /**
    * @dev creates a Dispute contract and links it to a Service
    * should the Escrow funds be managed by the Dispute contract?
    */
    function createDispute(Service service) public {
        require(serviceContracts[service].Dispute == address(0));
        require(msg.sender == service.client() || msg.sender == service.provider());
        service.dispute(msg.sender);
        Dispute dispute = new Dispute(service);
        serviceContracts[service].Dispute = dispute;
        emit CreatedDispute(msg.sender, dispute);
        // escrow.transferPrimary(dispute);
    }

    function authorizeWithdrawal(Service service) public {
        require(service.isFulfilled());
        Escrow escrow = serviceContracts[service].Escrow;
        escrow.transferPrimary(service.provider());
    }

    function collectFee() public returns (uint256 fee) {}
    function getServiceAmount(uint256 fee) public returns (uint256 amount) {}
}