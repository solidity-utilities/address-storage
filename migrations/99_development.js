"use strict";

module.exports = (deployer, network, accounts) => {
  if (network !== "development") {
    return;
  }

  console.log("Notice: detected network of development kind ->", { network });

  const LibraryMappingAddress = artifacts.require("LibraryMappingAddress");
  const AddressStorage = artifacts.require("AddressStorage");
  const Account = artifacts.require("Account");
  const Host = artifacts.require("Host");

  const owner_AddressStorage = accounts[0]
  const owner_Host = accounts[1]
  const owner_Account = accounts[2]
  const owner_Account__name = 'Jain';

  // LibraryMappingAddress.address = "0x0...";
  deployer.deploy(LibraryMappingAddress, { overwrite: false });
  deployer.link(LibraryMappingAddress, [AddressStorage, Host]);

  deployer.deploy(AddressStorage, owner_AddressStorage);
  deployer.deploy(Host, owner_Host);
  deployer.deploy(Account, owner_Account, owner_Account__name);
};

