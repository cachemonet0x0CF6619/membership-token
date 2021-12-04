// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MembershipToken is ERC721, PaymentSplitter, Ownable {
    event Subscribed(address member, uint256 expiry);
    event Renewed(address member, uint256 expiry);
    event Banished(address member, uint256 wen);
    event Repatriated(address member, uint256 wen);

    uint8 public constant max = 255;

    bytes internal _uri;
    address internal staff;

    // @dev members - subscribers
    address[] public list;

    // @dev block.timestamp + renewal = new expiry
    uint256 public constant renewal = 1_000_000;

    uint256 public constant due = 0.01 ether;
    uint256 public constant fee = 0.1 ether;

    mapping(address => uint256) paid;
    mapping(address => bool) exiled;

    constructor(
        string memory name,
        string memory symbol,
        address[] memory payees,
        uint256[] memory shares
    ) ERC721(name, symbol) PaymentSplitter(payees, shares) {}

    function setBaseURI(string memory uri) public onlyOwner {
        _uri = bytes(uri);
    }

    function _baseURI() internal view override returns (string memory) {
        return string(_uri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        return
            string(
                abi.encodePacked(_baseURI(), Strings.toString(tokenId), ".json")
            );
    }

    function setStaff(address s) public onlyOwner {
        staff = s;
    }

    modifier notExiled() {
        require(!exiled[msg.sender]);
        _;
    }

    function join() public payable {
        require(list.length <= max, "limit reached");
        require(msg.value >= fee, "minimum fee not met");
        require(!isSubscribed(msg.sender), "already registered");
        _safeMint(msg.sender, list.length);
        _renew(msg.sender, block.timestamp + renewal);
    }

    function _renew(address member, uint256 duration) internal {
        require(!isBanished(msg.sender), "banished");
        paid[member] = duration;
        emit Renewed(member, paid[member]);
    }

    // @dev check renewal date is gt || eq now (block.timestamp)
    function isSubscribed(address member) public view notExiled returns (bool) {
        return paid[member] >= block.timestamp;
    }

    function renew() public payable notExiled {
        require(msg.value >= due, "minimum due not met");
        _renew(msg.sender, block.timestamp + renewal);
    }

    function repatriate(address member) public onlyOwner {
        require(isBanished(member), "power trip much?");
        exiled[member] = false;
        emit Repatriated(member, block.timestamp);
        list.push(member);
        _renew(member, block.timestamp);
    }

    function banish(address member) public onlyOwner {
        require(member != owner(), "cheeky");
        exiled[member] = true;
        _remove(member);
        emit Banished(member, block.timestamp);
    }

    function _remove(address member) internal {
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] != member) continue;
            list[i] = list[list.length - 1];
            list.pop();
            break;
        }
    }

    function isBanished(address member) public view returns (bool) {
        return exiled[member];
    }

    function unsubscribe() public {
        _unsubscribe(msg.sender);
    }

    function _unsubscribe(address member) internal {
        require(isSubscribed(member), "not registered");
        paid[member] = 0;
        _remove(member);
    }

    modifier onlyStaff() {
        require(
            msg.sender == staff || msg.sender == owner(),
            "only the staff can see this"
        );
        _;
    }

    function members() public view onlyStaff returns (address[] memory) {
        return list;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        _renew(to, paid[from]);
        list.push(to);
        if (isSubscribed(from)) {
            _unsubscribe(from);
        }
    }

    // @dev test only
    function explode() public onlyOwner {
        selfdestruct(payable(owner()));
    }
}
