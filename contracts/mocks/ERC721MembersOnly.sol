// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../MembershipWithRenewal.sol";

contract ERC721MembersOnly is
    ERC721,
    MembershipWithRenewal,
    PaymentSplitter,
    Ownable
{
    uint256 public max = 100;
    uint256 constant fee = 0.01 ether;
    uint256 constant renewal = 30 days;

    mapping(address => uint256) public paid;
    mapping(address => bool) public exiled;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory payees,
        uint256[] memory shares
    ) ERC721(name, symbol) PaymentSplitter(payees, shares) {}

    /// @inheritdoc	ERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, MembershipBase)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // join with membership dues
    function join() external payable onlyNonMembers {
        require(_count <= max, "limit reached");
        require(msg.value >= fee, "minimum fee not met");
        _join(msg.sender, block.timestamp + renewal);
    }

    // @dev restrict to members
    function memberMint() external onlyMembers {
        _safeMint(msg.sender, _count);
    }

    // @dev check renewal date is gt || eq now (block.timestamp)
    function isMember(address member) public view returns (bool) {
        return _members[member].expiry >= block.timestamp;
    }

    function renew() public payable onlyMembers {
        require(msg.value >= fee, "minimum due not met");
        _renew(msg.sender, block.timestamp + renewal);
    }

    function leave() public onlyMembers {
        _remove(msg.sender);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        _join(to, _members[from].expiry);
        if (isMember(from)) _remove(from);
    }
}
