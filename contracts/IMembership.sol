// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/// @title IMembership
/// @dev Interface for membership tokens
interface IMembership {
    /// @notice Called to return membership expiration
    function membershipInfo(address _member)
        external
        view
        returns (uint256 _joined, uint256 _expiry);
}
