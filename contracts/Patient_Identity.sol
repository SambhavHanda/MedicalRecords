pragma solidity ^0.4.0;


contract Patient_Identity {

    address private owner;
    string public encryptionPublicKey;
    string public signPublicKey;
	
	uint constant EVENT_ERROR = 1;
    uint constant EVENT_WARNING = 2;
    uint constant EVENT_SIGNI_CHANGE = 3;
    uint constant EVENT_INFO = 4;
    uint constant EVENT_DEBUG = 5;

    mapping(bytes32 => Record) private records;

    /**
     * Constructor of the Patient Identity
     */
    function Patient_Identity() {
        owner = msg.sender;
    }

    /**
     * place a constraint on the user calling a function
     */
    modifier onlyBy(address _account) {
        if (msg.sender != _account) {
            revert();
        }
        _;
    }

    /**
     * The Record structure: every record is composed of:
     * - Record hash
     * - Endorsements
     */
    struct Record {
        bytes32 hash;
        mapping(bytes32 => Endorsement) endorsements;
    }

    /**
     * The endorsement structure: every endorsement is composed of:
     * - Endorser address
     * - Endorsement hash
     * - Accepted Status - true if the Patient has accepted the endorsement
     */
    struct Endorsement {
        address endorser;
        bytes32 hash;
        bool accepted;
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
     * Adds a record, with an empty list of endorsements.
     */
    function addRecord(bytes32 _hash) onlyBy(owner) returns(bool) {
        var record = records[_hash];
        if (record.hash == _hash) {
			sendEvent(EVENT_SIGNI_CHANGE, "A hash exists for the record");
            revert();
        }
        record.hash = _hash;
		sendEvent(EVENT_INFO, "Record has been added");
        return true;
    }

	/**
     * Retrieves a record hash.
     */
    function retrieveRecord(bytes32 _hash) onlyBy(owner) returns(bytes32) {
        var record = records[_hash];
        if (record.hash == _hash) {
		sendEvent(EVENT_SIGNI_CHANGE, "A hash exists for the record");
            revert();
        }
        return record.hash;
    }

	
    /**
     * This updates a record by removing the old one first. The event log should hold the record of the
     * transaction so at a future date it should be possible to traverse
     * the history of an attribute in the blockchain.
     */
    function updateRecord(bytes32 _oldhash, bytes32 _newhash) onlyBy(owner) returns(bool) {
		sendEvent(EVENT_DEBUG, "Attempting to update record");
        removeRecord(_oldhash);
        addRecord(_newhash);
		sendEvent(EVENT_SIGNI_CHANGE, "Record has been updated");
        return true;
    }

    /**
     * Removes a Record from a contract.
     */
    function removeRecord(bytes32 _hash) onlyBy(owner) returns(bool) {
        var record = records[_hash];
        if (record.hash != _hash) {
		sendEvent(EVENT_WARNING, "Hash not found for record");
            revert();
        }
        delete records[_hash];
		sendEvent(EVENT_SIGNI_CHANGE, "Record has been removed");
        return true;
    }

    /**
     * Adding endorsement to a record: requires a valid recordHash.
     */
    function addEndorsement(bytes32 _recordHash, bytes32 _endorsementHash) returns(bool) {
        var record = records[_recordHash];
        if (record.hash != _recordHash) {
			sendEvent(EVENT_ERROR, "Record doesn't exist");
            revert();
        }
        var endorsement = record.endorsements[_endorsementHash];
        if (endorsement.hash == _endorsementHash) {
			sendEvent(EVENT_ERROR, "Endorsement already exists");
            revert();
        }
        endorsement.hash = _endorsementHash;
        endorsement.endorser = msg.sender;
        endorsement.accepted = false;
		sendEvent(EVENT_INFO, "Endorsement has been added");
        return true;
    }

    /**
     * Patient can mark an endorsement as accepted.
     */
    function acceptEndorsement(bytes32 _recordHash, bytes32 _endorsementHash) onlyBy(owner) returns(bool) {
        var record = records[_recordHash];
        var endorsement = record.endorsements[_endorsementHash];
        endorsement.accepted = true;
		sendEvent(EVENT_SIGNI_CHANGE, "Endorsement has been accepted");
    }
	
	/**
     * Checking whether an _endorsementHash exists for the record _recordHash.
     */
    function checkIfEndorsementExists(bytes32 _recordHash, bytes32 _endorsementHash) returns(bool) {
        var record = records[_recordHash];
        if (record.hash != _recordHash) {
            sendEvent(EVENT_ERROR, "Record doesn't exist");
            return false;
        }
        var endorsement = record.endorsements[_endorsementHash];
        if (endorsement.hash != _endorsementHash) {
            sendEvent(EVENT_ERROR, "Endorsement doesn't exist");
            return false;
        }
        if (endorsement.accepted == true) {
            sendEvent(EVENT_INFO, "Endorsement exists for record");
            return true;
        } else {
            sendEvent(EVENT_ERROR, "Endorsement hasn't been accepted");
            return false;
        }
    }
	
	
    /**
     * Allows only the account owner to create or update encryptionPublicKey.
     */
    function setEncryptionPublicKey(string _myEncryptionPublicKey) onlyBy(owner) returns(bool) {
        encryptionPublicKey = _myEncryptionPublicKey;
		sendEvent(EVENT_SIGNI_CHANGE, "Encryption key added");
        return true;
    }

    /**
     * Allows only the account owner to create or update signingPublicKey.
     */
    function setSignPublicKey(string _mySignPublicKey) onlyBy(owner) returns(bool) {
        signPublicKey = _mySignPublicKey;
		sendEvent(EVENT_SIGNI_CHANGE, "Signing key added");
        return true;
    }

    /**
     * Kills the contract and prevents further actions on it.
     */
    function kill() onlyBy(owner) returns(uint) {
        suicide(owner);
		sendEvent(EVENT_WARNING, "Contract killed");
    }
}