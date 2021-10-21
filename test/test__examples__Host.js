"use strict";

const Host = artifacts.require("Host");
const Account = artifacts.require("Account");
const AddressStorage = artifacts.require("AddressStorage");

//
contract("test/examples/Host.sol", (accounts) => {
  const owner_Host = accounts[1];
  const owner_Account = accounts[2];
  const owner_Account__name = "Jain";
  const owner_Account__new_owner = accounts[9];

  //
  afterEach(async () => {
    const host = await Host.deployed();

    const active_accounts_reference = await host.active_accounts.call();
    const active_accounts_instance = await AddressStorage.at(
      active_accounts_reference
    );

    const banned_accounts_reference = await host.banned_accounts.call();
    const banned_accounts_instance = await AddressStorage.at(
      banned_accounts_reference
    );

    for (const account_owner of [owner_Account, owner_Account__new_owner]) {
      if (await active_accounts_instance.has(account_owner)) {
        await host.removeAccount(account_owner, { from: owner_Host });
      }

      if (await banned_accounts_instance.has(account_owner)) {
        await host.removeAccount(account_owner, { from: owner_Host });
      }
    }
  });

  //
  it("Host.banAccount allowed for owner on active account", async () => {
    const host = await Host.deployed();
    await host.registerAccount(owner_Account, owner_Account__name);

    const {
      logs: [log = {}],
    } = await host.banAccount(owner_Account, { from: owner_Host });

    assert.equal(log.event, "BannedAccount", "Failed to parse expected event");

    const {
      args: { owner, account_reference },
    } = log;

    return assert.equal(
      owner,
      owner_Account,
      "Failed to parse expected account owner"
    );
  });

  //
  it("Host.importAccount allowed for new contract", async () => {
    const host = await Host.deployed();
    const account = await Account.deployed();

    const {
      logs: [log = {}],
    } = await host.importAccount(account.address);

    assert.equal(
      log.event,
      "ActivatedAccount",
      "Failed to parse expected event"
    );

    const {
      args: { owner, account_reference },
    } = log;

    return assert.equal(
      owner,
      owner_Account,
      "Failed to parse expected account owner"
    );
  });

  //
  it("Host.importAccount disallows duplicate accounts", async () => {
    const host = await Host.deployed();
    const account = await Account.deployed();
    await host.importAccount(account.address);
    try {
      await host.importAccount(account.address);
    } catch (error) {
      if (error.reason === "Host.importAccount: account already active") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Host.importAccount disallows banned accounts", async () => {
    const host = await Host.deployed();
    const account = await Account.deployed();
    await host.importAccount(account.address);
    await host.banAccount(await account.owner(), { from: owner_Host });
    try {
      await host.importAccount(account.address);
    } catch (error) {
      if (error.reason === "Host.importAccount: account was banned") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Host.registerAccount allows new account", async () => {
    const host = await Host.deployed();

    const {
      logs: [log = {}],
    } = await host.registerAccount(owner_Account, owner_Account__name);

    assert.equal(
      log.event,
      "ActivatedAccount",
      "Failed to parse expected event"
    );

    const {
      args: { owner, account_reference },
    } = log;

    return assert.equal(
      owner,
      owner_Account,
      "Failed to parse expected account owner"
    );
  });

  //
  it("Host.registerAccount disallows duplicate accounts", async () => {
    const host = await Host.deployed();
    await host.registerAccount(owner_Account, owner_Account__name);
    try {
      await host.registerAccount(owner_Account, owner_Account__name);
    } catch (error) {
      if (error.reason === "Host.registerAccount: account already active") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Host.registerAccount disallows banned accounts", async () => {
    const host = await Host.deployed();
    await host.registerAccount(owner_Account, owner_Account__name);
    await host.banAccount(owner_Account, { from: owner_Host });
    try {
      await host.registerAccount(owner_Account, owner_Account__name);
    } catch (error) {
      if (error.reason === "Host.registerAccount: account was banned") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Host.updateKey allowed by Account owner", async () => {
    const host = await Host.deployed();
    const account = await Account.new(owner_Account, owner_Account__name);
    await host.importAccount(account.address);
    await account.changeOwner(owner_Account__new_owner, {
      from: owner_Account,
    });
    await host.updateKey(owner_Account, { from: owner_Account__new_owner });
  });

  //
  it("Host.updateKey disallowed from non-owner of Account", async () => {
    const host = await Host.deployed();
    const account = await Account.new(owner_Account, owner_Account__name);
    await host.importAccount(account.address);

    await account.changeOwner(owner_Account__new_owner, {
      from: owner_Account,
    });

    try {
      await host.updateKey(owner_Account, { from: owner_Host });
    } catch (error) {
      if (error.reason === "Host.updateKey: message sender not Account owner") {
        return assert.isTrue(true, "Wat!?");
      }
      console.error(error);
    }
    return assert.isTrue(false, "Failed to catch expected error reason");
  });

  //
  it("Host.whoIs returns expected account name", async () => {
    const host = await Host.deployed();
    await host.registerAccount(owner_Account, owner_Account__name);
    const name = await host.whoIs(owner_Account);
    return assert.equal(
      name,
      owner_Account__name,
      "Failed to parse expected name from contract"
    );
  });
});
