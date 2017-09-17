var PatientIdentity = artifacts.require("Patient_Identity.sol");
var PatientIdentityRegistry = artifacts.require("PatientIdentityRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(PatientIdentity);
  deployer.deploy(PatientIdentityRegistry);
  deployer.link(PatientIdentity, PatientIdentityRegistry);
};