const { expect } = require('chai');
const { ethers, deployments } = require('hardhat');

describe('ERC721MembersOnly', function () {
  let ERC721MembersOnly;
  let deployer;
  let member;

  beforeEach(async () => {
    [deployer, member] = await ethers.getSigners();

    await deployments.fixture();
    ERC721MembersOnly = await deployments.get('ERC721MembersOnly');
    erc721MembersOnly = await ethers.getContractAt(
      'ERC721MembersOnly',
      ERC721MembersOnly.address,
      deployer,
    )
  });

  describe('Membership', async () => {
    it('adds a member', async () => {
      await erc721MembersOnly.connect(member).join({ value: ethers.utils.parseEther('0.1') });
      expect(await erc721MembersOnly.isMember(member.address)).eq(true);
    });
  });
});
