// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import { AddressStorage } from "../../contracts/AddressStorage.sol";
// import {
//     AddressStorage
// } from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";
import { Account } from "./Account.sol";

/// @title Example contract to demonstrate further abstraction of `AddressStorage` features
/// @author S0AndS0
contract Host {
    AddressStorage public active_accounts = new AddressStorage(address(this));
    AddressStorage public banned_accounts = new AddressStorage(address(this));
    address public owner;

    /* -------------------------------------------------------------------- */

    ///
    constructor(address _owner) {
        owner = _owner;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Require message sender to be an instance owner
    /// @param _caller {string} Function name that implements this modifier
    modifier onlyOwner(string memory _caller) {
        string memory _message = string(
            abi.encodePacked("Host.", _caller, ": message sender not an owner")
        );
        require(msg.sender == owner, _message);
        _;
    }

    /// @notice Require `_key` to not be stored by `active_accounts`
    /// @param _key **{address}** Reference to `Account.owner`
    modifier onlyNotActive(address _key, string memory _caller) {
        string memory _message = string(
            abi.encodePacked("Host.", _caller, ": account already active")
        );
        require(!active_accounts.has(_key), _message);
        _;
    }

    /// @notice Require `_key` to not be stored by `banned_accounts`
    /// @param _key **{address}** Reference to `Account.owner`
    modifier onlyNotBanned(address _key, string memory _caller) {
        string memory _message = string(
            abi.encodePacked("Host.", _caller, ": account was banned")
        );
        require(!banned_accounts.has(_key), _message);
        _;
    }

    /* -------------------------------------------------------------------- */

    ///
    event ActivatedAccount(address owner, address account_reference);

    ///
    event BannedAccount(address owner, address account_reference);

    /* -------------------------------------------------------------------- */

    /// @notice Move `Account` reference from `active_accounts` to `banned_accounts`
    /// @param _key **{address}** Key within `active_accounts` to ban
    /// @custom:throws `"Host.banAccount: not active"`
    /// @custom:throws `"Host.banAccount: already banned"`
    function banAccount(address _key) external onlyOwner("banAccount") {
        address _account_reference = active_accounts.removeOrError(
            _key,
            "Host.banAccount: not active"
        );
        banned_accounts.setOrError(
            _key,
            _account_reference,
            "Host.banAccount: already banned"
        );
        emit BannedAccount(_key, _account_reference);
    }

    /// @notice Add existing `Account` instance to `active_accounts`
    /// @param **{Account}** Previously deployed `Account` contract instance
    /// @return **{Account}** Instance of `Account`
    /// @custom:throws `"Host.importAccount: account already active"`
    /// @custom:throws `"Host.importAccount: account was banned"`
    function importAccount(Account _account)
        public
        onlyNotActive(_account.owner(), "importAccount")
        onlyNotBanned(_account.owner(), "importAccount")
        returns (Account)
    {
        address _owner = _account.owner();
        address _account_reference = address(_account);
        active_accounts.set(_owner, _account_reference);
        emit ActivatedAccount(_owner, _account_reference);
        return _account;
    }

    /// @notice Initialize new instance of `Account` and add to `active_accounts`
    /// @param _owner **{address}** Account owner to assign
    /// @param _name **{string}** Account name to assign
    /// @return **{Account}** Instance of `Account` with given `owner` and `name`
    /// @custom:throws `"Host.registerAccount: account already active"`
    /// @custom:throws `"Host.registerAccount: account was banned"`
    function registerAccount(address _owner, string memory _name)
        external
        onlyNotActive(_owner, "registerAccount")
        onlyNotBanned(_owner, "registerAccount")
        returns (Account)
    {
        require(!active_accounts.has(_owner), "account already active");
        require(!banned_accounts.has(_owner), "account was banned");

        Account _account = new Account(_owner, _name);
        address _account_reference = address(_account);

        active_accounts.set(_owner, _account_reference);
        emit ActivatedAccount(_owner, _account_reference);

        return _account;
    }

    /// @notice Delete reference from either `active_accounts` or `banned_accounts`
    /// @param _key **{address}** Owner of `Account` instance to remove
    /// @return **{Account}** Instance from removed value `address`
    /// @custom:throws `"Host.removeAccount: message sender not an owner"`
    /// @custom:throws `"Host.removeAccount: account not available"`
    function removeAccount(address _key)
        external
        onlyOwner("removeAccount")
        returns (Account)
    {
        address _account_reference;
        if (active_accounts.has(_key)) {
            _account_reference = active_accounts.remove(_key);
        } else if (banned_accounts.has(_key)) {
            _account_reference = banned_accounts.remove(_key);
        }

        require(
            _account_reference != address(0x0),
            "Host.removeAccount: account not available"
        );

        return Account(_account_reference);
    }

    /// @notice Sync `active_accounts` key with `Account.owner`
    /// @dev Account instance should update `owner` before calling this method
    /// @param _key **{address}** Old owner `address` to sync with `Account.owner`
    /// @custom:throws **{Error}** `"Host.updateKey: message sender not Account owner"`
    function updateKey(address _key) external {
        Account _account = Account(active_accounts.get(_key));
        require(
            msg.sender == _account.owner(),
            "Host.updateKey: message sender not Account owner"
        );
        active_accounts.remove(_key);
        importAccount(_account);
    }

    /// @notice Retrieve `Account.name` for given `_key`
    /// @param _key **{address}** Owner of `active_accounts` instance
    /// @return **{string}** Name saved within `Account` instance
    /// @custom:throws **{Error}** `"Host.whoIs: account not active"`
    function whoIs(address _key) external view returns (string memory) {
        address _account_reference = active_accounts.getOrError(
            _key,
            "Host.whoIs: account not active"
        );
        Account _account_instance = Account(_account_reference);
        return _account_instance.name();
    }
}
