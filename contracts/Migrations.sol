pragma solidity ^0.4.2;


contract Migrations {

    address public owner;
    uint public last_completed_migration;

    /**
     * Modifier to check to see if the value of msg.sender is the same as owner.
     * The underscore _ denotes the inclusion of the remainder of the function body
     * to which the modifier is applied
     */
    modifier restricted() {
        if (msg.sender == owner) _;
    }

    /**
     * Constructor of the Migrations contract which assigns owner to the value of msg.sender
     */
    function Migrations() {
        owner = msg.sender;
    }

    /**
     * A function with the signature 'setCompleted(uint)' is required.
     * Uses the restricted modifier to update the last_completed_migration variable
     */
    function setCompleted(uint completed) restricted {
        last_completed_migration = completed;
    }

    /**
     * Function which provides the contract upgrade mechanism.
     * This function takes the address of the new contraxt, creates a handle and
     * calls the setCompleted function on the new contract
     */
    function upgrade(address new_address) restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}
