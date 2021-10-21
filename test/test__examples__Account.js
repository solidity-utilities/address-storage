"use strict";

const Account = artifacts.require("Account");

//
contract("test/examples/Account.sol", (accounts) => {
  const owner_Account = accounts[2];
  const owner_Account__name = "Jain";
  const owner_Account__new_name = 'Ted';
  const owner_Account__new_owner = accounts[9];

  //
  afterEach(async () => {
    const account = await Account.deployed();

    if (await account.owner() === owner_Account__new_owner) {
      await account.changeOwner(owner_Account, { from: owner_Account__new_owner });
    }

    if (await account.name() !== owner_Account__name) {
      await account.changeName(owner_Account__name, { from: owner_Account });
    }
  });

  //
  it("Account.changeName allowed for owner", async () => {
    const account = await Account.deployed();
    await account.changeName(owner_Account__new_name, { from: owner_Account });
    return assert.equal(owner_Account__new_name, await account.name(), "Failed to change name");
  });

  //
  it("Account.changeName disallowed for non-owner", async () => {
    const account = await Account.deployed();
    try {
      await account.changeName(owner_Account__new_name, { from: owner_Account__new_owner });
    } catch (error) {
      if (error.reason === "Account.changeName: message sender not an owner") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Account.changeOwner allowed for owner", async () => {
    const account = await Account.deployed();
    await account.changeOwner(owner_Account__new_owner, { from: owner_Account });
    return assert.equal(owner_Account__new_owner, await account.owner(), "Failed to change owner");
    assert.isTrue(true);
  });

  //
  it("Account.changeOwner disallowed for non-owner", async () => {
    const account = await Account.deployed();
    try {
      await account.changeOwner(owner_Account__new_owner, { from: owner_Account__new_owner });
    } catch (error) {
      if (error.reason === "Account.changeOwner: message sender not an owner") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });
});
