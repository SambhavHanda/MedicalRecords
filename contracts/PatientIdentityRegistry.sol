pragma solidity ^0.4.0;

/**
 * This contract provides a mechanism to verify that a Patient contract is valid
 */
 
/***********************************************************************************************/
    // The primary purpose of this contract would ideally be to enable the below logic to be used in contracts aiming to use validation:

    /**
     * Check if Patient Identity is valid using modifier.
     *
     * This might also enable protection against forking, since at the time the chain forks,
     * one can kill the registry, which 'invalidates' the patient identities established
     * on the old chain.
     */

    /**
     * modifier checkPatientIdentity(address patientIdentity, address patientIdentityRegistry) return (bool) {
     *  if ( patientIdentityRegistry.isValidContract(patientIdentity) != 1 ) {
     *    revert();
     *    _;
     *  }
     * }
*/


contract PatientIdentityRegistry {

    address private owner;
    uint constant WAITING = 0;
    uint constant ACTIVE = 1;
    uint constant REJECT = 2;

	uint constant EVENT_ERROR = 1;
    uint constant EVENT_WARNING = 2;
    uint constant EVENT_SIGNI_CHANGE = 3;
    uint constant EVENT_INFO = 4;

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
     * Standard change notification through event and outputing the following:
     * - contract owner
     * - status level of event
     * - message body for event
     */
    event ChangeNotification(address indexed sender, uint status, bytes32 msgNotification);

    /**
     * Function is used to send events.
     * Status Level:
     *  1   error conditions
     *  2   warning conditions
     *  3   Significant change to condition
     *  4   informational messages
     *  5   debug-level messages
    */
    function sendEvent(uint _status, bytes32 _notification) internal returns(bool) {
        ChangeNotification(owner, _status, _notification);
        return true;
    }

    /**
     * Any patient can submit a contract for acceptance into a registry.
     */
    function submitContract(bytes32 _contractHash) returns(bool) {
        var picontract = picontracts[_contractHash];
        picontract.hash = _contractHash;
        picontract.submitter = msg.sender;
        picontract.status = WAITING;
		sendEvent(EVENT_SIGNI_CHANGE, "Contract submitted");
        return true;
    }

    /**
     * Only the registry owner can approve a contract.
     */
    function approveContract(bytes32 _contractHash) onlyBy(owner) returns(bool) {
        var picontract = picontracts[_contractHash];
        picontract.status = ACTIVE;
		sendEvent(EVENT_SIGNI_CHANGE, "Contract approved");
        return true;
    }

    /**
     * Only the registry owner can reject a contract.
     */
    function rejectContract(bytes32 _contractHash) onlyBy(owner) returns(bool) {
        var picontract = picontracts[_contractHash];
        picontract.status = REJECT;
		sendEvent(EVENT_WARNING, "Contract rejected");
        return true;
    }

    /**
     * This is the public registry function that contracts should use to check
     * whether a contract is valid. 
     */
    function isValidContract(bytes32 _contractHash) returns(bool) {
        if (picontracts[_contractHash].status == ACTIVE) {
			sendEvent(EVENT_INFO, "Valid");
            return true;
        }
        if (picontracts[_contractHash].status == REJECT) {
			sendEvent(EVENT_ERROR, "REJECTED");
            revert();
        } else {
			sendEvent(EVENT_ERROR, "INVALID");
            return false;
        }
    }

}