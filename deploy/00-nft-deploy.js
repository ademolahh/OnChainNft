const { network } = require("hardhat");
const verify = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { log, deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  const args = [];
  const nft = await deploy("MyNft", {
    from: deployer,
    log: true,
    args: args,
    waitConfirmations: 5,
  });
  log("Deployed sucessfuly!!!!!!!!!!");
  if (chainId != 31337) {
    await verify(nft.address, args);
  }
};

module.exports.tags = ["all", "nft"];
