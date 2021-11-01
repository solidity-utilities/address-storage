# Address Storage
[heading__top]:
  #address-storage
  "&#x2B06; Solidity contract for storing and interacting with key/value address pairs"


Solidity contract for storing and interacting with key/value address pairs


## [![Byte size of Address Storage][badge__main__address_storage__source_code]][address_storage__main__source_code] [![Open Issues][badge__issues__address_storage]][issues__address_storage] [![Open Pull Requests][badge__pull_requests__address_storage]][pull_requests__address_storage] [![Latest commits][badge__commits__address_storage__main]][commits__address_storage__main] [![Build Status][badge__github_actions]][activity_log__github_actions]


---


- [:arrow_up: Top of Document][heading__top]

- [:building_construction: Requirements][heading__requirements]

- [:zap: Quick Start][heading__quick_start]

- [&#x1F9F0; Usage][heading__usage]

- [&#x1F523; API][heading__api]
  - [Contract `AddressStorage`][heading__contract_addressstorage]
    - [Method `changeOwner`][heading__method_changeowner]
    - [Method `clear`][heading__method_clear]
    - [Method `get`][heading__method_get]
    - [Method `getOrElse`][heading__method_getorelse]
    - [Method `getOrError`][heading__method_getorerror]
    - [Method `has`][heading__method_has]
    - [Method `indexOf`][heading__method_indexof]
    - [Method `indexOfOrError`][heading__method_indexoforerror]
    - [Method `listKeys`][heading__method_listkeys]
    - [Method `remove`][heading__method_remove]
    - [Method `removeOrError`][heading__method_removeorerror]
    - [Method `selfDestruct`][heading__method_selfdestruct]
    - [Method `set`][heading__method_set]
    - [Method `setOrError`][heading__method_setorerror]
    - [Method `size`][heading__method_size]

- [&#x1F5D2; Notes][heading__notes]

- [:chart_with_upwards_trend: Contributing][heading__contributing]
  - [:trident: Forking][heading__forking]
  - [:currency_exchange: Sponsor][heading__sponsor]

- [&#x1f4dc; Change Log][heading__change_log]
  - [Version `0.1.0`][heading__version_010]

- [:card_index: Attribution][heading__attribution]

- [:balance_scale: Licensing][heading__license]


---



## Requirements
[heading__requirements]:
  #requirements
  "&#x1F3D7; Prerequisites and/or dependencies that this project needs to function properly"


> Prerequisites and/or dependencies that this project needs to function properly


This project utilizes Truffle for organization of source code and tests, thus
it is recommended to install Truffle _globally_ to your current user account


```Bash
npm install -g truffle
```


______


## Quick Start
[heading__quick_start]:
  #quick-start
  "&#9889; Perhaps as easy as one, 2.0,..."


> Perhaps as easy as one, 2.0,...


NPM and Truffle are recommended for importing and managing dependencies


```Bash
cd your_project

npm install @solidity-utilities/address-storage
```


> Note, source code will be located within the
> `node_modules/@solidity-utilities/address-storage` directory of
> _`your_project`_ root


Solidity contracts may then import code via similar syntax as shown


```Solidity
import {
    AddressStorage
} from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";
```


> Note, above path is **not** relative (ie. there's no `./` preceding the file
> path) which causes Truffle to search the `node_modules` subs-directories


Review the [Truffle -- Package Management via NPM][truffle__package_management_via_npm] documentation for more details.


______


## Usage
[heading__usage]:
  #usage
  "&#x1F9F0; How to utilize this repository"


> How to utilize this repository


Write a set of contracts that make use of, and extend, `AddressStorage` features.


[**`contracts/Account.sol`**][source__test__examples__account_sol]


```Solidity
// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

/// @title Example contract instance to be reconstituted by `Host`
/// @author S0AndS0
contract Account {
    address public owner;
    string public name;

    /* -------------------------------------------------------------------- */

    ///
    constructor(address _owner, string memory _name) {
        owner = _owner;
        name = _name;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Require message sender to be an instance owner
    /// @param _caller {string} Function name that implements this modifier
    modifier onlyOwner(string memory _caller) {
        string memory _message = string(
            abi.encodePacked(
                "Account.",
                _caller,
                ": message sender not an owner"
            )
        );
        require(msg.sender == owner, _message);
        _;
    }

    /* -------------------------------------------------------------------- */

    /// @notice Update `Account.name`
    /// @param _new_name **{string}** Name to assign to `Account.name`
    /// @custom:throws **{Error}** `"Account.changeName: message sender not an owner"`
    function changeName(string memory _new_name)
        public
        onlyOwner("changeName")
    {
        name = _new_name;
    }

    /// @notice Update `Account.owner`
    /// @param _new_owner **{address}** Address to assign to `Account.owner`
    /// @custom:throws **{Error}** `"Account.changeOwner: message sender not an owner"`
    function changeOwner(address _new_owner) public onlyOwner("changeOwner") {
        owner = _new_owner;
    }
}
```


Above the `Account.sol` contract;


- stores owner information, such as `name`

- restricts certain mutation actions to owner only

- allows updating stored information by owner


[**`contracts/Host.sol`**][source__test__examples__host_sol]


```Solidity
// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.8.7;

import {
    AddressStorage
} from "@solidity-utilities/address-storage/contracts/AddressStorage.sol";

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
```


Above the `Host` contract;


- maintains mapping of `Account.owner` to `address(Account)` for `active_accounts` and `banned_accounts`

- restricts certain mutation actions to owner only

- provides convenience functions for retrieving information about `Account` instances


---


There is much more that can be accomplished by leveraging abstractions provided
by `AddressStorage`, check the [API][heading__api] section for full set of
features available. And review the
[`test/test__examples__Account.js`][source__test__test__examples__account_js]
and
[`test/test__examples__Host.js`][source__test__test__examples__host_js]
files for inspiration on how to use these examples within projects.


______


## API
[heading__api]:
  #api
  "Application Programming Interfaces for Solidity smart contracts"


> Application Programming Interfaces for Solidity smart contracts


---


### Contract `AddressStorage`
[heading__contract_addressstorage]:
  #contract-addressstorage
  "Solidity contract for storing and interacting with key/value address pairs"


> Solidity contract for storing and interacting with key/value address pairs


**Source** [`contracts/AddressStorage.sol`][source__contracts__addressstorage_sol]


**Properties**


- `data` **{mapping(address => address)}** Store key/value `address` pairs

- `indexes` **{mapping(address => uint256)}** Warning order of indexes **NOT** guaranteed!

- `keys` **{address[]}** Warning order of keys **NOT** guaranteed!

- `owner` **{address}** Allow mutation from specified `address`


**Developer note** -> Depends on
[`@solidity-utilities/library-mapping-address`][docs__library_mapping_address]


---


#### Method `changeOwner`
[heading__method_changeowner]:
  #method-changeowner
  "Overwrite old `owner` with new owner `address`"


> Overwrite old `owner` with new owner `address`


[**Source**][source__contracts__addressstorage_sol__changeowner] `changeOwner(address _new_owner)`


**Parameters**


- `_new_owner` **{address}** New owner address


**Throws** -> **{Error}** `"AddressStorage.changeOwner: message sender not an owner"`


---


#### Method `clear`
[heading__method_clear]:
  #method-clear
  "Delete `mapping` address key/value pairs and remove all `address` from `keys`"


> Delete `mapping` address key/value pairs and remove all `address` from `keys`


[**Source**][source__contracts__addressstorage_sol__clear] `clear()`


**Throws** -> **{Error}** `"AddressStorage.clar: message sender not an owner"`


**Developer note** -> **Warning** may fail if storing many `address` pairs


---


#### Method `get`
[heading__method_get]:
  #method-get
  "Retrieve stored value `address` or throws an error if _undefined_"


> Retrieve stored value `address` or throws an error if _undefined_


[**Source**][source__contracts__addressstorage_sol__get] `get(address _key)`


**Parameters**


- `_key` **{address}** Mapping key `address` to lookup corresponding value `address` for


**Returns** -> **{address}** Value for given key `address`


**Throws** -> **{Error}** `"AddressStorage.get: value not defined"`


**Developer note** -> Passes parameter to
[`data.getOrError`][docs__library_mapping_address__method__getorerror] with
default Error `_reason` to throw


---


#### Method `getOrElse`
[heading__method_getorelse]:
  #method-getorelse
  "Retrieve stored value `address` or provided default `address` if _undefined_"


> Retrieve stored value `address` or provided default `address` if _undefined_


[**Source**][source__contracts__addressstorage_sol__getorelse] `getOrElse(address _key, address _default)`


**Parameters**


- `_key` **{address}** Mapping key `address` to lookup corresponding value `address` for

- `_default` **{address}** Value to return if key `address` lookup is _undefined_


**Returns** -> **{address}** Value `address` for given key `address` or `_default` if _undefined_


**Developer note** -> Forwards parameters to
[`data.getOrElse`][docs__library_mapping_address__method__getorelse]


---


#### Method `getOrError`
[heading__method_getorerror]:
  #method-getorerror
  "Allow for defining custom error reason if value `address` is _undefined_"


> Allow for defining custom error reason if value `address` is _undefined_


[**Source**][source__contracts__addressstorage_sol__getorerror] `getOrError(address _key, string _reason)`


**Parameters**


- `_key` **{address}** Mapping key `address` to lookup corresponding value `address` for

- `_reason` **{string}** Custom error message to throw if value `address` is _undefined_


**Returns** -> **{address}** Value for given key `address`


**Throws** -> **{Error}** `_reason` if value is _undefined_


**Developer note** -> Forwards parameters to
[`data.getOrError`][docs__library_mapping_address__method__getorerror]


---


#### Method `has`
[heading__method_has]:
  #method-has
  "Check if `address` key has a corresponding value `address` defined"


> Check if `address` key has a corresponding value `address` defined


[**Source**][source__contracts__addressstorage_sol__has] `has(address _key)`


**Parameters**


- `_key` **{address}** Mapping key to check if value `address` is defined


**Returns** -> **{bool}** `true` if value `address` is defined, or `false` if
_undefined_


**Developer note** -> Forwards parameter to
[`data.has`][docs__library_mapping_address__method__has]


---


#### Method `indexOf`
[heading__method_indexof]:
  #method-indexof
  "Index for `address` key within `keys` array"


> Index for `address` key within `keys` array


[**Source**][source__contracts__addressstorage_sol__indexof] `indexOf(address _key)`


**Parameters**


- `_key` **{address}** Key to lookup index for


**Returns** -> **{uint256}** Current index for given `_key` within `keys` array


**Throws** -> **{Error}** `"AddressStorage.indexOf: key not defined"`


**Developer note** -> Passes parameter to
[`indexOfOrError`][heading__method_indexoforerror] with default `_reason`


---


#### Method `indexOfOrError`
[heading__method_indexoforerror]:
  #method-indexoforerror
  "Index for `address` key within `keys` array"


> Index for `address` key within `keys` array


[**Source**][source__contracts__addressstorage_sol__indexoforerror] `indexOfOrError(address _key, string _reason)`


**Parameters**


- `_key` **{address}** Key to lookup index for


**Returns** -> **{uint256}** Current index for given `_key` within `keys` array


**Throws** -> **{Error}** `_reason` if value for `_key` is _undefined_


**Developer note** -> Cannot depend on results being valid if mutation is
allowed between calls


---


#### Method `listKeys`
[heading__method_listkeys]:
  #method-listkeys
  "Convenience function to read all `mapping` key addresses"


> Convenience function to read all `mapping` key addresses


[**Source**][source__contracts__addressstorage_sol__listkeys] `listKeys()`


**Returns** -> **{address[]}** Keys `address` array


**Developer note** -> Cannot depend on results being valid if mutation is
allowed between calls


---


#### Method `remove`
[heading__method_remove]:
  #method-remove
  "Delete value `address` for given `_key`"


> Delete value `address` for given `_key`


[**Source**][source__contracts__addressstorage_sol__remove] `remove(address _key)`


**Parameters**


- `_key` **{address}** Mapping key to delete corresponding value `address` for


**Returns** -> **{address}** Value `address` that was removed from `data`
storage


**Throws**


- **{Error}** `"AddressStorage.remove: message sender not an owner"`

- **{Error}** `"AddressStorage.remove: value not defined"`


**Developer note** -> Passes parameter to
[`removeOrError`][heading__method_removeorerror] with default `_reason`


---


#### Method `removeOrError`
[heading__method_removeorerror]:
  #method-removeorerror
  "Delete value `address` for given `_key`"


> Delete value `address` for given `_key`


[**Source**][source__contracts__addressstorage_sol__removeorerror] `removeOrError(address _key, string _reason)`


**Parameters**


- `_key` **{address}** Mapping key to delete corresponding value `address` for

- `_reason` **{string}** Custom error message to throw if value `address` is _undefined_


**Returns** -> **{address}** Value `address` that was removed from `data`
storage


**Throws**


- **{Error}** `"AddressStorage.removeOrError: message sender not an owner"`

- **{Error}** `_reason` if value is _undefined_


**Developer note** -> **Warning** reorders `keys`, and mutates `indexes`, for
efficiency reasons


---


#### Method `selfDestruct`
[heading__method_selfdestruct]:
  #method-selfdestruct
  "Call `selfdestruct` with provided `address`"


> Call `selfdestruct` with provided `address`


[**Source**][source__contracts__addressstorage_sol__selfdestruct] `selfDestruct(address payable _to)`


**Parameters**


- `_to` **{address}** Where to transfer any funds this contract has


**Throws** -> **{Error}** `"AddressStorage.selfDestruct: message sender not an owner"`


---


#### Method `set`
[heading__method_set]:
  #method-set
  "Store `_value` under given `_key` while preventing unintentional overwrites"


> Store `_value` under given `_key` while preventing unintentional overwrites


[**Source**][source__contracts__addressstorage_sol__set] `set(address _key, address _value)`


**Parameters**


- `_key` **{address}** Mapping key to set corresponding value `address` for

- `_value` **{address}** Mapping value to set


**Throws**


- **{Error}** `"AddressStorage.set: message sender not an owner"`

- **{Error}** `"AddressStorage.set: value already defined"`


**Developer note** -> Forwards parameters to
[`setOrError`][heading__method_setorerror] with default `_reason`


---


#### Method `setOrError`
[heading__method_setorerror]:
  #method-setorerror
  "Store `_value` under given `_key` while preventing unintentional overwrites"


> Store `_value` under given `_key` while preventing unintentional overwrites


[**Source**][source__contracts__addressstorage_sol__setorerror] `setOrError(address _key, address _value, string _reason)`


**Parameters**


- `_key` **{address}** Mapping key to set corresponding value `address` for

- `_value` **{address}** Mapping value to set

- `_reason` **{string}** Custom error message to present if value `address` is defined


**Throws**


- **{Error}** `"AddressStorage.setOrError: message sender not an owner"`

- **{Error}** `_reason` if value is defined


**Developer note** -> Forwards parameters to
[`data.setOrError`][docs__library_mapping_address__method__setorerror]


---


#### Method `size`
[heading__method_size]:
  #method-size
  "Number of key/value `address` pairs currently stored"


> Number of key/value `address` pairs currently stored


[**Source**][source__contracts__addressstorage_sol__size] `size()`


**Returns** -> **{uint256}** Length of `keys` array


**Developer note** -> Cannot depend on results being valid if mutation is
allowed between calls


______


## Notes
[heading__notes]:
  #notes
  "&#x1F5D2; Additional things to keep in mind when developing"


> Additional things to keep in mind when developing


In some cases it may be cheaper for deployment costs to use the
`library-mapping-address` project directly instead, especially if tracking
defined keys is not needed.


---


This repository may not be feature complete and/or fully functional, Pull
Requests that add features or fix bugs are certainly welcomed.


______


## Contributing
[heading__contributing]:
  #contributing
  "&#x1F4C8; Options for contributing to address-storage and solidity-utilities"


> Options for contributing to address-storage and solidity-utilities


---


### Forking
[heading__forking]:
  #forking
  "&#x1F531; Tips for forking `address-storage`"


> Tips for forking `address-storage`


Make a [Fork][address_storage__fork_it] of this repository to an account that
you have write permissions for.


- Clone fork URL. The URL syntax is _`git@github.com:<NAME>/<REPO>.git`_, then add this repository as a remote...


```Bash
mkdir -p ~/git/hub/solidity-utilities

cd ~/git/hub/solidity-utilities

git clone --origin fork git@github.com:<NAME>/address-storage.git

git remote add origin git@github.com:solidity-utilities/address-storage.git
```


- Install development dependencies


```Bash
cd ~/git/hub/solidity-utilities/address-storage

npm ci
```


> Note, the `ci` option above is recommended instead of `install` to avoid
> mutating the `package.json`, and/or `package-lock.json`, file(s) implicitly


- Commit your changes and push to your fork, eg. to fix an issue...


```Bash
cd ~/git/hub/solidity-utilities/address-storage


git commit -F- <<'EOF'
:bug: Fixes #42 Issue


**Edits**


- `<SCRIPT-NAME>` script, fixes some bug reported in issue
EOF


git push fork main
```


- Then on GitHub submit a Pull Request through the Web-UI, the URL syntax is _`https://github.com/<NAME>/<REPO>/pull/new/<BRANCH>`_


> Note; to decrease the chances of your Pull Request needing modifications
> before being accepted, please check the
> [dot-github](https://github.com/solidity-utilities/.github) repository for
> detailed contributing guidelines.


---


### Sponsor
  [heading__sponsor]:
  #sponsor
  "&#x1F4B1; Methods for financially supporting `solidity-utilities` that maintains `address-storage`"


> Methods for financially supporting `solidity-utilities` that maintains
> `address-storage`


Thanks for even considering it!


Via Liberapay you may
<sub>[![sponsor__shields_io__liberapay]][sponsor__link__liberapay]</sub> on a
repeating basis.


For non-repeating contributions Ethereum is accepted via the following public address;


    0x5F3567160FF38edD5F32235812503CA179eaCbca


Regardless of if you're able to financially support projects such as
`address-storage` that `solidity-utilities` maintains, please consider sharing
projects that are useful with others, because one of the goals of maintaining
Open Source repositories is to provide value to the community.


______


## Change Log
[heading__change_log]:
  #change-log
  "&#x1f4dc; Note, this section only documents breaking changes or major feature releases"


> Note, this section only documents breaking changes or major feature releases


---


### Version `0.1.0`
[heading__version_010]:
  #version-010
  "Make eligible functions `external`"


> Make eligible functions `external`


```bash
git diff 'v0.1.0' 'v0.0.2'
```


**Developer notes**


Recent update to version `0.1.0` of `library-mapping-address` dependency now
attempts to prevent assigning values of `0x0`


Functions `get`, `has`, and `remove` are now `external` typed. However,
`getOrError` and `removeOrError` will remain `public` due to code duplication
causing _"out of gas"_ errors for some use cases.


______


## Attribution
[heading__attribution]:
  #attribution
  "&#x1F4C7; Resources that where helpful in building this project so far."


- [GitHub -- `github-utilities/make-readme`](https://github.com/github-utilities/make-readme)

- [GitHub -- `solidity-utilities/library-mapping-address`](https://github.com/solidity-utilities/library-mapping-address)

- [GitHub -- `actions/setup-node/issues/214`](https://github.com/actions/setup-node/issues/214#issuecomment-810829250)


______


## License
[heading__license]:
  #license
  "&#x2696; Legal side of Open Source"


> Legal side of Open Source


```
Solidity contract for storing and interacting with key/value address pairs
Copyright (C) 2021 S0AndS0

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```


For further details review full length version of
[AGPL-3.0][branch__current__license] License.



[branch__current__license]:
  LICENSE
  "&#x2696; Full length version of AGPL-3.0 License"


[badge__commits__address_storage__main]:
  https://img.shields.io/github/last-commit/solidity-utilities/address-storage/main.svg

[commits__address_storage__main]:
  https://github.com/solidity-utilities/address-storage/commits/main
  "&#x1F4DD; History of changes on this branch"


[address_storage__community]:
  https://github.com/solidity-utilities/address-storage/community
  "&#x1F331; Dedicated to functioning code"


[issues__address_storage]:
  https://github.com/solidity-utilities/address-storage/issues
  "&#x2622; Search for and _bump_ existing issues or open new issues for project maintainer to address."

[address_storage__fork_it]:
  https://github.com/solidity-utilities/address-storage/fork
  "&#x1F531; Fork it!"

[pull_requests__address_storage]:
  https://github.com/solidity-utilities/address-storage/pulls
  "&#x1F3D7; Pull Request friendly, though please check the Community guidelines"

[address_storage__main__source_code]:
  https://github.com/solidity-utilities/address-storage/
  "&#x2328; Project source!"

[badge__issues__address_storage]:
  https://img.shields.io/github/issues/solidity-utilities/address-storage.svg

[badge__pull_requests__address_storage]:
  https://img.shields.io/github/issues-pr/solidity-utilities/address-storage.svg

[badge__main__address_storage__source_code]:
  https://img.shields.io/github/repo-size/solidity-utilities/address-storage


[badge__github_actions]:
  https://github.com/solidity-utilities/address-storage/actions/workflows/test.yaml/badge.svg?branch=main

[activity_log__github_actions]:
  https://github.com/solidity-utilities/address-storage/deployments/activity_log


[truffle__package_management_via_npm]:
  https://www.trufflesuite.com/docs/truffle/getting-started/package-management-via-npm
  "Documentation on how to install, import, and interact with Solidity packages"


[docs__library_mapping_address]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md
  "`solidity-utilities/library-mapping-address` -- Solidity library for mapping addresses"

[docs__library_mapping_address__method__get]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-get
  "`solidity-utilities/library-mapping-address` -- Retrieves stored value `address` or throws an error if _undefined_"

[docs__library_mapping_address__method__getorelse]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-getorelse
  "`solidity-utilities/library-mapping-address` -- Retrieves stored value `address` or provided default `address` if _undefined_"

[docs__library_mapping_address__method__getorerror]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-getorerror
  "`solidity-utilities/library-mapping-address` -- Allows for defining custom error reason if value `address` is _undefined_"

[docs__library_mapping_address__method__has]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-has
  "`solidity-utilities/library-mapping-address` -- Check if `address` key has a corresponding value `address` defined"

[docs__library_mapping_address__method__overwrite]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-overwrite
  "`solidity-utilities/library-mapping-address` -- Store `_value` under given `_key` **without** preventing unintentional overwrites"

[docs__library_mapping_address__method__overwriteorError]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-overwriteorerror
  "`solidity-utilities/library-mapping-address` -- Store `_value` under given `_key` **without** preventing unintentional overwrites"

[docs__library_mapping_address__method__remove]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-remove
  "`solidity-utilities/library-mapping-address` -- Delete value `address` for given `_key`"

[docs__library_mapping_address__method__removeorerror]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-removeorerror
  "`solidity-utilities/library-mapping-address` -- Delete value `address` for given `_key`"

[docs__library_mapping_address__method__set]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-set
  "`solidity-utilities/library-mapping-address` -- Store `_value` under given `_key` while preventing unintentional overwrites"

[docs__library_mapping_address__method__setorerror]:
  https://github.com/solidity-utilities/library-mapping-address/blob/main/README.md#method-setorerror
  "`solidity-utilities/library-mapping-address` -- Store `_value` under given `_key` while preventing unintentional overwrites"


[source__test]:
  test
  "CI/CD (Continuous Integration/Deployment) tests and examples"

[source__test__examples__account_sol]:
  test/examples/Account.sol
  "Solidity code for demonstrating test/examples/Account.sol"

[source__test__examples__host_sol]:
  test/examples/Host.sol
  "Solidity code for demonstrating test/examples/host.sol"

[source__test__test__examples__account_js]:
  test/test__examples__Account.js
  "JavaScript code for testing test/examples/Account.sol"

[source__test__test__examples__host_js]:
  test/test__examples__Host.js
  "JavaScript code for testing test/examples/Host.sol"

[source__contracts__addressstorage_sol]:
  contracts/AddressStorage.sol
  "Solidity contract for storing and interacting with key/value `address` pairs"

[source__contracts__addressstorage_sol__changeowner]:
  contracts/AddressStorage.sol#L47
  "Overwrite old `owner` with new owner `address`"

[source__contracts__addressstorage_sol__clear]:
  contracts/AddressStorage.sol#L54
  "Delete `mapping` address key/value pairs and remove all `address` from `keys`"

[source__contracts__addressstorage_sol__get]:
  contracts/AddressStorage.sol#L68
  "Retrieve stored value `address` or throws an error if _undefined_"

[source__contracts__addressstorage_sol__getorelse]:
  contracts/AddressStorage.sol#L77
  "Retrieve stored value `address` or provided default `address` if _undefined_"

[source__contracts__addressstorage_sol__getorerror]:
  contracts/AddressStorage.sol#L90
  "Allow for defining custom error reason if value `address` is _undefined_"

[source__contracts__addressstorage_sol__has]:
  contracts/AddressStorage.sol#L104
  "Check if `address` key has a corresponding value `address` defined"

[source__contracts__addressstorage_sol__indexof]:
  contracts/AddressStorage.sol#L112
  "Index for `address` key within `keys` array"

[source__contracts__addressstorage_sol__indexoforerror]:
  contracts/AddressStorage.sol#L121
  "Index for `address` key within `keys` array"

[source__contracts__addressstorage_sol__listkeys]:
  contracts/AddressStorage.sol#L136
  "Convenience function to read all `mapping` key addresses"

[source__contracts__addressstorage_sol__remove]:
  contracts/AddressStorage.sol#L143
  "Delete value `address` for given `_key`"

[source__contracts__addressstorage_sol__removeorerror]:
  contracts/AddressStorage.sol#L153
  "Delete value `address` for given `_key`"

[source__contracts__addressstorage_sol__selfdestruct]:
  contracts/AddressStorage.sol#L178
  "Call `selfdestruct` with provided `address`"

[source__contracts__addressstorage_sol__set]:
  contracts/AddressStorage.sol#L188
  "Store `_value` under given `_key` while preventing unintentional overwrites"

[source__contracts__addressstorage_sol__setorerror]:
  contracts/AddressStorage.sol#L198
  "Store `_value` under given `_key` while preventing unintentional overwrites"

[source__contracts__addressstorage_sol__size]:
  contracts/AddressStorage.sol#L215
  "Number of key/value `address` pairs currently stored"

