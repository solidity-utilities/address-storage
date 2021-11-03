// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import { LibraryMappingAddress } from "@solidity-utilities/library-mapping-address/contracts/LibraryMappingAddress.sol";

/// @title Solidity contract for storing and interacting with key/value `address` pairs
/// @dev Depends on `@solidity-utilities/library-mapping-address`
/// @author S0AndS0
contract AddressStorage {
    using LibraryMappingAddress for mapping(address => address);
    /// Store key/value `address` pairs
    mapping(address => address) public data;
    /// Warning order of indexes **NOT** guaranteed!
    mapping(address => uint256) public indexes;
    /// Warning order of keys **NOT** guaranteed!
    address[] public keys;
    /// Allow mutation or selfdestruct from specified `address`
    address public owner;
    /// Allow mutation from mapped `address`s
    mapping(address => bool) public authorized;

    /* -------------------------------------------------------------------- */

    /// @notice Define instance of `AddressStorage`
    /// @param _owner **{address}** Account or contract authorized to mutate stored data
    constructor(address _owner) {
        owner = _owner;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Requires message sender to be an instance owner
    /// @param _caller **{string}** Function name that implements this modifier
    /// @custom:throws **{Error}** `"AddressStorage._caller: message sender not an owner"`
    modifier onlyOwner(string memory _caller) {
        string memory _message = string(
            abi.encodePacked(
                "AddressStorage.",
                _caller,
                ": message sender not an owner"
            )
        );
        require(msg.sender == owner, _message);
        _;
    }

    /// @notice Requires message sender to be in authorized mapping
    /// @param _caller **{string}** Function name that implements this modifier
    /// @custom:throws **{Error}** `"AddressStorage._caller: message sender not authorized"`
    modifier onlyAuthorized(string memory _caller) {
        string memory _message = string(
            abi.encodePacked(
                "AddressStorage.",
                _caller,
                ": message sender not authorized"
            )
        );
        require(authorized[msg.sender] || msg.sender == owner, _message);
        _;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Insert `address` into `mapping` of `authorized` data structure
    /// @dev Does not check if `address` is already `authorized`
    /// @param _key **{address}** Key to set value of `true`
    /// @custom:throws **{Error}** `"AddressStorage.addAuthorized: message sender not authorized"`
    function addAuthorized(address _key) external onlyOwner("addAuthorized") {
        authorized[_key] = true;
    }

    /// @notice Overwrite old `owner` with new owner `address`
    /// @param _new_owner **{address}** New owner address
    /// @custom:throws **{Error}** `"AddressStorage.changeOwner: message sender not an owner"`
    function changeOwner(address _new_owner) external onlyOwner("changeOwner") {
        owner = _new_owner;
    }

    /// @notice Delete `mapping` address key/value pairs and remove all `address` from `keys`
    /// @dev **Warning** may fail if storing many `address` pairs
    /// @custom:throws **{Error}** `"AddressStorage.clear: message sender not authorized"`
    function clear() external onlyAuthorized("clear") {
        uint256 _index = keys.length;
        while (_index > 0) {
            _index--;
            address _key = keys[_index];
            data.remove(_key);
            delete indexes[_key];
            keys.pop();
        }
    }

    /// @notice Remove `address` from `mapping` of `authorized` data structure
    /// @param _key **{address}** Key to set value of `false`
    /// @custom:throws **{Error}** `"AddressStorage.deleteAuthorized: message sender not authorized"`
    /// @custom:throws **{Error}** `"AddressStorage.deleteAuthorized: cannot remove owner"`
    function deleteAuthorized(address _key)
        external
        onlyAuthorized("deleteAuthorized")
    {
        require(
            msg.sender == owner || msg.sender == _key,
            "AddressStorage.deleteAuthorized: message sender not authorized"
        );
        require(
            _key != owner,
            "AddressStorage.deleteAuthorized: cannot remove owner"
        );
        delete authorized[_key];
    }

    /// @notice Retrieve stored value `address` or throws an error if _undefined_
    /// @dev Passes parameter to `data.getOrError` with default Error `_reason` to throw
    /// @param _key **{address}** Mapping key `address` to lookup corresponding value `address` for
    /// @return **{address}** Value for given key `address`
    /// @custom:throws **{Error}** `"AddressStorage.get: value not defined"`
    function get(address _key) external view returns (address) {
        return data.getOrError(_key, "AddressStorage.get: value not defined");
    }

    /// @notice Retrieve stored value `address` or provided default `address` if _undefined_
    /// @dev Forwards parameters to `data.getOrElse`
    /// @param _key **{address}** Mapping key `address` to lookup corresponding value `address` for
    /// @param _default **{address}** Value to return if key `address` lookup is _undefined_
    /// @return **{address}** Value `address` for given key `address` or `_default` if _undefined_
    function getOrElse(address _key, address _default)
        external
        view
        returns (address)
    {
        return data.getOrElse(_key, _default);
    }

    /// @notice Allow for defining custom error reason if value `address` is _undefined_
    /// @dev Forwards parameters to `data.getOrError`
    /// @param _key **{address}** Mapping key `address` to lookup corresponding value `address` for
    /// @param _reason **{string}** Custom error message to throw if value `address` is _undefined_
    /// @return **{address}** Value for given key `address`
    /// @custom:throws **{Error}** `_reason` if value is _undefined_
    function getOrError(address _key, string memory _reason)
        external
        view
        returns (address)
    {
        return data.getOrError(_key, _reason);
    }

    /// @notice Check if `address` key has a corresponding value `address` defined
    /// @dev Forwards parameter to `data.has`
    /// @param _key **{address}** Mapping key to check if value `address` is defined
    /// @return **{bool}** `true` if value `address` is defined, or `false` if _undefined_
    function has(address _key) external view returns (bool) {
        return data.has(_key);
    }

    /// @notice Index for `address` key within `keys` array
    /// @dev Passes parameter to `indexOfOrError` with default `_reason`
    /// @param _key **{address}** Key to lookup index for
    /// @return **{uint256}** Current index for given `_key` within `keys` array
    /// @custom:throws **{Error}** `"AddressStorage.indexOf: key not defined"`
    function indexOf(address _key) external view returns (uint256) {
        return indexOfOrError(_key, "AddressStorage.indexOf: key not defined");
    }

    /// @notice Index for `address` key within `keys` array
    /// @dev Cannot depend on results being valid if mutation is allowed between calls
    /// @param _key **{address}** Key to lookup index for
    /// @param _reason **{string}** Custom error message to throw if value `address` is _undefined_
    /// @return **{uint256}** Current index for given `_key` within `keys` array
    /// @custom:throws **{Error}** `_reason` if value for `_key` is _undefined_
    function indexOfOrError(address _key, string memory _reason)
        public
        view
        returns (uint256)
    {
        require(data.has(_key), _reason);
        return indexes[_key];
    }

    /// @notice Convenience function to read all `mapping` key addresses
    /// @dev Cannot depend on results being valid if mutation is allowed between calls
    /// @return **{address[]}** Keys `address` array
    function listKeys() external view returns (address[] memory) {
        return keys;
    }

    /// @notice Delete value `address` for given `_key`
    /// @dev Passes parameter to `removeOrError` with default `_reason`
    /// @param _key **{address}** Mapping key to delete corresponding value `address` for
    /// @return **{address}** Value `address` that was removed from `data` storage
    /// @custom:throws **{Error}** `"AddressStorage.remove: message sender not authorized"`
    /// @custom:throws **{Error}** `"AddressStorage.remove: value not defined"`
    function remove(address _key)
        external
        onlyAuthorized("remove")
        returns (address)
    {
        return removeOrError(_key, "AddressStorage.remove: value not defined");
    }

    /// @notice Delete value `address` for given `_key`
    /// @dev **Warning** reorders `keys`, and mutates `indexes`, for efficiency reasons
    /// @param _key **{address}** Mapping key to delete corresponding value `address` for
    /// @param _reason **{string}** Custom error message to throw if value `address` is _undefined_
    /// @return **{address}** Value `address` that was removed from `data` storage
    /// @custom:throws **{Error}** `"AddressStorage.removeOrError: message sender not authorized"`
    /// @custom:throws **{Error}** `_reason` if value is _undefined_
    function removeOrError(address _key, string memory _reason)
        public
        onlyAuthorized("removeOrError")
        returns (address)
    {
        address _value = data.removeOrError(_key, _reason);
        uint256 _last_index = keys.length - 1;
        address _last_key = keys[_last_index];
        if (keys.length > 1) {
            uint256 _target_index = indexes[_key];
            keys[_target_index] = keys[_last_index];
            indexes[_last_key] = _target_index;
        }
        delete indexes[_last_key];
        keys.pop();
        return _value;
    }

    /// @notice Call `selfdestruct` with provided `address`
    /// @param _to **{address}** Where to transfer any funds this contract has
    /// @custom:throws **{Error}** `"AddressStorage.selfDestruct: message sender not an owner"`
    function selfDestruct(address payable _to)
        external
        onlyOwner("selfDestruct")
    {
        selfdestruct(_to);
    }

    /// @notice Store `_value` under given `_key` while preventing unintentional overwrites
    /// @dev Forwards parameters to `setOrError` with default `_reason`
    /// @param _key **{address}** Mapping key to set corresponding value `address` for
    /// @param _value **{address}** Mapping value to set
    /// @custom:throws **{Error}** `"AddressStorage.set: message sender not authorized"`
    /// @custom:throws **{Error}** `"AddressStorage.set: value already defined"`
    function set(address _key, address _value) external onlyAuthorized("set") {
        setOrError(_key, _value, "AddressStorage.set: value already defined");
    }

    /// @notice Store `_value` under given `_key` while preventing unintentional overwrites
    /// @dev Forwards parameters to `data.setOrError`
    /// @param _key **{address}** Mapping key to set corresponding value `address` for
    /// @param _value **{address}** Mapping value to set
    /// @param _reason **{string}** Custom error message to present if value `address` is defined
    /// @custom:throws **{Error}** `"AddressStorage.setOrError: message sender not authorized"`
    /// @custom:throws **{Error}** `_reason` if value is defined
    function setOrError(
        address _key,
        address _value,
        string memory _reason
    ) public onlyAuthorized("setOrError") {
        data.setOrError(_key, _value, _reason);
        indexes[_key] = keys.length;
        keys.push(_key);
    }

    /// @notice Number of key/value `address` pairs stored
    /// @dev Cannot depend on results being valid if mutation is allowed between calls
    /// @return **{uint256}** Length of `keys` array
    function size() external view returns (uint256) {
        return keys.length;
    }
}
