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
