"use strict";

const LibraryMappingAddress = artifacts.require("LibraryMappingAddress");
const AddressStorage = artifacts.require("AddressStorage");

module.exports = (deployer, _network, accounts) => {
  const owner_AddressStorage = accounts[0]

  // LibraryMappingAddress.address = "0x0...";
  deployer.deploy(LibraryMappingAddress, { overwrite: false });
  // deployer.deploy(LibraryMappingAddress);
  deployer.link(LibraryMappingAddress, AddressStorage);
  deployer.deploy(AddressStorage, owner_AddressStorage);
};

