pragma solidity ^0.4.24;

import "./Secondary.sol";

/*
* @dev Service contract
* all these methods are executed by the parent CanWork contract
* a Service is represented by an address and can be tied to an Escrow contract.
* Service contract does not handle amounts or payments because a Service can be free.
* Payments are handled by an Escrow contract or similar
* A contract can consult the Service state and execute actions accordingly
*/
contract Service is Secondary {

    modifier onlyClient {
        require(msg.sender == client);
        _;
    }
    
    modifier onlyProvider {
        require(msg.sender == provider);
        _;
    }

    event AcceptedServiceTerms(address indexed pendingProvider);
    event CanceledService(address indexed client);
    event ApprovedProvider(address indexed client, address indexed provider);
    event CompletedJob();
    event RaisedDispute(address indexed disputeBy);
    event FinishedJob();

    struct Provider {
        bool exists;
    }

    mapping(address => Provider) public pendingProviders;
    
    address public client;
    address public provider;
    address public disputeBy;
    
    bool public isFulfilled = false;
    bool public isOnDispute = false;

    State public state;
    enum State {
        pendingProvider,
        pendingCompletion,
        complete,
        cancelled,
        fullfilled,
        onDispute
    }

    constructor(address _client) public {
        client = _client;
        state = State.pendingProvider;
    }

    /*
    * @dev Executed by any provider
    * Provider accepts the Service and is pushed into the list of pending providers
    * Client must approve one of the providers
    */
    function accept() public {
        require(msg.sender != client);
        require(state == State.pendingProvider);
        require(!pendingProviders[msg.sender].exists);
        pendingProviders[msg.sender].exists = true;
        emit AcceptedServiceTerms(msg.sender);
    }

    /*
    * @dev Changes service state to cancelled
    */
    function cancel() onlyClient public {
        require(state == State.pendingProvider || state == State.pendingCompletion);
        state = State.cancelled;
        emit CanceledService(client);
    }

    /*
    * @dev A client chooses a provider
    */
    function approve(address _provider) onlyClient public {
        require(pendingProviders[_provider].exists);
        require(state == State.pendingProvider);
        provider = _provider;
        state = State.pendingCompletion;
        emit ApprovedProvider(client, provider);
    }
    
    /*
    * @dev A provider marks the service as finished
    */
    function complete() onlyProvider public {
        require(state == State.pendingCompletion);
        state = State.complete;
        emit CompletedJob();
    }
    
    /*
    * @dev a client or provider may mark the Service as onDispute via CanWork contract
    */
    function dispute(address _disputeBy) public onlyPrimary {
        require(state == State.complete || state == State.pendingCompletion);
        require(_disputeBy == client || _disputeBy == provider);
        disputeBy = _disputeBy;
        state = State.onDispute;
        isOnDispute = true;
        emit RaisedDispute(disputeBy);
    }
    
    /*
    * @dev Primary determines the service is fullfilled
    * Client is primary by default
    * Dispute may be a primary
    */
    function finish() onlyPrimary public {
        require(state == State.complete || state == State.onDispute);
        state = State.fullfilled;
        isFulfilled = true;
        isOnDispute = false;
        emit FinishedJob();
    }
}