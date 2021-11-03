// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import { AddressStorage } from "../contracts/AddressStorage.sol";

///
contract Test_AddressStorage {
    address payable owner_AddressStorage = payable(address(this));
    address _key = address(0x1);
    address _value = address(0x2);
    address _default_value = address(0x3);
    address _moderator = address(0x4);

    AddressStorage data = new AddressStorage(owner_AddressStorage);

    ///
    function afterEach() public {
        if (data.has(_key)) {
            data.remove(_key);
        }
        if (data.authorized(_moderator)) {
            data.deleteAuthorized(_moderator);
        }
    }

    ///
    function test_addAuthorized() public {
        Assert.isFalse(
            data.authorized(_moderator),
            "Address already authorized"
        );
        data.addAuthorized(_moderator);
        Assert.isTrue(
            data.authorized(_moderator),
            "Failed to authorize address"
        );
    }

    ///
    function test_addAuthorized_not_owner() public {
        AddressStorage _data = new AddressStorage(_key);
        try _data.addAuthorized(_value) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "AddressStorage.addAuthorized: message sender not an owner",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_deleteAuthorized() public {
        Assert.isFalse(
            data.authorized(_moderator),
            "Address already authorized"
        );
        data.addAuthorized(_moderator);
        Assert.isTrue(
            data.authorized(_moderator),
            "Failed to authorize address"
        );
        data.deleteAuthorized(_moderator);
        Assert.isFalse(
            data.authorized(_moderator),
            "Failed to de-authenticate address"
        );
    }

    ///
    function test_deleteAuthorized_not_owner() public {
        AddressStorage _data = new AddressStorage(_key);
        try _data.deleteAuthorized(_value) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "AddressStorage.deleteAuthorized: message sender not authorized",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_get_error() public {
        try data.get(_key) returns (address _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "AddressStorage.get: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_getOrElse() public {
        address _got = data.getOrElse(_key, _default_value);
        Assert.equal(_got, _default_value, "Failed to get default value");
    }

    ///
    function test_getOrError() public {
        try
            data.getOrError(
                _key,
                "Test_AddressStorage.test_getOrError: value not defined"
            )
        returns (address _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "Test_AddressStorage.test_getOrError: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_has() public {
        Assert.isFalse(data.has(_key), "Somehow key/value was defined");
        data.set(_key, _value);
        Assert.isTrue(data.has(_key), "Failed to define key/value pair");
    }

    ///
    function test_remove_error() public {
        try data.remove(_key) returns (address _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "AddressStorage.remove: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_removeOrError() public {
        try
            data.removeOrError(
                _key,
                "Test_AddressStorage.test_removeOrError: value not defined"
            )
        returns (address _result) {
            Assert.equal(_result, _key, "Failed to catch error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "Test_AddressStorage.test_removeOrError: value not defined",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_selfdestruct() public {
        AddressStorage _data = new AddressStorage(owner_AddressStorage);
        _data.selfDestruct(owner_AddressStorage);
    }

    ///
    function test_selfdestruct_non_owner() public {
        AddressStorage _data = new AddressStorage(_key);
        try _data.selfDestruct(owner_AddressStorage) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "AddressStorage.selfDestruct: message sender not an owner",
                "Caught unexpected error reason"
            );
        }
    }

    ///
    function test_set() public {
        data.set(_key, _value);
        address _got = data.get(_key);
        Assert.equal(_got, _value, "Failed to get expected value");
    }

    ///
    function test_set_error() public {
        data.set(_key, _value);
        try data.set(_key, _value) {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "AddressStorage.set: value already defined",
                "Caught unexpected error reason"
            );
        }
        data.remove(_key);
        Assert.isFalse(data.has(_key), "Failed to remove value by key");
    }

    ///
    function test_setOrError() public {
        data.set(_key, _value);
        try
            data.setOrError(
                _key,
                _value,
                "Test_AddressStorage.test_setOrError: value already defined"
            )
        {
            Assert.isTrue(false, "Failed to catch expected error");
        } catch Error(string memory _reason) {
            Assert.equal(
                _reason,
                "Test_AddressStorage.test_setOrError: value already defined",
                "Caught unexpected error reason"
            );
        }
        data.remove(_key);
        Assert.isFalse(data.has(_key), "Failed to remove value by key");
    }
}
