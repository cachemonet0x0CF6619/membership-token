// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "./IMembership.sol";

abstract contract MembershipBase is ERC165, IMembership {
    MembershipInfo private _info;

    struct MembershipInfo {
        uint256 joined;
        uint256 expiry;
    }

    mapping(address => MembershipInfo) internal _members;
    uint256 internal _count;

    /// @dev Emited when membership gained
    event Joined(address member, uint256 expiry);

    modifier onlyMembers() {
        require(
            _members[msg.sender].expiry >= block.timestamp,
            "Invalid membership"
        );
        _;
    }

    modifier onlyNonMembers() {
        require(
            _members[msg.sender].expiry <= block.timestamp,
            "Invalid membership"
        );
        _;
    }

    /// @inheritdoc IMembership
    function membershipInfo(address _member)
        external
        view
        returns (uint256 joined, uint256 expiry)
    {
        MembershipInfo memory member = _members[_member];
        joined = member.joined;
        expiry = member.expiry;
    }

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IMembership).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @dev set membership join and expiration dates
    /// @param _member address of member
    /// @param _duration membership duration in seconds
    function _join(address _member, uint256 _duration) internal {
        require(_members[_member].expiry < block.timestamp);
        _members[_member] = MembershipInfo(
            block.timestamp,
            block.timestamp + _duration
        );
        _count++;
        emit Joined(_member, _members[_member].expiry);
    }

    /// @dev set membership to zero value
    /// @param _member address of member
    function _remove(address _member) internal virtual {
        MembershipInfo memory member = _members[_member];
        _members[_member] = MembershipInfo(member.joined, 0);
        delete member;
    }
}
