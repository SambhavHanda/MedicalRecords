pragma solidity ^0.4.0;


contract Patient_Identity {

    address private owner;
    string public encryptionPublicKey;
    string public signPublicKey;

    mapping(bytes32 => Record) public records;

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
     * Adds a record, with an empty list of endorsements.
     */
    function addRecord(bytes32 _hash) onlyBy(owner) returns(bool) {
        var record = records[_hash];
        if (record.hash == _hash) {
            revert();
        }
        record.hash = _hash;
        return true;
    }

	/**
     * Retrieves a record.
     */
    function retrieveRecord(bytes32 _hash) onlyBy(owner) returns(record) {
        var record = records[_hash];
        if (record.hash == _hash) {
            revert();
        }
        return record;
    }

	
    /**
     * This updates a record by removing the old one first. The event log should hold the record of the
     * transaction so at a future date it should be possible to traverse
     * the history of an attribute in the blockchain.
     */
    function updateRecord(bytes32 _oldhash, bytes32 _newhash) onlyBy(owner) returns(bool) {
        removeRecord(_oldhash);
        addRecord(_newhash);
        return true;
    }

    /**
     * Removes a Record from a contract.
     */
    function removeRecord(bytes32 _hash) onlyBy(owner) returns(bool) {
        var record = records[_hash];
        if (record.hash != _hash) {
            revert();
        }
        delete records[_hash];
        return true;
    }

    /**
     * Adding endorsement to a record: requires a valid recordHash.
     */
    function addEndorsement(bytes32 _recordHash, bytes32 _endorsementHash) returns(bool) {
        var record = records[_recordHash];
        if (record.hash != _recordHash) {
            revert();
        }
        var endorsement = record.endorsements[_endorsementHash];
        if (endorsement.hash == _endorsementHash) {
            revert();
        }
        endorsement.hash = _endorsementHash;
        endorsement.endorser = msg.sender;
        endorsement.accepted = false;
        return true;
    }

    /**
     * Patient can mark an endorsement as accepted.
     */
    function acceptEndorsement(bytes32 _recordHash, bytes32 _endorsementHash) onlyBy(owner) returns(bool) {
        var record = records[_recordHash];
        var endorsement = record.endorsements[_endorsementHash];
        endorsement.accepted = true;
    }

    /**
     * Allows only the account owner to create or update encryptionPublicKey.
     */
    function setEncryptionPublicKey(string _myEncryptionPublicKey) onlyBy(owner) returns(bool) {
        encryptionPublicKey = _myEncryptionPublicKey;
        return true;
    }

    /**
     * Allows only the account owner to create or update signingPublicKey.
     */
    function setSignPublicKey(string _mySignPublicKey) onlyBy(owner) returns(bool) {
        signPublicKey = _mySignPublicKey;
        return true;
    }

    /**
     * Kills the contract and prevents further actions on it.
     */
    function kill() onlyBy(owner) returns(uint) {
        suicide(owner);
    }
}