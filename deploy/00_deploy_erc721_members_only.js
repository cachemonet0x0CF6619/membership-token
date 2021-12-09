// deploy/00_deploy_erc721_members_only.js
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy('ERC721MembersOnly', {
    from: deployer,
    args: [
      'ERC721MembersOnly',
      'TEST',
      [deployer],
      [100]
    ],
    log: true,
  });
}

module.exports.tags = ['ERC721MembersOnly'];
