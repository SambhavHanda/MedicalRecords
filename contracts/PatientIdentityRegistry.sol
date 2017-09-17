pragma solidity ^0.4.0;

/**
 * This contract provides a mechanism to verify that a Patient contract is valid
 */

contract PatientIdentityRegistry {

    address private owner;
    uint constant WAITING = 0;
    uint constant ACTIVE = 1;
    uint constant REJECT = 2;

    /**
     * Constructor of the registry.
     */
    function PatientIdentityRegistry() {
        owner = msg.sender;
    }

    /**
     * The PIContract structure: every PIContract is composed of:
     * Hash of contract bytecode
     * Account that submitted the address
     * Status
     */
    struct PIContract {
        bytes32 hash;
        address submitter;
        uint status;
    }

    /**
     * Mapping for contract registry.
     */
    mapping(bytes32 => PIContract) public picontracts;

    
    modifier onlyBy(address _account) {
        if (msg.sender != _account) {
            revert();
        }
        _;
    }

    /**
     * Any patient can submit a contract for acceptance into a registry.
     */
    function submitContract(bytes32 _contractHash) returns(bool) {
        var picontract = picontracts[_contractHash];
        picontract.hash = _contractHash;
        picontract.submitter = msg.sender;
        picontract.status = PENDING;
        return true;
    }

    /**
     * Only the registry owner can approve a contract.
     */
    function approveContract(bytes32 _contractHash) onlyBy(owner) returns(bool) {
        var picontract = picontracts[_contractHash];
        picontract.status = ACTIVE;
        return true;
    }

    /**
     * Only the registry owner can reject a contract.
     */
    function rejectContract(bytes32 _contractHash) onlyBy(owner) returns(bool) {
        var picontract = picontracts[_contractHash];
        picontract.status = REJECTED;
        return true;
    }

    /**
     * This is the public registry function that contracts should use to check
     * whether a contract is valid. 
     */
    function isValidContract(bytes32 _contractHash) returns(bool) {
        if (picontracts[_contractHash].status == ACTIVE) {
            return true;
        }
        if (picontracts[_contractHash].status == REJECTED) {
            revert();
        } else {
            return false;
        }
    }

}