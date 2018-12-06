pragma solidity ^0.4.24;

import "./SafeMath.sol";
import "./Secondary.sol";

 /**
 * @title Escrow
 * @dev Base escrow contract, holds funds designated for a payee until they
 * withdraw them.
 * @dev Intended usage: This contract (and derived escrow contracts) should be a
 * standalone contract, that only interacts with the contract that instantiated
 * it. That way, it is guaranteed that all Ether will be handled according to
 * the Escrow rules, and there is no need to check for payable functions or
 * transfers in the inheritance tree. The contract that uses the escrow as its
 * payment method should be its primary, and provide public methods redirecting
 * to the escrow's deposit and withdraw.
 */
contract Escrow is Secondary {
  using SafeMath for uint256;

  uint256 public amount = 0;
  address public payee;

  event Deposited(uint256 weiAmount);
  event SetPayee(address indexed payee);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  /**
  * @dev Stores the sent amount as credit to be withdrawn.
  * @param payee The destination address of the funds.
  */
  function deposit() public onlyPrimary payable {
    amount = msg.value;
    emit Deposited(amount);
  }

  /**
  * @param payee The destination address of the funds.
  */
  function setPayee(address _payee) public onlyPrimary {
    payee = _payee;
    emit SetPayee(payee);
  }

  /**
  * @dev Withdraw accumulated balance for a payee.
  */
  function withdraw() public onlyPrimary {
    uint256 payment = amount;
    amount = 0;
    payee.transfer(payment);
    emit Withdrawn(payee, payment);
  }
}
