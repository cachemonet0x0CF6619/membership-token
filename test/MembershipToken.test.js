const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Membership Token', function () {
  let owner, member, contract
  before(async () => {
    const [owner_, member_] = await ethers.getSigners();
    owner = owner_;
    member = member_;

    const Contract = await ethers.getContractFactory('MembershipToken');
    contract = await Contract.deploy(
      "Membership",
      "MEMBA",
      [owner.address],
      [100]
    );
    await contract.deployed();
  });
  it('should add an address to the list', async () => {
    await contract.connect(member).join({ value: ethers.utils.parseEther('0.1') });
    const subscribed = await contract.isSubscribed(member.address);
    expect(subscribed).to.eq(true);
  });
  it('should provide a list of vips', async () => {
    const subs = await contract.connect(owner).members();
    expect(subs).to.include(member.address);
  });
  it('should allow owner to banish members', async () => {
    await contract.connect(owner).banish(member.address);
    expect(await contract.isBanished(member.address)).to.eq(true);
  });
  it('should exclude banished members from vip', async () => {
    const subs = await contract.connect(owner).members();
    expect(subs).to.not.include(member.address);
  });
});
