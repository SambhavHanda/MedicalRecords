/**
  * The purpose of this test contract is to test the functions in PatientIdentityRegistry.sol.
  */

var PatientIdentityRegistry = artifacts.require("PatientIdentityRegistry");

contract('PatientIdentityRegistry', function(accounts) {

    var registry,
        contractRegistry1,
        contracthash1,
        
    contracthash1 = '0xca02b2202ffaacbd499538ef6d594a48f7a7631b60405ec8f30a0e7c096d54d9';

    before("Setup the Patient Identity registry and populate the variables", function(done) {
        contractRegistry1 = accounts[0];
        
        PatientIdentityRegistry.new({from: contractRegistry1})
        .then(function(response) {
            registry = response;
            done();
        });

        return registry,
        contractRegistry1,
      
    });

    describe("PatientIdentityRegistry tests", function() {

        it("submit a Patient contract into the registry", function() {
            return registry.submitContract(contracthash1, {from: contractRegistry1})
            .then(function(response) {
                assert.isOk(response, 'Contract submitting failed');
            });
        });

        it("proved that the registry owner can approve a contract", function() {
            return registry.approveContract(contracthash1, {from: contractRegistry1})
            .then(function(response) {
                assert.isOk(response, 'Contract approval failed');
            });
        });

    });

});