/**
  * The purpose of this test contract is to test the functions in PatientIdentity.sol
  * that use records.
  */

var PatientIdentity = artifacts.require("PatientIdentity");

contract('PatientIdentity', function(accounts) {

    var patientIdentity,
        owner,
        endorser,
        recordHash1,
        recordHash2,
        recordHash3,
        recordHash4;

    recordHash1 = '0xca02b2202ffaacbd499438eg6d584a48f7a7631b60405ec8f39a0d7c086d54d4';
    recordHash2 = '............';
    recordHash3 = '............';
    recordHash4 = '............';

    before("Setup the Patient Identity contract and initialize the variables", function(done) {
        owner = accounts[0];
        endorser = accounts[1];
        thirdparty = accounts[2];

        PatientIdentity.new({from: owner})
        .then(function(data) {
            patientIdentity = data;
            done();
        });

        return patientIdentity,
        owner,
        endorser,
        
    });

    describe("Record tests", function() {

        it("added a record as the owner, and succeed", function() {
            return patientIdentity.addRecord(recordHash1, {from: owner})
            .then(function(response) {
                assert.isOk(response, "Record addition failed");
                
            });
        });

        it("confirmed that the owner's record has been added successfully", function() {
            return patientIdentity.records.call(recordHash1)
            .then(function(response) {
                assert.equal(response.valueOf(), recordHash1, "Record hash does not exist");
            });
        });
		
		it("removed a Record as an owner, and succeed", function() {
            return patientIdentity.removeRecord(recordHash1, {from: owner})
            .then(function(response) {
                assert.isOk(response, "Record removal failed");
            });
        });
		
		});
}, status_code);