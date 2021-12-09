// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./MembershipBase.sol";

abstract contract MembershipWithRenewal is MembershipBase {
    /// @dev emitted when membership is renewed
    event Renewed(address indexed member, uint256 duration);

    /// @dev increase member expiration by given duration
    function _renew(address _member, uint256 _duration) internal virtual {
        _members[_member].expiry = block.timestamp + _duration;
        emit Renewed(_member, _members[_member].expiry);
    }
}
